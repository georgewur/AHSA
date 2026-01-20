
Flow1D.Internal = new.env()

default.1D.stateinit = function(x)
{
  return(0)
}

default.1D.isacceptable = function(x,state)
{
  return(TRUE);
}

default.1D.int.flux = function(x,state,gradstate)
{
  return(0)
}


default.formatnumber = function(x)
{
  return(formatC(x,width=8,format="f",digits=4))
}

newFlow1D = function(
  domain,
  nodes,
  stateinit = default.1D.stateinit,
  is.acceptable = default.1D.isacceptable ,                     
  int.flux= default.1D.int.flux,                   
  spat.ext.flux= NULL,
  point.ext.flux= NULL,
  formatnumber = default.formatnumber,
  HNLSoption = FALSE,
  name="")
{
  result = new.env()
  
  if(name=="")
  {
    result$name=paste("Flow1D",gsub(" ","_",date()),sep="")
  } else {
    result$name = name
  }
  
  result$domain = domain
  
  result$is.acceptable = is.acceptable
  result$stateinit = stateinit
  result$fn = formatnumber
  
  result$int.flux = int.flux
  
  if(is.null(spat.ext.flux))
  {
    result$spat.ext.flux = NULL
  } else {
    if(is.list(spat.ext.flux))
    {
      result$spat.ext.flux = spat.ext.flux
    } else {
      result$spat.ext.flux = list("only.spat.ext"=spat.ext.flux)
    }
  }
  
  
  
  # lists to store boundary things 
  
  result$fixedstate = list()
  result$fixedflux =  list()
  result$stateflux =  list()
  
  # check if nodes are in domain 
  nodes = sort(nodes)
  
  
  nodeindex = 1
  for(i in 1:length(nodes))
  {
    if((domain[1] <= nodes[i])&(nodes[i] <= domain[2]))
    {
      xvalue = nodes[i]
      statevalue = stateinit(xvalue)
      if(!result$is.acceptable(xvalue,statevalue))
      {
        cat("error: unacceptable initial state value:\n")
        cat(paste("x=",xvalue,";state = ",statevalue,"\n"))
        return(NULL)    
      }
      result$cell= rbind(result$cell,
                         data.frame(x=xvalue,
                                    index = nodeindex,
                                    area=0,
                                    state=stateinit(nodes[i])))  
      nodeindex = nodeindex+1
    }
  }
  
  result$NumNodes = dim(result$cell)[1]
  
  
  diffinnodes = length(nodes)-result$NumNodes
  if(diffinnodes>0)
  {
    warning(paste("number of nodes removed as outside domain=",diffinnodes))
  }
  
  # check if there is just one external flux, rename it then
  
  if(!is.null(point.ext.flux)){
    if(is.numeric(point.ext.flux[[1]])) 
    {
      point.ext.flux = list(only.point.ext.flux=point.ext.flux)
    }
  }
  
  # add the nodenumber to the point.ext.flux
  result$point.ext.flux= lapply(point.ext.flux,
                                function(f)
                                {
                                  cellindex = which.min((f$pos-result$cell$x)^2)
                                  return(list(pos=f$pos,flux=f$flux,cellindex=cellindex))
                                }
  )
  
  # internal fluxes
  
  result$intflux.list = data.frame()
  
  add.internalseg = function(this,fromnode,tonode)
  {
    fromx = this$cell[fromnode,"x"]
    tox = this$cell[tonode,"x"]
    distnodes = abs(fromx-tox)
    Cx = (fromx+tox)/2
    this$intflux.list = rbind(this$intflux.list,
                              data.frame(Cx=Cx,
                                         distnodes = distnodes,
                                         fromnode=fromnode,tonode=tonode))
    this$cell[fromnode,"area"] = this$cell[fromnode,"area"]+ 
      distnodes/2;
    this$cell[tonode,"area"] = this$cell[tonode,"area"]+ 
      distnodes/2;
  }
  sort.indices = sort(result$cell[,1],index.return=TRUE)$ix
  for(i in 2:result$NumNodes)
  {
    add.internalseg(result,sort.indices[i-1],sort.indices[i])
  }
  
  leftcellindex = which(result$cell[,"index"]==sort.indices[1])
  result$cell[leftcellindex,"area"] = result$cell[leftcellindex,"area"]+
    result$cell[leftcellindex,"x"]-result$domain[1]
  rightcellindex = which(result$cell[,"index"]==sort.indices[result$NumNodes])
  result$cell[rightcellindex,"area"] = result$cell[rightcellindex,"area"]+
    result$domain[2]-result$cell[rightcellindex,"x"]
  result$boundarycell = data.frame(cellindex=c(leftcellindex,rightcellindex),
                                   nx = c(1,-1))
  
  # adding workspace for calculating misfits
  result$.s  = rep(0,result$NumNodes)
  result$.B = rep(0,result$NumNodes)
  result$.MAM = 0
  result$.whichMAM = 0
  result$.RMSM = 0
  result$.dBds = matrix(0,result$NumNodes,result$NumNodes)
  
  # remember to update the B for the first time

  result$cell = cbind(result$cell,B=result$.B)
  
  # remember option
  result$HNLSoption = HNLSoption
  
  # all done
  attr(result,"class")="Flow1D"
  return(result)
}


