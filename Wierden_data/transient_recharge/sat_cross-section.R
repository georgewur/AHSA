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
# may-june,2012 
#
######################################SATURATED ZONE######################################
################################SATURATED-FLOW-X-SECTION-MODEL######################################
# creating a resistance layer between deep and phreat aquifer
clay.x = c(0,10,1000,1001,5000)
clay.resistance=c(500,500,500,500,25)
resistance.fun =approxfun(clay.x,clay.resistance)

drainage.x =c(0,1250,1250.1)
drainage.C =c(250,250,1000000)
# drain.level=c(surface.fun(drainage.x[1])-0.80,
#               surface.fun(drainage.x[2])-0.80,
#               surface.fun(drainage.x[3])-0.80)
drain.level = function(x)
{
  surface.fun(x)-0.80
}
drain.resistance.fun = approxfun(drainage.x,drainage.C,rule=2)
drain.level.fun = approxfun(drainage.x,drain.level(drainage.x),rule=2)
drainage = function(x,state)
{
  if(state>drain.level.fun(x))
  {
    return(-(state-drain.level.fun(x))/drain.resistance.fun(x))
  }else{
    return(0.0)
  }
}



phreat.flux = function(x,state,gradstate)
{
  k=15 #m/d
  if (state < surface.fun(x))
    return(-k*state*gradstate)
  else
    return(-k*surface.fun(x)*gradstate)
}

deep.flux = function(x,state,gradstate)
{
  kD=275 #transmissivity deep aquiferm2/d
  return(-kD*gradstate)
}

# recharge.fun = approxfun(c(sat.domain[1],sat.domain[2]),c(0.001,0.001))
# 
# recharge = function(x,state) 
# {
#   return(recharge.fun(x))#using just a value to get saturated models running
# }
recharge = function(x,state) 
{
  return(0.001)#using just a value to get saturated models running
}


initialisation = function(sat.nodes)
{
  return(surface.fun(sat.nodes)-1) #1m below surface
}

#exchange flux from deep aquifer to phreat aquifer
deep2phreat = function(x,state)
{
  return((deep.ss.fun(x)-state)/resistance.fun(x))
}

#exchange flux from phreat aquifer to deep aquifer
phreat2deep = function(x,state)
{
  return((phreat.ss.fun(x)-state)/resistance.fun(x))
}

Qsto.phreat = function(x,state)
{
  -Scoef.fun(x)*(state - ps.phreat(x))/delt
}

Qsto.deep = function(x,state)
{
  -0.0001*(state - ps.deep(x))/delt
}

Qseepage.sat = function(x,state) #for upper nodes only!!
{
  if(state > surface.fun(x))
  {
    q.top = (state - surface.fun(x))/surf.resit
    return(q.top)
  }else{
    return(0.0)
  }
}
