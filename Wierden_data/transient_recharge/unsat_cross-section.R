# Cross sectional model at regional scale simulating saturated and unsaturated groundwater flow
# x-dimension in the order of km
# z-dimension in the order of 10ths of meters
# two 1.5D saturated groundwater models with partial aquitard in between
# several (4-6) unsaturated models (vetical)
# BC's saturated models: Waterdivide at high end (ice pushed ridge), prescribed river head/drainage system
# BC's unsaturated models: surface:precipitation,watertable:psi=0.
# If no unsaturated zone exist; Cauchy: surface-level, vertical resistance
# domain unsat.models depend on head upper sat.model
# hydr.prop. unsat.models based on van Genuchten, possibly rootfunction included
# G. Bier                                                                    
# june,2012 


#rm(list=ls())
# load previously generated data e.g. k.fun,theta.fun and c.fun 
load(file='soilset.Rdata')

##########################GENERAL UNSAT FUNCTIONS##########################################
#generate root uptake reduction function
# Here we are assuming just one crop 'pasture'for all models
h.wet = -15
h.moist = -25
h.dry = -800
h.wilt = -8000

# Feddes funtion
Epot.reduction = approxfun(c(h.wilt,h.dry,h.moist,h.wet),c(0,1,1,0),rule=2)

# initialize psi (h) with -Z
psi.init=function(z,state)
{
  state=-z
  return(state)
}

#in the unsat zone pressures are all negative
psi.OK =function(z,state)
{
  if (state>(-18000)&(state<=10000)) 
  {
    return(TRUE)
  }else{
    return(FALSE) 
  }  
}


##########################GENERAL UNSAT FUNCTIONS##########################################

#########################SET UP UNSAT MODELS##############################################
#First a basic list of, in this case, 3 models
uns.models = list(uns1=list(domain=NULL,
                            nodes=NULL,
                            prevstate=NULL,
                            top.amsl=NULL,
                            bottom.amsl=NULL,
                            root.uptake=NULL,
                            x.coord=500),
                  uns2=list(domain=NULL,
                            nodes=NULL,
                            prevstate=NULL,
                            top.amsl=NULL,
                            bottom.amsl=NULL,
                            root.uptake=NULL,
                            x.coord=1400),
                  uns3=list(domain=NULL,
                            nodes=NULL,
                            prevstate=NULL,
                            top.amsl=NULL,
                            bottom.amsl=NULL,
                            root.uptake=NULL,
                            x.coord=2500)
                  )# end of list

#First a basic list of, in this case, 3 models
##############root.uptake functions
uns.models$uns1$root.uptake = function(z,state)
{
  depth = 100*(uns.models$uns1$top.amsl-uns.models$uns1$bottom.amsl)-z
#  cat(paste(' depth',depth,'z ',z,'surface',surface.fun(uns.models$uns1$x.coord),"\n"))
  if (depth<20) 
  {
    
    return(Epot.reduction(state)*0.4*-Epot/20)
  }else{
    if (depth<40)
    {
      return(Epot.reduction(state)*0.3*-Epot/20)
    }else{
      if (depth<60)
      {
        return(Epot.reduction(state)*0.2*-Epot/20)
      }else{
        if (depth<=80)
        {
          return(Epot.reduction(state)*0.1*-Epot/20)
        }else{
          return(0)
        }
      }
    }
  }
}

uns.models$uns2$root.uptake = function(z,state)
{
  depth = 100*(uns.models$uns2$top.amsl-uns.models$uns2$bottom.amsl)-z
  #    cat(paste(' depth',depth,'z ',z,'surface',surface.fun(uns.models$uns1$x.coord),"\n"))
  if (depth<20) 
  {
    
    return(Epot.reduction(state)*0.4*-Epot/20)
  }else{
    if (depth<40)
    {
      return(Epot.reduction(state)*0.3*-Epot/20)
    }else{
      if (depth<60)
      {
        return(Epot.reduction(state)*0.2*-Epot/20)
      }else{
        if (depth<=80)
        {
          return(Epot.reduction(state)*0.1*-Epot/20)
        }else{
          return(0)
        }
      }
    }
  }
}