.updateB = function(model)
  UseMethod(".updateB")
.updateB.Flow1D = function(this)
{
  this$.B[1:this$NumNodes] = 0
  
  #internal flux
  
  do.int.flux = function(f)
  {
    jf = f[["fromnode"]]
    jt = f[["tonode"]]
    fns = this$.s[[jf]]
    fnx = this$cell$x[jf] #X
    tns = this$.s[[jt]]
    tnx = this$cell$x[jt] #X
    smid = (fns+tns)/2
    sgrad = (tns-fns)/f[["distnodes"]]
    if(!this$HNLSoption)
    {
      value = this$int.flux(f[["Cx"]],smid,sgrad)
    } else {
      value = (2*this$int.flux(f[["Cx"]],smid,sgrad)+
        this$int.flux(fnx,fns,sgrad)+  this$int.flux(tnx,tns,sgrad))/4 
    }
    this$.B[jf] = this$.B[jf] - value
    this$.B[jt] = this$.B[jt] + value
  }
  apply(this$intflux.list,1,do.int.flux)
  
  # external fluxes
  
  for(f in this$spat.ext.flux)
  {
    do.spat.flux = function(c)
    {
      i = c["index"]
      x = c["x"]
      s = this$.s[i]
      a = c["area"]
      value = f(x,s)
      this$.B[i] = this$.B[i]+value*a
    }
    apply(this$cell,1,do.spat.flux)
  }
  
  dummy = lapply(this$point.ext.flux,
                 function(f){ 
                   i = f$cellindex
                   if(is.function(f$flux)) value=f$flux(this$.s[i])
                   else value = f$flux
                   this$.B[i] = this$.B[i]+value})
  
  # boundary conditions
  
  do_fixedstate = function(bc)
  {
    i = this$boundarycell$cellindex[bc$BCindex]
#     print(paste("BC ",i,this$.B[i]))
    this$fixedstate[[bc$BCindex]]$freeflux = -this$.B[i]
    this$.B[i] = 0
  } 
  lapply(this$fixedstate,do_fixedstate)
  
  do_fixed_flux = function(bc)
  {
    i = this$boundarycell$cellindex[bc$BCindex]
    this$.B[i] = this$.B[i] + bc$value * this$boundarycell$nx[bc$BCindex]
  }
  lapply(this$fixedflux,do_fixed_flux)
  
  do_state_flux = function(bc)
  {
    i = this$boundarycell$cellindex[bc$BCindex]
    fluxvalue = bc$valuefunc(this$.s[i]) * this$boundarycell$nx[bc$BCindex]
    this$.B[i] = this$.B[i] + fluxvalue
  }
  lapply(this$stateflux,do_state_flux)
  
  
  
  this$.MAM = max(abs(this$.B))
  this$.wichMAM = which.max(abs(this$.B))
  this$.RMSM = sqrt(mean(this$.B^2))
}

.updatecellB = function(this)
  UseMethod(".updatecellB")
.updatecellB.Flow1D = function(this)
{
  this$.s = this$cell$state
  .updateB(this)
  this$cell$B = this$.B
  this$currentMAM = this$.MAM
}

.updatedBds = function(model,eps)
  UseMethod(".updatedBds")
