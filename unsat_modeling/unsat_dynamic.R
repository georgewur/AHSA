# soil physical parameters

name="B13" #"B7"
  
# depth  below surface of saturated groundwater (in cm)

D = 750 #75


# input : a list of times (in days) and input fluxes
# note that the fluxes are given in cm/day

times =  c(0.0, 1/24, 1.2/24, 3.0/24, 4.0/24,  24/24);
influx = c(0.5, 0.5,  8,      8,       0.5    ,0.5);

# all plots go to this file:
#pdf(file=paste("dyn",name,".pdf",sep=""),width=8,height=8)


# some ranges for the plotting

psi.plot.min = -D
psi.plot.max = -1

theta.plot.min = theta.psi.fun(-psi.plot.min)
theta.plot.max = X$theta[1]+0.01


# space discretization: number of cells in profile

N = 30

# time discretization:
delt = 1/24/4


#######################################################
#                                                     #  
# in principle you should not touch the stuff beneath #
#                                                     #
#######################################################


# read in the data 
X = read.table(paste(name,".dat",sep=""))

# the following functions will be used to
# caculate k and theta given psi:

k.psi.fun = approxfun(X$psi,X$k,rule=2)
theta.psi.fun = approxfun(X$psi,X$theta,rule=2)



#the following linear interpolation function
# between the data above  will be used:

influx.fun = approxfun(times,influx,rule=2)


# some variables needed for time managing
begin.time = times[1]
end.time = times[length(times)]
min.influx = min(influx)
max.influx = max(influx)

times.used = numeric(0)
influxes.used = numeric(0)
influx.cur = influx.fun(0.0)

#some variables need for space managing

z = seq(-D,0,length=N)
zmid = (z[1:(N-1)]+z[2:N])/2.0
delz = z[2]-z[1]


# functions to define misfit

square = function(x)
  {
    sum(x*x);
  }

calcq = function(psi)
  {
    N = length(psi)
    meanpsi = (psi[1:(N-1)]+psi[2:N])/2.0;
    gradpsi = (psi[2:N]-psi[1:(N-1)])/delz;
    return(-k.psi.fun(abs(meanpsi))*(gradpsi+1) )
  }

statmodel = function(psi)
  {
    misfit = 0.0;
    misfit = misfit+10*square(psi[1]+1);
    q = calcq(psi)
    misfit = misfit+10*square(q[N-1]+influx.cur);
    misfit = misfit+square(q[1:(N-2)]-q[2:(N-1)])
    return(misfit)
  }

dynmodel = function(psi)
  {
    misfit = 0.0;
    misfit = misfit+10*square(psi[1]+1);
    q = calcq(psi)
    misfit = misfit+10*square(q[N-1]-influx.cur);
    misbalance = q[1:(N-2)]-q[2:(N-1)]+delz/delt*(theta[2:(N-1)]-theta.psi.fun(-psi[2:(N-1)]))
    misfit = misfit+square(misbalance)
    return(misfit)
  }

# the postprocessing step

do.plotting = function(psi,theta,q)
  {
    oldpar <- par(no.readonly = TRUE)
    layout(matrix(c(4, 4, 4,
                    1, 2, 3,
                    1, 2, 3,
                    1, 2, 3 ), nr = 4, byrow = TRUE))
    par(mar=c(5.1,2.1,0.3,2.1))
    plot(psi,z,xlab="",xlim=c(psi.plot.min,psi.plot.max),type="l",lwd=3,col="red")
    lines(c(-D,-1),c(0,-D),col="blue")
    mtext("psi (cm)",1,line=2.5)
    grid()
    
    plot(theta,z,ylab="z",xlab="",
         xlim=c(theta.plot.min,theta.plot.max),type="l",
         lwd=3,col="red")
    mtext("theta (-)",1,line=2.5)
    grid()
    
    plot(q,zmid,ylab="z",xlab="",xlim=c(min.influx,max.influx),
         type="l",lwd=3,col="green")
    mtext("q (cm/day)",1,line=2.5)
    grid()

 
    par(mar=c(5.1,5.1,2.1,5.1))
    plot(times.used,influxes.used,type="l",
         xlim=c(begin.time,end.time), xlab="",
         ylim=c(min(0,min.influx),max.influx),ylab="",
         col="blue",lwd=3)
    axis(4,col="red")
    mtext("time (day)",1,line=2.5)
    mtext("influx  (cm/day)",2,line=2.5,col="blue")
    mtext("outflux (cm/day)",4,line=2.5,col="red")
    lines(times.used,outfluxes,col="red",lwd=3)
    grid()
    par(oldpar)  
  }

# here the real calculations start


tracevalue = 0
#tracevalue = 2

# first calculate a stationary profile

outfluxes = rep(0.0,length=0)

t = begin.time
times.used = cbind(times.used,t)
influx.cur = influx.fun(begin.time);
influxes.used = cbind(influxes.used,influx.cur)

psi = rep(-1,N)
psiequi = -D-z-1
q = rep(0,(N-1))

  
# res= optim(psiequi,statmodel,method="BFGS",control=c(trace=tracevalue,abstol=0.000001,maxit=500))
res= optim(psiequi,statmodel,method="CG",control=c(trace=tracevalue,abstol=0.001,maxit=500))
psi = res$par
theta = theta.psi.fun(-psi)
q = -calcq(psi)
outfluxes = cbind(outfluxes,q[1])
do.plotting(psi,theta,q)

  
t = t+delt
count = 0
while(t < end.time)
  {
    times.used = cbind(times.used,t)
    influx.cur = -influx.fun(t);
    influxes.used = cbind(influxes.used,-influx.cur)
    
    res= optim(psi,dynmodel,method="BFGS",control=c(trace=tracevalue,abstol=0.001))
    psi = res$par
    if(max(psi)>0)
      {
        print("stopping because of ponding!!!")
        t=end.time
      }
    theta = theta.psi.fun(-psi)
    q=-calcq(psi)
    outfluxes = cbind(outfluxes,q[1])
    do.plotting(psi,theta,q)
    
    t = t+delt
    count = count+1
  }

#dev.off()
