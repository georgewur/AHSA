#Testing for a model with a deep groundwater table
#having a free drainage boundary condition at the bottom
#d_psi/dz = 0
soiltype = soil.set$B5#B1

print(unlist(soiltype))

## domain of the model
top = 0.0  # at the surface
bottom = -500# 8 meters below surface

#log_top = log10(0.1)
# log_top = log10(0.1)
# log_bottom = log10(-bottom)
# log_z = seq(from = log_top, to = log_bottom,by = 0.1)
# nodes = -10^log_z
# nodes = c(0.0,nodes)
# nodes
# diff(nodes)
# 
# top = 0.0
# bottom_roots = -200.0
# upper_nodes = seq(from = top, to = bottom_roots, by = -1)
# log_top_roots = log10(-bottom_roots + 1)
# log_bottom = log10(-bottom)
# log_z_lower_nodes = seq(from = log_top_roots, to = log_bottom, by = 0.025)
# lower_nodes = -10^log_z_lower_nodes
# nodes = c(upper_nodes,lower_nodes)

nodes = seq(top,bottom, by = -1)
domain=c(bottom,top)


###description of the internal flux##############
unsatdarcy.flux = function(z,psi,dpsidz)
{
  return(-soiltype$k.fun(psi)*(dpsidz+1))
}

################### make the model #################
UnsatStat = newFLOW1D(domain,unsatdarcy.flux,"Unsaturated zone, 1D stationary")

####### discretisation #####################
# position the nodes 2 cm apart
#nodes = seq(from=domain[1],to=domain[2],by=1)
#set.discretisation(UnsatStat,nodes,"FEquartic") #setting to FEquartic slows transient simulations way too much
set.discretisation(UnsatStat,nodes,"FE")
# An initialisation is certainly important (as the default initialisation by zeros does not make sense here). 
# So we initialize with a no-flux profile:
Psi.equi = approxfun(c(domain[1],domain[2]),c(domain[2],domain[1]))
do.initialize(UnsatStat,Psi.equi)

# We want to avoid pressures to be too negative (<-1E-5)
Psi.in.range = function(z,Psi) # it has 2 arguments; the position and the state. Set the min. value to pF4.2 not pF5
{
  # if(Psi<=-1*10^4.2) return(FALSE)
  if(Psi <= -16000) return(FALSE) # also in the Feddes function -16000 which is 4.20412 and not 4.2
  #if(Psi<=-1*10^5) return(FALSE)
  else return(TRUE)
}
set.isacceptable(UnsatStat,Psi.in.range) #the set.isacceptable function limits the possible values that the state can become

############## Boundary conditions ##################
##at the bottom free drainage
##d_psi/dz = 0, so q_drainage = k(psi)
free_drain = function(psi)
{
  return(-soiltype$k.fun(psi))
}

set.BC.fluxstate(UnsatStat,"left",free_drain)

## at the now simply the precipitation
ppt = 0.1
set.BC.fixedflux(UnsatStat,"right","ppt")  
############## Boundary conditions ##################

summary(UnsatStat)
solve.steps(UnsatStat,verboselevel = 1)
plot(UnsatStat,fluxplot = T,vertical = T)
dataframe.balance(UnsatStat)
dataframe.boundaries(UnsatStat)