.updatedBds.Flow1D = function(this,eps)
{
  this$.dBds[,] = 0
  
  do.int.flux = function(f)
  {
    jf = f[["fromnode"]]
    jt = f[["tonode"]]
    fns = this$.s[jf]
    fnx = this$cell$x[jf] #X
    tns = this$.s[jt]
    tnx = this$cell$x[jt] #X
    smid = (fns+tns)/2
    sgrad = (tns-fns)/f["distnodes"]
    if(!this$HNLSoption)
    {
      value = this$int.flux(f["Cx"],smid,sgrad)
      ds = (this$int.flux(f["Cx"],smid+eps,sgrad)-value)/eps*0.5
      dg = (this$int.flux(f["Cx"],smid,sgrad+eps)-value)/eps/f["distnodes"]
      this$.dBds[jf,jf] = this$.dBds[jf,jf] - ds + dg 
      this$.dBds[jt,jt] = this$.dBds[jt,jt] + ds + dg
      this$.dBds[jf,jt] = this$.dBds[jf,jt] - ds - dg
      this$.dBds[jt,jf] = this$.dBds[jt,jf] + ds - dg
    } else {
      midvalue = this$int.flux(f["Cx"],smid,sgrad)
      midds = (this$int.flux(f["Cx"],smid+eps,sgrad)-midvalue)/eps*0.5/2
      middg = (this$int.flux(f["Cx"],smid,sgrad+eps)-midvalue)/eps/f["distnodes"]/2    
      this$.dBds[jf,jf] = this$.dBds[jf,jf] - midds + middg 
      this$.dBds[jt,jt] = this$.dBds[jt,jt] + midds + middg
      this$.dBds[jf,jt] = this$.dBds[jf,jt] - midds - middg
      this$.dBds[jt,jf] = this$.dBds[jt,jf] + midds - middg
      fnvalue = this$int.flux(fnx,fns,sgrad)
      fnds = (this$int.flux(fnx,fns+eps,sgrad)-fnvalue)/eps/4
      fndg = (this$int.flux(fnx,fns,sgrad+eps)-fnvalue)/eps/f["distnodes"]/4    
      this$.dBds[jf,jf] = this$.dBds[jf,jf] - fnds + fndg
      this$.dBds[jt,jt] = this$.dBds[jt,jt]  + fndg
      this$.dBds[jf,jt] = this$.dBds[jf,jt]  - fndg
      this$.dBds[jt,jf] = this$.dBds[jt,jf] + fnds - fndg
      tnvalue = this$int.flux(tnx,tns,sgrad)
      tnds = (this$int.flux(tnx,tns+eps,sgrad)-tnvalue)/eps/4
      tndg = (this$int.flux(tnx,tns,sgrad+eps)-tnvalue)/eps/f["distnodes"]/4    
      this$.dBds[jf,jf] = this$.dBds[jf,jf]  + tndg
      this$.dBds[jt,jt] = this$.dBds[jt,jt]  + tnds + tndg
      this$.dBds[jf,jt] = this$.dBds[jf,jt]  + tnds - tndg
      this$.dBds[jt,jf] = this$.dBds[jt,jf]  - tndg  
    }
    return()
  }
  apply(this$intflux.list,1,do.int.flux)
  
  # external fluxes
  for(f in this$spat.ext.flux)
  {
    do.spat.flux = function(c)
    {
      i = c["index"]
      x = c["x"]
      s = this$.s[i]
      a = c["area"]
      value = f(x,s)
      ds = (f(x,s+eps)-value)/eps
      this$.dBds[i,i] = this$.dBds[i,i]+ds*a
    }
    apply(this$cell,1,do.spat.flux)
  }
  dummy = lapply(this$point.ext.flux,
                 function(f){ 
                   if(is.function(f$flux)){
                     i = f$cellindex
                     s = this$.s[i]
                     value=(f$flux(s+eps)-f$flux(s))/eps
                     this$.dBds[i,i] = this$.dBds[i,i]+value
                   }})
  
  # bring in boundary conditions
  do_fixed_state = function(bc)
  {
    i = this$boundarycell$cellindex[bc$BCindex]
    this$.dBds[i,] = 0
    this$.dBds[,i] = 0
    this$.dBds[i,i] = 1     
  }
  lapply(this$fixedstate,do_fixed_state)
  
  do_state_flux = function(bc)
  {
    i = this$boundarycell$cellindex[bc$BCindex]
    this$.dBds[i,i] = this$.dBds[i,i] + (bc$valuefunc(this$cell$state[i]+eps)- 
      bc$valuefunc(this$cell$state[i])) *
      this$boundarycell$nx[bc$BCindex]/eps      
  }
  lapply(this$stateflux,do_state_flux)  
}

