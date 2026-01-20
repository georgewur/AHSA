###############################SLM32806 Ecohydrology practical lecture 1###################################
###############################                        nov. 2013 G. Bier###################################
# Cross sectional model at regional scale simulating saturated and unsaturated groundwater flow
# x-dimension in the order of km
# z-dimension in the order of 10ths of meters
# two 1.5D saturated groundwater models with partial aquitard in between
# several (3) unsaturated models (vetical)
# BC's saturated models: East Waterdivide at high end (ice pushed ridge), West prescribed river head/drainage system
# BC's unsaturated models: surface:precipitation,watertable:psi=0.
# If no unsaturated zone exist; Cauchy: surface-level, vertical resistance
# domain unsat.models depend on head upper sat.model
# hydr.prop. unsat.models based on van Genuchten, rootfunction included
##############################################################################
#
#
rm(list=ls())
set.seed(123)# due to older flow1D version
begin.run = proc.time() # to keep track how long it runs.
##creating surface function with a sigmoid function
minx = -2000
maxx = 2000
x.sigmoid = seq(minx,maxx,100)
x.coord.sigmoid= x.sigmoid+2000
top = 45
bottom =25.5
growth =0.0025
sigmoid = bottom + (top-bottom)/(1+exp(-growth*x.sigmoid))
# plot(x^0.99, type='l')
plot(x.coord.sigmoid,sigmoid, type='l')
grid()
surface.fun = approxfun(x.coord.sigmoid,sigmoid,method='linear',rule=2:2)
# creating surface function with a sigmoid function
#
source('unsat_cross-section.R')
source('sat_cross-section.R')
#library(FVFE1D) quite a few function are implemented differently now
source('flow1D_16_10_12.R') 
##################################SAT MODELS######################################

####################################SET UP SATURATED DOMAIN AND MODELS#####################
x.section.domain=maxx - minx
sat.domain=c(0,x.section.domain)
sat.nodes=seq(from=sat.domain[1],to=sat.domain[2],length=50)
#MODEL AND BC FOR PHREAT MODEL
sat.phreat = newFlow1D(sat.domain,
                       sat.nodes,
                       int.flux = phreat.flux,     ##here you have your Darcy
                       spat.ext.flux = list(rch=recharge,
                                            exchange=deep2phreat,
                                            drn=drainage),  ##here the spatial external flux is our recharge
                       stateinit=initialisation) ## here the new arguement to have proper initial states in the model

set.BC.left.fixedstate(sat.phreat,surface.fun(0)-1.75)
#MODEL AND BC FOR PHREAT MODEL
#MODEL FOR DEEP MODEL NO BC
sat.deep = newFlow1D(sat.domain,sat.nodes,
                     int.flux=deep.flux,
                     spat.ext.flux = phreat2deep,
                     stateinit=initialisation)
#MODEL FOR DEEP MODEL NO BC
##################################SAT MODELS######################################
#
#
######################################FIRST SOLVE SATURATED MODELS#########################
#
# the very first states of deep aquifer for calc exchange with phreatic aquifer
deep.ss.fun=approxfun(sat.nodes,surface.fun(sat.nodes)) 
# also the very first 'previous states need to be known for first run

#temp
# save(sat.phreat,sat.deep,phreat.state.fun,deep.state.fun,file="modeldata.Rdat")
# load(file="modeldata.Rdat")
#temp
maxit=500 #max amount of iterations
for (i in 1:maxit)
{
  solve.step(sat.phreat,controls=list(MAMtolerance = 5))
  phreat.ss.fun = approxfun(sat.nodes,sat.phreat$cell$state)
  solve.step(sat.deep)
  deep.ss.fun = approxfun(sat.nodes,sat.deep$cell$state)
  control.phreat = current.misfit.stats(sat.phreat)$MAM
  control.deep   = current.misfit.stats(sat.deep)$MAM
  cat(paste("calcuted step",i,"\n"))
  cat(paste(' misfit balance deep',control.deep,"\n"))
  cat(paste(' misfit balance phreat',control.phreat,"\n"))
  
  if ((control.phreat < 0.001) & (control.deep <0.001)) break
}
if(i>maxit) cat(paste("MODEL IS NOT CONVERGED!!!!!!"))

plot(sat.nodes,surface.fun(sat.nodes),type='l',col='green')
lines(sat.nodes,phreat.ss.fun(sat.nodes),col='red')
lines(sat.nodes,deep.ss.fun(sat.nodes),col='blue')
grid()