uns.models$uns3$root.uptake = function(z,state)
{
  depth = 100*(uns.models$uns3$top.amsl-uns.models$uns3$bottom.amsl)-z
 #   cat(paste(' depth',depth,'z ',z,'surface',surface.fun(uns.models$uns1$x.coord),"\n"))
  if (depth<20) 
  {
    
    return(Epot.reduction(state)*0.4*-Epot/20)
  }else{
    if (depth<40)
    {
      return(Epot.reduction(state)*0.3*-Epot/20)
    }else{
      if (depth<60)
      {
        return(Epot.reduction(state)*0.2*-Epot/20)
      }else{
        if (depth<=80)
        {
          return(Epot.reduction(state)*0.1*-Epot/20)
        }else{
          return(0)
        }
      }
    }
  }
}

make.unsat.model.stat = function(currentmodel,currentsoil)
{
  uns.models[[currentmodel]]$top.amsl <<- surface.fun(uns.models[[currentmodel]]$x.coord)
  if (phreat.ss.fun(uns.models[[currentmodel]]$x.coord)>=
    surface.fun(uns.models[[currentmodel]]$x.coord))
  {
    uns.models[[currentmodel]]$domain <<- c(0,1.0*100)# just 1 m (=100cm) of unsat.soil
    uns.models[[currentmodel]]$bottom.amsl <<- 
      surface.fun(uns.models[[currentmodel]]$x.coord)-uns.models[[currentmodel]]$domain[2]/100
    cat(paste('artesion conditions, bottom model set to:',
              uns.models[[currentmodel]]$bottom.amsl,"\n", 'in m AMSL'))
  }else{
    atwatertable = 0
    atsurface = (surface.fun(uns.models[[currentmodel]]$x.coord)-
                 phreat.ss.fun(uns.models[[currentmodel]]$x.coord)+depth.below.table)*100
    uns.models[[currentmodel]]$domain <<- c(atwatertable,atsurface)
#     uns.models[[currentmodel]]$domain <<- c(0,(surface.fun(uns.models[[currentmodel]]$x.coord)-
#       phreat.ss.fun(uns.models[[currentmodel]]$x.coord)+depth.below.table)*100)
    uns.models[[currentmodel]]$bottom.amsl <<- phreat.ss.fun(uns.models[[currentmodel]]$x.coord)-
      depth.below.table
    cat(paste('phreatic conditions, bottom models set:',
              uns.models[[currentmodel]]$bottom.amsl),"\n")
  }
  uns.models[[currentmodel]]$prevstate <<- psi.init #to have some first values
  uns.models[[currentmodel]]$nodes <<- seq(uns.models[[currentmodel]]$domain[1],
                                           uns.models[[currentmodel]]$domain[2],length=50)
  cat(paste('model :',currentmodel,'soil :',currentsoil,"\n"))
  cat(paste('domain :',uns.models[[currentmodel]]$domain,"\n"))
#  cat(paste('nodes :',uns.models[[currentmodel]]$nodes))
  return(newFlow1D(uns.models[[currentmodel]]$domain,
                   uns.models[[currentmodel]]$nodes,
                   stateinit = uns.models[[currentmodel]]$prevstate,
                   int.flux = soil.set[[currentsoil]]$Richards.flux,
                   spat.ext.flux = uns.models[[currentmodel]]$root.uptake,
                   is.acceptable = psi.OK,
                   HNLSoption=T))
  
  
}
# 21/8/12 put storage calculation in gnrl_cross_section.R
# calculating phreatic storage coefficient from unsat models
# for now (11/7/12) use theta.sat - mean.theta model
# s.uns1 = soil.set$B1$theta.sat - mean(soil.set$B1$theta.fun(uns.models$uns1$cell$state))
# s.uns2 = soil.set$B8$theta.sat - mean(soil.set$B1$theta.fun(uns.models$uns2$cell$state))
# s.uns3 = soil.set$B5$theta.sat - mean(soil.set$B1$theta.fun(uns.models$uns3$cell$state))
# Scoef.fun = approxfun(c(uns.models$uns1$x.coord,uns.models$uns2$x.coord,uns.models$uns3$x.coord),
#                       c(s.uns1,s.uns2,s.uns3),rule=2)
# calculating phreatic storage coefficient from unsat models