summary.Flow1D = function(this)
{
  cat(paste("Flow1D system: ",this$name,"\n"))
  cat(paste("  number of cells = ",dim(this$cell)[1],"\n"))  
  n = length(this$spat.ext.flux) 
  cat(paste("  number of spatial external fluxes = ",n,"\n"))  
  if(n>0)
  {
    cat("    with names: ")
    cat(names(this$spat.ext.flux))
    cat("\n")
  }
  n = length(this$point.ext.flux) 
  if(n>0)
  {
    cat(paste("  number of cells with point external fluxes = ",n," "))  
    for(i in 1:n)
    {
      cat("\n     for cell ")
      cat(this$point.ext.flux[[i]]$cellindex)
      cat(" : ")
      cat(names(this$point.ext.flux)[[i]])
    } 
    cat("\n")
  }
  cat(paste("  number of internal fluxes = ",dim(this$intflux.list)[1],"\n"))	
  cat(paste("  number of boundary cells = ",dim(this$boundarycell)[1],"\n"))	
}

print.Flow1D = function(this)
{
  summary(this)
}

data.frame.cells = function(model,cellnumbers=numeric())
  UseMethod("data.frame.cells")
data.frame.cells.Flow1D = function(this,cellnumbers=numeric())
{
  if(length(cellnumbers)==0)
  {
    cellnumbers = 1:dim(this$cell)[1]
  }
  pointextfluxnames = names(this$point.ext.flux)
  results=data.frame()
  for(cn in cellnumbers)
  {
    newrow = list()
    newrow[["x"]] = this$cell[cn,"x"]
    newrow[["area"]] = this$cell[cn,"area"]
    newrow[["state"]] = this$cell[cn,"state"]
    for(nff in names(this$spat.ext.flux))
    {
      newrow[[nff]]= this$cell[cn,"area"] *
        this$spat.ext.flux[[nff]](this$cell[cn,"x"],
                                  this$cell[cn,"state"])
    }
    for(nff in pointextfluxnames)
    {
      newrow[[nff]] = NA
    }
    if(dim(results)[1]==0)
    {
      results = as.data.frame(newrow)
    } else
    {
      results = rbind(results,newrow,deparse.level=0)
    }
  }  
  for(n in pointextfluxnames)
  {
    f = this$point.ext.flux[[n]]
    i = f$cellindex
    if(is.function(f$flux))
    {
      results[[n]][i] = f$flux(this$cell$state[i])
    } else { 
      results[[n]][i] = f$flux
    }
  }
  .updateB(this)
  results = cbind(results,misfit=this$cell$B)
  return(results)
}


data.frame.fluxes = function(model,fluxnumbers=numeric())
  UseMethod("data.frame.fluxes")
data.frame.fluxes.Flow1D = function(this,fluxnumbers=numeric())
{
  if(length(fluxnumbers)==0)
  {
    fluxnumbers = 1:dim(this$intflux.list)[1]
  }
  results=data.frame()
  for(fn in fluxnumbers)
  {
    newrow = list()
    fromn = this$intflux.list[fn,"fromnode"]
    ton = this$intflux.list[fn,"tonode"]
    newrow[["fromnode"]] = fromn
    newrow[["tonode"]] = ton 
    newrow[["x"]] = this$intflux.list[fn,"Cx"]
    newrow[["y"]] = this$intflux.list[fn,"Cy"]
    newrow[["length"]] = this$intflux.list[fn,"length"]
    fromstate = this$cell[fromn,"state"]
    tostate = this$cell[ton,"state"]
    newrow[["state"]] = (fromstate+tostate)/2.0
    newrow[["grad"]] =  (tostate-fromstate)/this$intflux.list[fn,"distnodes"]
    newrow[["flux"]] = this$int.flux(newrow[["x"]],newrow[["state"]],newrow[["grad"]])
    if(dim(results)[1]==0)
    {
      results = as.data.frame(newrow)
    } else
    {
      results = rbind(results,newrow,deparse.level=0)
    }
  }
  return(results)
}

data.frame.boundaryfluxes = function(this)
  UseMethod("data.frame.boundaryfluxes")
data.frame.boundaryfluxes.Flow1D = function(this)
{ 
  results=data.frame()
  for(f in this$fixedstate)
  {
    i = this$boundarycell[f$BCindex,1]
    results = rbind(results,data.frame(cellnumber = i, x = this$cell$x[i],
                                      "type"="fixed state",flux=f$freeflux))
  }
  for(f in this$fixedflux)
  {
    i = this$boundarycell[f$BCindex,1]
    results = rbind(results,data.frame(cellnumber = i, x = this$cell$x[i],
                                       "type"="fixed state",flux=f$freeflux))   
  }
  for(f in this$stateflux)
  {
    i = this$boundarycell[f$BCindex,1] 
    results = rbind(results,data.frame(cellnumber = i, x = this$cell$x[i],
                                       "type"="state flux",flux=f$valuefunc(this$cell$state[i])))
  }
  return(results)
}