#############temp 18-10-12##################################
# showbalance(sat.phreat)
# showbalance(sat.deep)
# dfc.phreat = data.frame.cells(sat.phreat)
# plot(sat.nodes,dfc.phreat$exchange,type='l')
# seepage = sum(dfc.phreat$exchange[which(dfc.phreat$exchange<0)])
# infiltration =sum(dfc.phreat$exchange[which(dfc.phreat$exchange>=0)])
# set previous states ps for transient modeling
#############temp 18-10-12##################################
ps.phreat = phreat.ss.fun
ps.deep = deep.ss.fun
# set previous states ps for transient modeling
########################################LOAD METEO DATA####################################
# meteo = read.table(file='debilt1990.dat',header=T)
#meteo = read.table(file='85-95.dat',header=T)
meteo = read.table(file = "meteo_2017_2024_processed.txt",header=T)
ppn.stat = mean(meteo$Precipitation_mm_d)#*0.1 #cm/d
#testing 23-8-12 with lower ppn.stat
ppn.stat = 0.08  #0.8 mm/d as an average recharge
eref.stat= mean(meteo$Evaporation_mm_d)#*0.1 #cm/d
Epot = 0  #temp 21/8/12 voor stationair modellen nog geen rootuptake
# rech.stat = -(ppn.stat - eref.stat)
########################################LOAD METEO DATA####################################
######################################FIRST SOLVE SATURATED MODELS#########################
##################################UNSAT STAT MODELS######################################
#for vertical discretisation unsaturated zone thickness starts at or below groundwater table.
#in case of a prescribed head at the bottom of the unsaturated zone 2m below groundwater table
#is bottom (here left) of the unsat. domain
#Surface is the top (here right) of the unsat.domain
#   depth 2m below groundwater table =0.0 cm!
#   depth at surface level is maxdepth in cm!
#   depth has a positive value
#
# for root.uptake function root system starts at surface
depth.below.table = 2; #   
#check with conditino below wheather artesian conditions occur. If so, thickness unsat zone is set to 1.0 m below surface



## 11/7/12  maak lijsten van modellen!! for opzetten en loops ed
# model.list = list()
# model.list[["uns1"]] = make.unsat.mode.stat('uns1')....
uns1=make.unsat.model.stat('uns1','B1')
set.BC.left.fixedstate(uns1,phreat.ss.fun(uns.models$uns1$x.coord))
set.BC.right.fixedflux(uns1,-ppn.stat)

uns2=make.unsat.model.stat('uns2','B8')
set.BC.left.fixedstate(uns2,phreat.ss.fun(uns.models$uns2$x.coord))
set.BC.right.fixedflux(uns2,-ppn.stat)

uns3=make.unsat.model.stat('uns3','B5')
set.BC.left.fixedstate(uns3,phreat.ss.fun(uns.models$uns3$x.coord))
set.BC.right.fixedflux(uns3,-ppn.stat)

recharge=c() # to start with an empty vector for the calculated recharge below the uns models

 uns.stat.models.list = list(links=uns1,midden=uns2,rechts=uns3)# listname=globalname
# for (modnr in uns.stat.models.list)
#   for (modnr in names(uns.models))  THIS DOES NOT work since names in uns.model is only a set of characters...'uns1','uns2'etc
X11(xpos=100)
   for(naam in c("links","midden","rechts"))
{
 curmodel = uns.stat.models.list[[naam]]    
  for (i in 1:100)
  {
    solve.step(curmodel,controls=list(MAMtolerance=3))#,RMSMtolerance=0.5))
    plot(curmodel,flux=T)
    err = current.misfit.stats(curmodel)$MAM
    cat(paste("for model",naam,"calcuted step",i,' misfit :',err,"\n"))
    if (err <0.0005) break
  }
#  tmpdf = data.frame.cells(curmodel) #use data to retrieve misfit=recharge at bottom of model
#   recharge = c(recharge,tmpdf$misfit[1]) #use data to retrieve misfit=recharge at bottom of model
 recharge = c(recharge,curmodel$fixedstate[[1]]$freeflux)
}
dev.off()
approx.recharge = approxfun(c(uns.models$uns1$x.coord,uns.models$uns2$x.coord,uns.models$uns3$x.coord),
                            recharge,rule=2:2)
recharge.fun = function(x,state)
{
  return(approx.recharge(x))
}  
# calculating phreatic storage coefficient from unsat models
# for now (21/8/12) use theta.sat - mean.theta model
s.uns1 = soil.set$B1$theta.sat - mean(soil.set$B1$theta.fun(uns1$cell$state))
s.uns2 = soil.set$B8$theta.sat - mean(soil.set$B8$theta.fun(uns2$cell$state))
s.uns3 = soil.set$B5$theta.sat - mean(soil.set$B5$theta.fun(uns3$cell$state))
Scoef.fun = approxfun(c(uns.models$uns1$x.coord,uns.models$uns2$x.coord,uns.models$uns3$x.coord),
                      c(s.uns1,s.uns2,s.uns3),rule=2)
