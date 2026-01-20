#read meteo data from https://daggegevens.knmi.nl/klimatologie/daggegevens

data = read.table("2017-2024.txt", header=TRUE, sep=",")

#inspect data
head(data)
plot(data$YYYYMMDD, data$RH, type="l", xlab="Date", ylab="rate in 10*mm/d", main="Daily PPN and RH from 2017 to 2024")
lines(data$YYYYMMDD, data$EV24, col="blue")

range(data$RH, na.rm=TRUE)
#removing the -1 for small precip values with 0.0
data$RH[data$RH == -1] <- 0
#convert RH to mm/d
data$RH <- data$RH / 10

range(data$EV24, na.rm=TRUE)
#convert EV24 to mm/d
data$EV24 <- data$EV24 / 10


plot(data$RH, type = "l", lwd = 2)
lines(data$EV24, col="blue",lwd = 2)
grid()
legend("topright", legend=c("RH", "EV24"), col=c("black", "blue"), lty=1, lwd=2)

hist(data$RH, main="Histogram of Daily Precipitation (RH)", xlab="Precipitation (mm/d)", breaks=30)
hist(data$EV24, main="Histogram of Daily Evaporation (EV24)", xlab="Evaporation (mm/d)", breaks=30)

#save processed data
savedata = data.frame(Date=data$YYYYMMDD, Precipitation_mm_d=data$RH, Evaporation_mm_d=data$EV24)
write.table(savedata, file="meteo_2017_2024_processed.txt", sep="\t", row.names=FALSE, quote=FALSE)
#end of script