remove.BC = function(model,bci)
  UseMethod("remove.BC")
remove.BC.Flow1D = function(this,bci)
{
  if(length(this$fixedstate)>0)
  {
    this$fixedstate = this$fixedstate[sapply(this$fixedstate,function(l){l$BCindex!=bci})]
  }  
  if(length(this$fixedflux)>0)
  {
    this$fixedflux = this$fixedflux[sapply(this$fixedflux,function(l){l$BCindex!=bci})]
  }
  if(length(this$stateflux)>0)
  {
    this$stateflux = this$stateflux[sapply(this$stateflux,function(l){l$BCindex!=bci})]        
  }  
}

set.BC.fixedstate  = function(model,value=0,cellnumbers=numeric())
  UseMethod("set.BC.fixedstate")
set.BC.fixedstate.Flow1D = function(this,value=0,cellnumbers=numeric())
{
  if(length(cellnumbers)>0)
  {
    for(n in cellnumbers)
    {
      I = which(this$boundarycell$cellindex==n)
      if(length(I)==0)
      {
        warning(paste("bc fixedstate for cell",n,"not set as this is no boundary cell"))
      } else {
        bci = I[1]
        remove.BC(this,bci)
        this$cell[n,"state"] = value
        this$fixedstate[[length(this$fixedstate)+1]] = 
          list(BCindex=bci,value=value,freeflux=0)
      }
    }
  } 
}

set.BC.left.fixedstate = function(model,value)
  UseMethod("set.BC.left.fixedstate")
set.BC.left.fixedstate.Flow1D = function(this,value)
{
  set.BC.fixedstate(this,value,this$boundarycell$cellindex[1])
}

set.BC.right.fixedstate = function(model,value)
  UseMethod("set.BC.right.fixedstate")
set.BC.right.fixedstate.Flow1D = function(this,value)
{
  set.BC.fixedstate(this,value,this$boundarycell$cellindex[2])
}


set.BC.fixedflux = function(model,value,cellnumbers=numeric())
  UseMethod("set.BC.fixedflux")
set.BC.fixedflux.Flow1D = function(this,value,cellnumbers=numeric())
{
  if(length(cellnumbers)>0)
  {
    for(n in cellnumbers)
    {
      I = which(this$boundarycell$cellindex==n)
      if(length(I)==0)
      {
        warning(paste("bc fixedflux for cell",n,"not set as this is no boundary cell"))
      } else {
        bci = I[1]
        remove.BC(this,bci)
        this$fixedflux[[length(this$fixedflux)+1]] = 
          list(BCindex=bci,value=value)
      }
    }
  }
}

set.BC.left.fixedflux = function(model,value)
  UseMethod("set.BC.left.fixedflux")
set.BC.left.fixedflux.Flow1D = function(this,value)
{
  set.BC.fixedflux(this,value,this$boundarycell$cellindex[1])
}

set.BC.right.fixedflux = function(model,value)
  UseMethod("set.BC.right.fixedflux")
set.BC.right.fixedflux.Flow1D = function(this,value)
{
  set.BC.fixedflux(this,value,this$boundarycell$cellindex[2])
}


set.BC.stateflux = function(model,value,cellnumbers=numeric())
  UseMethod("set.BC.stateflux")
set.BC.stateflux.Flow1D = function(this,value,cellnumbers=numeric())
{
  if(length(cellnumbers)>0)
  {
    for(n in cellnumbers)
    {
      I = which(this$boundarycell$cellindex==n)
      if(length(I)==0)
      {
        warning(paste("bc stateflux for cell",n,"not set as this is no boundary cell"))
      } else {
        bci = I[1]
        remove.BC(this,bci)
        this$stateflux[[length(this$stateflux)+1]] = 
          list(BCindex=bci,valuefunc=value)
      }
    }
  }  
} 


set.BC.left.stateflux = function(model,value)
  UseMethod("set.BC.left.stateflux")
set.BC.left.stateflux.Flow1D = function(this,value)
{
  set.BC.stateflux(this,value,this$boundarycell$cellindex[1])
}

set.BC.right.stateflux = function(model,value)
  UseMethod("set.BC.right.stateflux")
set.BC.right.stateflux.Flow1D = function(this,value)
{
  set.BC.stateflux(this,value,this$boundarycell$cellindex[2])
}

