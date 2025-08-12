##some additional functions for the Unsat_trans.Rmd's 


calc.wtable = function(model)
{
  df = dataframe.states(model)
  psi.fun = approxfun(df$state,df$x)
  wtable.tmp <<- c(wtable.tmp,psi.fun(0)) #store the water table depth
}

plot.wtable = function(model,curtime)
{
  df = dataframe.states(model)
  plot(df$state, df$x, type = "o",col = "blue",lwd=2.5,
       main = paste("Psi(z), location water table at time",curtime), xlab = "psi in cm", ylab = "depth profile")
  abline(h = drn.level, col = "brown", lwd= 3, lty = "dashed")
  text(20,drn.level, "drainage level", col = "brown")
  psi.fun = approxfun(df$state,df$x)
  abline(h = psi.fun(0),col = "red", lwd = 2)
  text(20,psi.fun(0),"water table" , col = "red")
  grid()
}

plot.theta = function(model)
{
  df = dataframe.states(model)
  theta.psi = soiltype$theta.fun(df$state)
  plot(theta.psi,df$x, type = "o", col = "green", lwd = 2.5,
       main = "Theta(z), moisture content in profile", xlab = "theta", ylab = "depth profile")
  abline(h = drn.level, col = "brown", lwd= 3, lty = "dashed")
  text((mean(theta.psi)),drn.level, "drainage level", col = "brown")
  grid()
}

plot.roots = function(model)
{
  df = dataframe.externalfluxes(model)
  plot(df$`S{Evapotranspiration}dx`,df$x, type = "o", col = "green", lwd = 2.5,
       main = "Moisture extraction by roots in depth", xlab = "rate (cm/d)", ylab = "depth profile")
  #abline(h = drn.level, col = "brown", lwd = 3, lty = "dashed")
  #text(mean(df$`S{Transpiration}dx`),drn.level,"drainage level", col = "brown")
  grid()
}

save.data = function(model = modelname)
{
  df.state = dataframe.states(model)
  state.tmp <<- rbind(state.tmp,df.state$state) #adding the states (psi) to this data.frame
  df.extern = dataframe.externalfluxes(model)
  transp.tmp <<- rbind(transp.tmp,df.extern$`S{Evapotranspiration}dx`) #for transpiration(roots) data
  moist.tmp <<- rbind(moist.tmp,df.extern$`S{Storage}dx`)
  #balance terms transp:[2,3],flow2sto:[3,2],sto2flow[3,3]
  df.balance = dataframe.balance(model)
  #the drainage/upward seepage at the bottom will be written in balance.dat
  df.bound = dataframe.boundaries(model)
  balance.tmp <<- rbind(balance.tmp,c(precip[current.time],evapot[current.time],
                                      df.balance[2,3],df.balance[3,2],
                                      df.balance[3,3],df.bound[1,4],df.bound[2,4]))
}

plot.trans.balance = function() # this is a very basic simple and generic R plot
{
  time.series = c(1:length(balance.res[,1]))
  flux.range = range(balance.res[,2:8])
  plot(x = time.series , y = balance.res$Eact, ylim = flux.range, xlab = "time (d)",
       ylab = "flux rate cm/d", main = "Water balance terms", type = "l",
       lwd = 2, col = "red")
  lines(x = time.series, y = balance.res$Sto2flow, lwd = 2,col = "lightblue")
  lines(x = time.series, y = balance.res$Flow2sto, lwd = 2, col = "lightgreen")
  lines(x = time.series, y = balance.res$Recharge, lwd = 2, col = "magenta")
  lines(x = time.series, y = balance.res$Precip, lwd = 2, col = 'blue',lty = "dashed")
  lines(x = time.series, y = balance.res$Ponding, lwd = 2, col = 'orange')
  lines(x = time.series, y = balance.res$Epot, lwd = 2, col = 'tomato3',lty = "dashed")
  grid()
  legend("topright", legend = c("Eact", "Sto2flow", "Flow2sto", "Recharge", "Precip", "Ponding", "Epot"),
         col = c("red", "lightblue", "lightgreen", "magenta", "blue", "orange", "tomato3"),
         lwd = 2, bty = "n")
}