# calculating phreatic storage coefficient from unsat models

 

##################################UNSAT STAT MODELS######################################

##################################TRANSIENT LOOP OVER MODELS#############################
# make transient models first; including storage as additional external flux
sat.phreat.trans = newFlow1D(sat.domain,
                             sat.nodes,
                             int.flux = phreat.flux,     
                             spat.ext.flux = list(rch=recharge.fun,
                                                  exchange=deep2phreat,
                                                  drn=drainage,
                                                  sto=Qsto.phreat),  
                             stateinit=phreat.ss.fun) 

set.BC.left.fixedstate(sat.phreat.trans,surface.fun(0)-1.75)
#MODEL AND BC FOR PHREAT MODEL
#MODEL FOR DEEP MODEL NO BC
sat.deep.trans = newFlow1D(sat.domain,sat.nodes,
                           int.flux=deep.flux,
                           spat.ext.flux = list(exchange=phreat2deep,
                                          sto=Qsto.deep),
                           stateinit=deep.ss.fun)
#MODEL FOR DEEP MODEL NO BC
# make transient models first; including storage as additional external flux
# set previous states ps for transient modeling
ps.uns1 = approxfun(uns1$cell$x,uns1$cell$state,rule=2)
ps.uns2 = approxfun(uns2$cell$x,uns2$cell$state,rule=2)
ps.uns3 = approxfun(uns3$cell$x,uns3$cell$state,rule=2)
# set previous states ps for transient modeling
# put these previous states in a list for transient modeling
prev.state.list = list(left=ps.uns1,middle=ps.uns2,right=ps.uns3)
# put these previous states in a list for transient modeling
Qsto.uns1 = function(x,state)
{
  -(soil.set$B1$theta.fun(state) - soil.set$B1$theta.fun(prevstate(x)))/delt
}
Qsto.uns2 = function(x,state)
{
  -(soil.set$B8$theta.fun(state) - soil.set$B8$theta.fun(prevstate(x)))/delt
}
Qsto.uns3 = function(x,state)
{
  -(soil.set$B5$theta.fun(state) - soil.set$B5$theta.fun(prevstate(x)))/delt
}
Qsto.uns.list = list(left=Qsto.uns1,middle=Qsto.uns2,right=Qsto.uns3)

uns.trans.models = uns.models
uns1.trans=make.unsat.model.trans('uns1','B1',Qsto.uns1,'left')
set.BC.left.fixedstate(uns1.trans,phreat.ss.fun(uns.trans.models$uns1$x.coord))

uns2.trans=make.unsat.model.trans('uns2','B8',Qsto.uns2,'middle')
set.BC.left.fixedstate(uns2.trans,phreat.ss.fun(uns.trans.models$uns2$x.coord))

uns3.trans=make.unsat.model.trans('uns3','B5',Qsto.uns3,'right')
set.BC.left.fixedstate(uns3.trans,phreat.ss.fun(uns.trans.models$uns3$x.coord))

uns.trans.models.list = list(left=uns1.trans,middle=uns2.trans,right=uns3.trans)


# make transient models first; including storage as additional external flux
# creating meteorological functions
# days = seq(1,365,by=1)
days = seq(1,length(meteo$Precipitation_mm_d),by=1)
ppn.fun = approxfun(days,meteo$Precipitation_mm_d*0.1,rule=2)# in cm/day BUT in +/+
eref.fun = approxfun(days,meteo$Evaporation_mm_d*0.1,rule=2)
# creating meteorological functions
# using steady state phreatic head now for first transient head for BC's uns.trans models
phreat.trans.fun = phreat.ss.fun
# using steady state phreatic head now for first transient head for BC's uns.trans models

results=c() #create an emtpy table/matrix to put results into