# Qsto.uns = function(x,state)
# {
#   (soil.set[[currentsoil]]$theta.fun(state) - soil.set[[currentsoil]]$theta.fun(prevstate))/delt
# }


make.unsat.model.trans = function(currentmodel,currentsoil,currentstorage,currentname)
{
  uns.trans.models[[currentmodel]]$top.amsl <<- surface.fun(uns.trans.models[[currentmodel]]$x.coord)
  if (phreat.ss.fun(uns.trans.models[[currentmodel]]$x.coord)>=
    surface.fun(uns.trans.models[[currentmodel]]$x.coord))
  {
    uns.trans.models[[currentmodel]]$domain <<- c(0,1.0*100)# just 1 m. of unsat.soil
    uns.trans.models[[currentmodel]]$bottom.amsl <<- 
      surface.fun(uns.trans.models[[currentmodel]]$x.coord)-uns.trans.models[[currentmodel]]$domain[2]/100
    cat(paste('artesion conditions, bottom models set:',
              uns.trans.models[[currentmodel]]$bottom.amsl,"\n"))
  }else{
    atwatertable = 0
    atsurface = (surface.fun(uns.trans.models[[currentmodel]]$x.coord)-
      phreat.ss.fun(uns.trans.models[[currentmodel]]$x.coord)+depth.below.table)*100
    uns.trans.models[[currentmodel]]$domain <<- c(atwatertable,atsurface)
    #     uns.models[[currentmodel]]$domain <<- c(0,(surface.fun(uns.models[[currentmodel]]$x.coord)-
    #       phreat.ss.fun(uns.models[[currentmodel]]$x.coord)+depth.below.table)*100)
    uns.trans.models[[currentmodel]]$bottom.amsl <<- phreat.ss.fun(uns.trans.models[[currentmodel]]$x.coord)-
      depth.below.table
    cat(paste('phreatic conditions, bottom models set:',
              uns.trans.models[[currentmodel]]$bottom.amsl),"\n")
  }
#  uns.trans.models[[currentmodel]]$prevstate <<- psi.init #to have some first values
  uns.trans.models[[currentmodel]]$nodes <<- seq(uns.trans.models[[currentmodel]]$domain[1],
                                           uns.trans.models[[currentmodel]]$domain[2],length=50)
  cat(paste('model :',currentmodel,'soil :',currentsoil,"\n"))
  cat(paste('domain :',uns.trans.models[[currentmodel]]$domain,"\n"))
  #  cat(paste('nodes :',uns.models[[currentmodel]]$nodes))
  
  
  
  return(newFlow1D(uns.trans.models[[currentmodel]]$domain,
                   uns.trans.models[[currentmodel]]$nodes,
            #       stateinit = uns.trans.models[[currentmodel]]$prevstate,
                   stateinit = prev.state.list[[currentname]],
                   int.flux = soil.set[[currentsoil]]$Richards.flux,
                   spat.ext.flux = list(Qroot=uns.trans.models[[currentmodel]]$root.uptake,
                                        Qsto=currentstorage),
                   is.acceptable = psi.OK,
                   HNLSoption=T))
  
  
}



#########################SET UP UNSAT MODELS##############################################
# un1 =newFlow1D(domain=c(0,100),nodes=seq(1,10,by=1),
#                stateinit = psi.init,
#                int.flux = soil.set$B1$Richards.flux)
# 
# set.BC.left.fixedstate(un1,2)
# solve.step(un1)