calc.flux = function(model,fid)
  UseMethod("calc.flux")
calc.flux.Flow1D = function(this,fid)
{
  f = this$intflux.list[fid,]
  fn = this$cell[f$fromnode,]
  tn = this$cell[f$tonode,]
  sgrad =  (tn$state-fn$state)/f$distnodes
  if(!this$HNLSoption)
  {
    fintens = this$int.flux(f$Cx,(fn$state+tn$state)/2.0,sgrad)
  } else {
    fintens = (2*this$int.flux(f$Cx,(fn$state+tn$state)/2.0,sgrad)+
      this$int.flux(fn$x,fn$s,sgrad)+  
      this$int.flux(tn$x,tn$s,sgrad))/4   
  }
  return(fintens)
}

current.misfit.stats = function(model)
  UseMethod("current.misfit.stats")
current.misfit.stats.Flow1D = function(this)
{
  .updateB(this)
  this$currentMAM = this$.MAM
  this$currentRMSM = this$.RMSM
  this$cell$B = this$.B
  
  return(list(RMSM = this$.RMSM, MAM = this$.MAM, whichMAM = this$.wichMAM))
}

cellinfo  = function(model,cellnumbers=numeric())
  UseMethod("cellinfo")
cellinfo.Flow1D = function(this,cellnumbers=c())
{
  if(length(cellnumbers)==0)
  {
    cellnumbers = 1:(dim(this$cell)[1])
  }
  cat(paste("Flow1D sytem: ",this$name,"\n"))
  for(n in cellnumbers)
  {
    cat(paste(" info for cell ",n,"\n"))
    cat(paste("   center at",this$fn(this$cell[n,"x"]),"\n"))
    cat(paste("   cell area = ",this$fn(this$cell[n,"area"]),"\n"))
    for(i in which(this$intflux.list$fromnode==n))
    {
      cat(paste("     connected to cell",this$intflux.list[i,"tonode"],"by flux #",i,"\n"))
    }
    for(i in which(this$intflux.list$tonode==n))
    {
      cat(paste("     connected to cell",this$intflux.list[i,"fromnode"],"by flux #",i,"\n"))
    }
    if(!is.element(n,this$boundarycell$cellindex))
    {
      cat("     cell is not on boundary\n")
    }
    else
    {
      BCisset = FALSE
      for(f in this$fixedstate)
      {
        if(n==this$boundarycell$cellindex[f$BCindex])
        {
          cat(paste("     boundary state value fixed to ",f$value))
          BCisset = TRUE
        }
      }
      for(f in this$fixedflux)
      {
        if(n==this$boundarycell$cellindex[f$BCindex])
        {
          cat(paste("     boundary flux value fixed to ",f$value))
          BCisset = TRUE
        }        
      }
      for(f in this$stateflux)
      {
        if(n==this$boundarycell$cellindex[f$BCindex])
        {
          cat("     boundary flux value by state-function")
          BCisset = TRUE
        }        
      }
      if(!BCisset)
      {
        cat(paste("     zero-flux boundary"))
      }
    }
    for(fn in names(this$point.ext.flux))
    {
      if(this$point.ext.flux[[fn]]$cellindex==n)
      {
        cat("     point source/sinks: ")
        cat(fn)
        cat("\n")          
      }
    } 
    cat("\n")
  }
}

showbalance  = function(model,cellnumbers=numeric())
  UseMethod("showbalance")