delt = 1 #1/2 #day dd 17-12-25 no idea why I set delt to 0.5 day here
#begintime = 731                    #starttime simulation
#endtime = begintime + 730                     #endtime simulation
##15-12-25, GEEN IDEE waarom hier vanaf dag 731 (2jaar??) begonnen wordt
begintime = 1 
endtime = length(days)
#starttime simulation
time = begintime
X11(xpos=100)
while (time < endtime)
{
  ppn.trans = -ppn.fun(time) #here negative since z is positive upwards
  eref.trans= eref.fun(time)
  Epot = eref.trans
  recharge = c() # reset this vector to NULL to fill with new values
  # set BC's for unsat trans models  
  set.BC.right.fixedflux(uns1.trans,ppn.trans)
  set.BC.right.fixedflux(uns2.trans,ppn.trans)
  set.BC.right.fixedflux(uns3.trans,ppn.trans)
  set.BC.left.fixedstate(uns1.trans,phreat.trans.fun(uns.models$uns1$x.coord))
  set.BC.left.fixedstate(uns2.trans,phreat.trans.fun(uns.models$uns2$x.coord))
  set.BC.left.fixedstate(uns3.trans,phreat.trans.fun(uns.models$uns3$x.coord))
  unsat.results =c() #to write intermediate results
  for (name in c('left','middle','right'))
  {
    cur.model = uns.trans.models.list[[name]]
    cur.prev.stat = prev.state.list[[name]]
    prevstate = cur.prev.stat
    
    for (i in 1:100)
    {
      solve.step(cur.model,controls=list(MAMtolerance=3))
      control = current.misfit.stats(cur.model)$MAM
 #     plot(cur.model, flux=T)
      cat(paste('curmodel',name,"calcuted step",i,' misfits :',control,"\n"))
      if (control < 0.001)  break
      }
   
    prev.state.list[[name]] = approxfun(cur.model$cell$x,cur.model$cell$state) #put current state here for next time step to calculate storagechange
     tmpdf = data.frame.cells(cur.model) #to extract data from unsat models
    recharge = c(recharge,-0.01*cur.model$fixedstate[[1]]$freeflux) #undocumented function for getting recharge
    #recharge: unit in unsat is cm/d unit in sat is m/d so transform by 1/100 cm-> m
    unsat.results = rbind(unsat.results,c(sum(tmpdf$Qroot), #root extraction
                                          sum(tmpdf$Qsto), #storage
                                          cur.model$fixedstate[[1]]$freeflux, #recharge to phreat
                                          tmpdf$state[1])) #head at this location
  }#for loop over names
  
  approx.recharge = approxfun(c(uns.models$uns1$x.coord,uns.models$uns2$x.coord,uns.models$uns3$x.coord),
                              recharge,rule=2:2)
  recharge.fun = function(x,state)
  {
    return(approx.recharge(x))
  }  

  # calculating phreatic storage coefficient from unsat models
  # for now (21/8/12) use theta.sat - mean.theta model
  s.uns1 = soil.set$B1$theta.sat - mean(soil.set$B1$theta.fun(uns1.trans$cell$state))
  s.uns2 = soil.set$B8$theta.sat - mean(soil.set$B8$theta.fun(uns2.trans$cell$state))
  s.uns3 = soil.set$B5$theta.sat - mean(soil.set$B5$theta.fun(uns3.trans$cell$state))
  Scoef.fun = approxfun(c(uns.models$uns1$x.coord,uns.models$uns2$x.coord,uns.models$uns3$x.coord),
                        c(s.uns1,s.uns2,s.uns3),rule=2)
 #run the sat.trans.models
  maxit=500 #max amount of iterations
  sat.results = c() #to write intermediate result sat. model
  for (i in 1:maxit)
  {
    #   solve.step.new(sat.phreat)
    solve.step(sat.phreat.trans)
    phreat.ss.fun = approxfun(sat.phreat.trans$cell$x,sat.phreat.trans$cell$state)
    #   solve.step.new(sat.deep)
    solve.step(sat.deep.trans)
    deep.ss.fun = approxfun(sat.deep.trans$cell$x,sat.deep.trans$cell$state)
    control.phreat = current.misfit.stats(sat.phreat.trans)$MAM
    control.deep   = current.misfit.stats(sat.deep.trans)$MAM
    cat(paste("calcuted step",i,'time :',time,"\n"))
    cat(paste(' misfit balance deep',control.deep,"\n"))
    cat(paste(' misfit balance phreat',control.phreat,"\n"))
    
    if ((control.phreat < 0.001) & (control.deep <0.001)) break
  }
  if(i>maxit) cat(paste("MODEL IS NOT CONVERGED!!!!!!"))
  sat.dafr = data.frame.cells(sat.phreat.trans)
#   sat.results= rbind(sat.results,c(sum(sat.dafr$exchange),sum(sat.dafr$drn),
#                                    sum(dafr$rch),sum(dafr$sto),dafr$misfit[1]))
  results = rbind(results,c(time,ppn.fun(time),eref.fun(time),
                            unsat.results[1,],unsat.results[2,],unsat.results[3,],
                            sum(abs(sat.dafr$exchange))/2,sum(sat.dafr$drn),
                            sum(sat.dafr$rch),sum(sat.dafr$sto),sat.phreat.trans$fixedstate[[1]]$freeflux))
  #set current states to ps.phreat and ps.deep to calculate storagechange for next timestep
  ps.phreat = approxfun(sat.phreat.trans$cell$x,sat.phreat.trans$cell$state)
  phreat.trans.fun = ps.phreat #this is to have proper fixed head BC for unsatmodels
  ps.deep = approxfun(sat.deep.trans$cell$x,sat.deep.trans$cell$state)
  #set current states to ps.phreat and ps.deep to calculate storagechange for next timestep
  
  
  #################################plotting#########################################
  old.par=par(no.readonly=TRUE)
  layout(matrix(c(1,1,1,2,3,4,5,5,5),ncol=3,byrow=T))
  #first plot on top
  plot(days,ppn.fun(days),col='blue',type='l')
  lines(days,eref.fun(days),col= 'red')
  abline(v=time)
  grid()
  #first plot on top
  #3 plots middel unsat models
  plot(uns1.trans$cell$state,uns1.trans$cell$x,col='red',type='b')
  
  grid()
  plot(uns2.trans$cell$state,uns2.trans$cell$x,col='red',type='b')
  grid()
  plot(uns3.trans$cell$state,uns3.trans$cell$x,col='red',type='b')
  grid()
  #3 plots middel unsat models
  #bottom plot containing surface level, h-phreat, h-deep
  plot(sat.nodes,surface.fun(sat.nodes),type='l',col='green')
  lines(sat.nodes,phreat.ss.fun(sat.nodes),col='red')
  lines(sat.nodes,deep.ss.fun(sat.nodes),col='blue')
  grid()
  #bottom plot containing surface level, h-phreat, h-deep
  #reset plot parameters
  par(old.par)
  #reset plot parameters
  #################################plotting#########################################
  time = time + delt

}#while (time) loop

