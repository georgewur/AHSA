#cleaning the memory
rm(list=ls())
#loading the manipulate package
library(manipulate)


#some required functions
hweir = function(Q,weir.b)
{
  return (weir.d + (Q/(2/3*sqrt(2*9.8)*Cd*weir.b))^(2/3))
}
#wetted Area
ow.A = function(a,ow.b,ow.m)
{
  return(ow.b*a+ow.m*2*a^2/2)
}
# water table width
ow.B = function(a,ow.b,ow.m)
{
  return(ow.b + 2*ow.m*a)
}
#wetten perimeter
ow.P = function(a,ow.b,ow.m)
{
  return(ow.b + a * 2 *sqrt(1 + ow.m^2))
}
#hydraulic radius
ow.R = function(a)
{
  return(ow.A(a,ow.b,ow.m)/ow.P(a,ow.b,ow.m))
}
# some parameter values losely related to the Midden-Regge
ow.L = 5800
S0 = 0.001
ds = -10


n = 0.05
ow.b = 3 #width of the river #just a guess
ow.m = 2 #side slope of the river #just a guess

#Zb.fun = approxfun(c(0,-ow.L),c(0,ow.L*S0))
#now Zb.fun need to be a function of S0 as well, since this a slider
Zb.fun = function(s,S0)
{
  return(-s*S0)
}


Cd = 0.62  #discharge coefficient for the weir

weir.d = 1.25 #weir/crest height
weir.b = 1.5 #weir/crest width

s = seq(0,-ow.L, by = ds)

#the manipulate routine
Qup = 1.5
Q_Si = 0.0 #0.5
S0 = 0.001
n =0.03

a.si = rep(0,length(s))

manipulate({
  # new set of water depth for backwater curves including side inflow
  
  # first downstream prescribed water level
  a.si[1] = hweir(Qup + Q_Si,weir.b)
  # a Q array along the trajectory of the river
  Qs = seq(Qup+Q_Si,Qup,length.out= length(s))
  #loop for calculating the water levels
  for (i in 1:(length(a.si)-1) )
  {
    A = ow.A(a.si[i],ow.b,ow.m)
    Q = Qs[i]
    u = Q/A
    I =  Q_Si/ow.L
    S.i = 2*u*I/(9.8*A)
    S.f = n^2*abs(Q)^2/(A^2*ow.R(a.si[i])^(4/3))
    Fr = sqrt(Q^2*ow.B(a.si[i],ow.b,ow.m)/(9.8*A^3))
    dads = (S0 - S.f - S.i)/(1-Fr^2)
    ##calculation of the water depths in upstream order
    a.si[i+1] = a.si[i] + dads*ds
  }
  ## the water level is simply the  water depth + the bottom slope #ylim = c(0,h.si[length(h.si)]),
  h.si = a.si + Zb.fun(s,S0)
  plot(s,h.si, type = "l",xlab = "Distance from weir (m)", ylab = "Water level (m)",ylim = c(0,h.si[length(h.si)]),
       main = paste("S0 :",S0, "Q_up :",Qup, "Q_Si :",Q_Si),col = "blue",lwd = 3)
  lines(s,Zb.fun(s,S0), col = "brown", lwd = 3)
  rect(-15,0,0,weir.d,col = "brown")
  grid()
  
},
Qup = slider(0.15, 10, initial = Qup, step = 0.1, label = "Qup"),
Q_Si = slider(0, 10, initial = Q_Si, step = 0.1, label = "Q_Si"),
S0 = slider(0.0001, 0.005, initial = S0, step = 0.0001, label = "S0"),
n = slider(0.01, 0.05, initial = n, step = 0.01, label = "n"),
weir.b = slider(0.1, 10, initial = weir.b, step = 0.1, label = "weir.b"),
ow.b = slider(1, 10, initial = ow.b, step = 0.2, label = "ow.b"),
ow.m = slider(1, 4, initial = ow.m, step = 0.2, label = "ow.m")
)


