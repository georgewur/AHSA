##script to analyse the effect of different
## recharge
## soil types
## depth of the groundwater table
## on the psi and theta profiles

### make the environment clean
rm(list = ls())
### load the manipulate package
library(manipulate)

###loading the staring series data
load(file='Staring.Rdata')
soil.names = names(soil.set)

manipulate({
  # Definieer de bodemtype
  soil <- soil.set[[soil_choice]]
  soil_name <- soil$name
  
  # Definieer het domein
  dz <- 1 # cm
  psi <- seq(psi_min, 0, by = dz) # cm
  z <- psi
  
  # Randvoorwaarden
  psi[1] <- 0.0 # Grondwaterstand
  
  # Flux rate aan het oppervlak
  for (i in 2:length(psi)) {
    psi[i] <- psi[i-1] + (q / soil$k.fun(psi[i-1]) - 1) * dz
  }
  
  oldpar <- par(no.readonly = TRUE)
  par(mfrow = c(1, 2)) # Twee plots naast elkaar
  
  plot(z, rev(z), type = "l", lty = "dashed", col = "blue", main = paste("Soil:", soil_name, "; q = ", q, "cm/day"),
       ylab = "Depth (cm)", xlab = "Pressure head (psi in cm)", xlim = range(psi))
  lines(psi, z, type = "l", col = "red",lwd = 3)
  grid()
  
  range_theta <- c(soil$theta.res, soil$theta.sat)
  plot(soil$theta.fun(psi), z, type = "l", col = "red", lwd = 3,
       ylab = "Depth (cm)", xlab = "Water content", xlim = range_theta)
  lines(soil$theta.fun(rev(z)), z, type = "l", col = "blue", lty = "dashed")
  grid()
  
  par(oldpar)
  
}, 
q = slider(-0.1, 1, step = 0.01, initial = 0.01, label = "Flux rate (q) (cm/d)"),
psi_min = slider(-2500, 0, step = 10, initial = -1500, label = "gw table below surface (cm)"),
#soil_choice = picker("B13", "O2", label = "Soil type"))
soil_choice = picker(as.list(soil.names), label = "Soil type"))