results = data.frame(results)

names(results)=c('time','ppn cm/d','eref cm/d','uns1.Qroot','uns1.Qsto','uns1.Rch','uns1.State',
                 'uns2.Qroot','uns2.Qsto','uns2.Rch','uns2.State',
                 'uns3.Qroot','uns3.Qsto','uns3.Rch','uns3.state',
                 'Qsat.inf/seepg','Qsat.drainage','Qsat.recharge',
                 'Qsat.storage','Qsat.BC')
write.csv(file='results.csv',results)
dev.off()
cat(paste('begin simulation :',begin.run[3]))
cat(paste('begin simulation :',proc.time()[3]))
run.time = begin.run[3]-proc.time()[3]
cat(paste('total simulation time in sec:',run.time,'in minutes :',run.time/60,'in hours :',run.time/3600))


####aggregate recharge on ten daily basis by copilot..
# results$time = as.integer(results$time)
# results.ten.day = aggregate(results[,2:20],by=list(rep(1:ceiling(nrow(results)/10),each=10,length.out=nrow(results))),FUN=mean)
# names(results.ten.day)[1]='period'
# write.csv(file='results_ten_day.csv',results.ten.day)

##by chat
results$decade = ceiling(results$time / 10)
results.ten.day = aggregate(results[,2:20], by=list(results$decade), FUN=mean)
names(results.ten.day)[1] = 'decade'
write.csv(file='results_ten_day.csv',results.ten.day)


##################################TRANSIENT LOOP OVER MODELS#############################

####creating xyz files for GMS
#according to chatgpt the following should replace date numbers to actual dates
#first create dates from decade numbers
#to be on the save side copy the results.ten.day to results_test
results_test = results.ten.day
results_test$datum <- as.Date("2017-01-01") + (results_test$decade - 1) * 10 + 4
#then format the dates to "YYYYMMDD"
results_test$datum <- format(results_test$datum, "%d/%m/%Y")
##exporting them into XYS format

ppn_results <- data.frame(
  datum  = results_test[[21]],
  precip = results_test[[2]] * 0.1
)
ppn_results$datum = paste(ppn_results$datum, "00:00:00")
#ppn_results = data.frame(datum = results_test$datum, 
#                         precip =results_test$`ppn.cm.d` * 0.1)
header_file = paste("XYS 1 ",length(ppn_results[,1]), "Precipitation_m_d")
cat("XYS 1 ",header_file, "\n", file = "precipitation_2017_2024.xys")
write.table(ppn_results, file = "precipitation_2017_2024.xys",append = TRUE,row.names = FALSE, col.names = FALSE, quote = TRUE)