showbalance.Flow1D = function(this,cellnumbers=c())
{
  .updateB(this)
  if(length(cellnumbers)==0)
  {
    cellnumbers = 1:this$NumNodes
  }
  cat(paste("\nFlow1D sytem: ",this$name,"\n"))
  headcellnumbers=head(cellnumbers)
  cat("balance for cell ")
  cat(headcellnumbers)
  if(length(headcellnumbers)<length(cellnumbers)) cat(" ... ")
  cat("\n\n")
  totinternalflux = 0
  for(cn in cellnumbers)
  {
    for(fid in which(this$intflux.list$tonode==cn))
    {
      c2n = this$intflux.list[fid,"fromnode"]
      if(max(cellnumbers==c2n)==0)
      {
        flux = calc.flux(this,fid)
        cat(paste("flow from node",c2n,"to node",cn,"(flux num=",fid,")=\t",this$fn(flux),"\n"))
        totinternalflux = totinternalflux + flux
      }
    }
    for(fid in which(this$intflux.list$fromnode==cn))    
    {
      c2n = this$intflux.list[fid,"tonode"]
      if(max(cellnumbers==c2n)==0)
      {
        flux = -calc.flux(this,fid)
        cat(paste("flow from node",c2n,"to node",cn,"(flux num=",fid,")=\t",this$fn(flux),"\n"))
        totinternalflux = totinternalflux + flux
      }
    }
  }
  cat(paste("                                               --------\n"))
  cat(paste("             netto internal flux =                 \t",this$fn(totinternalflux),"\n"))
  cat(paste("-------------------------------------------------------\n"))
  boundarycellnumbers = intersect(cellnumbers,this$boundarycell$cellindex)
  totboundaryflux = 0.0  
  
  for(i in boundarycellnumbers)
  {
    for(f in this$fixedstate)
    {
      cn = this$boundarycell$cellindex[f$BCindex]
      if(cn==i)
      {
        flux = f$freeflux
        cat(paste("free boundaryflux of node",cn," =                 \t",this$fn(flux),"\n"))        
        totboundaryflux = totboundaryflux + flux              
      }
    }
    for(f in this$fixedflux)
    {
      cn = this$boundarycell$cellindex[f$BCindex]
      if(cn==i)
      {
        flux = f$value 
        cat(paste("imposed fixed boundaryflux of node",cn," =                 \t",this$fn(flux),"\n"))        
        totboundaryflux = totboundaryflux + flux * this$boundarycell$nx[f$BCindex]                  
      }        
    }
    for(f in this$stateflux)
    {
      cn = this$boundarycell$cellindex[f$BCindex]
      if(cn==i)
      {
        flux = f$valuefunc(this$cell$state[cn])
        cat(paste("imposed state-flux of node",cn," =                 \t",this$fn(flux),"\n"))        
        totboundaryflux = totboundaryflux + flux * this$boundarycell$nx[f$BCindex]                  
      }        
    }      
  }
  if(length(boundarycellnumbers)>0)
  {
    cat(paste("                                               --------\n"))
    cat(paste("             netto boundary flux =                 \t",this$fn(totboundaryflux),"\n"))
    cat(paste("-------------------------------------------------------\n"))
  } 
  tot.ext.flux = 0.0
  ext.flux.found = FALSE
  for(nff in names(this$spat.ext.flux))
  {
    ext.flux.found = TRUE
    tot.spat.ext.flux = 0.0
    for(cn in cellnumbers)
    {
      flux = this$cell[cn,"area"] *
        this$spat.ext.flux[[nff]](this$cell[cn,"x"],this$cell[cn,"state"])
      tot.spat.ext.flux = tot.spat.ext.flux + flux
      tot.ext.flux = tot.ext.flux + flux
    }
    cat(paste("spat. ext. flux",nff," for cellinfo \t",this$fn(tot.spat.ext.flux),"\n"))
  }   
  for( fn in names(this$point.ext.flux))
  {
    cn = this$point.ext.flux[[fn]]$cellindex
    if(is.element(cn,cellnumbers))
    {
      ext.flux.found = TRUE
      f = this$point.ext.flux[[fn]]
      if(is.function(f$flux)){
        flux = f$flux(this$cell$state[cn])
      } else {
        flux = f$flux
      }
      cat(paste("point ext. flux",fn," for cell",cn,"\t",this$fn(flux),"\n"))
      tot.ext.flux = tot.ext.flux + flux      
    }
  }
  
  if(ext.flux.found)
  {
    cat(paste("-------------------------------------------------------\n"))
    cat(paste("             total external flux =              \t",this$fn(tot.ext.flux),"\n")) 
  }
  cat(paste("===================================================================\n"))
  cat(paste("              total balance misfit =               \t",this$fn(totinternalflux+tot.ext.flux+totboundaryflux),"\n\n"))
} 

solve.step = function(model,
                      controls=list(
                        difference.eps = 1.0e-5,
                        shrinkfactor = 0.95,
                        RMSMtolerance = +Inf,
                        MAMtolerance = +Inf))
  UseMethod("solve.step")
solve.step.Flow1D = function(this,
                             controls=list(
                               difference.eps = 1.0e-5,
                               shrinkfactor = 0.95,
                               RMSMtolerance = +Inf,
                               MAMtolerance = +Inf))
{
  wrongnames = setdiff(names(controls),
                       c("difference.eps","shrinkfactor",
                         "RMSMtolerance","MAMtolerance"))
  if(length(wrongnames)>0)
  {
    print("stopped the solver because the following bad names in controls:")
    print(wrongnames)
    return(NULL)
  }
  if(is.null(controls$difference.eps)) controls$difference.eps = 1.0e-5
  if(is.null(controls$shrinkfactor)) controls$shrinkfactor = 0.95
  if(is.null(controls$RMSMtolerance)) controls$RMSMtolerance = +Inf
  if(is.null(controls$MAMtolerance)) controls$MAMtolerance =+Inf
  if((controls$shrinkfactor >= 1)|| (controls$shrinkfactor < 0))
  {
    controls$shrinkfactor = 0.95
    warning("shrinkfactor reset to 0<0.95<1")
  } 
  N = this$NumNodes
  
  this$.s = this$cell$state
  
  .updateB(this)
  this$currentMAM = this$.MAM
  this$currentRMSM = this$.RMSM
  this$cell$B = this$.B
  
  .updatedBds(this,controls$difference.eps)
  
  dBdsInv = solve(this$.dBds)
  
  
  startRMSM = this$currentRMSM
  startMAM = this$currentMAM
  
  w = rep(1,N)
  Deltastate = -dBdsInv %*% (w*this$cell$B)

  # acceptability
  fstar  = rep(1,N)
  for(j in 1:N)
  {
    if(!this$is.acceptable(this$cell$x[j],this$cell$state[j]))
    {
      warning(paste("starting state at",this$cell$x[j],
                    "with value ",this$cell$state[j],"is not acceptable"))
      return(NULL)
    }
    while(!this$is.acceptable(this$cell$x[j],
                              this$cell$state[j]+fstar[j]*Deltastate[j]))
    {
      fstar[j] = fstar[j]*controls$shrinkfactor
    }
  }
  
  if(min(abs(this$cell$B))>1e-6)
  {
    w = -this$.dBds %*% (fstar * Deltastate) / this$cell$B 
    minw = min(w)
    
    if(minw < 0)
    {
      minfstar = min(fstar)
      lambda = minfstar/(minfstar-minw)
      w = lambda * w + (1-lambda) * minfstar
    }
  } else
  {
    minfstar = min(fstar)
    w = minfstar*w
  }
  Deltastate = -dBdsInv %*% (w*this$cell$B)

  
  this$.s = this$cell$state + Deltastate
  .updateB(this)
  
  newRMSM = this$.RMSM
  newMAM = this$.MAM
  newMSC = max(abs(Deltastate))
  J = which(newMAM>startMAM+controls$MAMtolerance)
  while((newRMSM>startRMSM+controls$RMSMtolerance)|(length(J)>0))
  {
    w = w * controls$shrinkfactor
    w[J] = w[J] * controls$shrinkfactor
    Deltastate = -dBdsInv %*% (w*this$cell$B)
    this$.s = this$cell$state + Deltastate
    .updateB(this)
    newRMSM = this$.RMSM
    newMAM = this$.MAM
    J = which(newMAM>startMAM+controls$MAMtolerance)
    newMSC =  max(abs(Deltastate))
    if(newMSC<controls$difference.eps)
    {
      warning("stopping solve.step because maxstatechange < difference.eps")
      break
    }
  }
  
  this$cell$state = this$.s
  this$cell$B = this$.B
  this$currentMAM = this$.MAM
  this$currentRMSM = this$.RMSM
  
  return(list(RMSM = newRMSM, MAM = newMAM, maxstatechange = newMSC))
}

plot.Flow1D = function(this,stateplot=TRUE,fluxplot=FALSE, addcellnumbers = FALSE)
{
  twoplot = FALSE
  if(stateplot&fluxplot) twoplot = TRUE
  if(twoplot)
  {
    old.par= par(no.readonly=TRUE)
    layout(matrix(c(1,2),nrow=2))
    par(mar=c(5,5,1,1))
  }
  if(stateplot)
  {
    plot(this$cell$x,this$cell$state,xlab="x",ylab="state",type="o",col=rgb(1,0,0),lwd=2)
    if(addcellnumbers)
    {
      text(this$cell$x,this$cell$state,labels=1:length(this$cell$x),pos=3,col="blue")
    }
  }
  if(fluxplot)
  {
    dff = data.frame.fluxes(this)
    plot(dff$x,dff$flux,xlab="x",ylab="int. flux (in x direction)",
         type="o",col=rgb(0,0,1),lwd=2)
    abline(h=0,col=rgb(0,0,1,0.5))
  }
  if(twoplot)
  {
    par(old.par)
  }
}
