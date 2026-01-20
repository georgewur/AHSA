# ===============================
# Instellingen
# ===============================
rm(list = ls())
# Invoeren van bestandsnaam
input_csv <- "results_ten_day.csv"

# Startdatum eerste decade
start_date <- as.Date("2017-01-05")

# Kolom met decade nummer (B = 2)
decade_col <- 2

# Waardekolommen die je wilt exporteren
# Gebruik kolomnummers OF kolomnamen
value_columns <- c(
  shallow = 7,
  medium = 11,
  deep = 15
)

# ===============================
# Inlezen
# ===============================

data <- read.csv(input_csv, stringsAsFactors = FALSE)

# Datum berekenen
data$datum <- start_date + (data[[decade_col]] - 1) * 10

# Datumstring maken in gewenst formaat
data$datum_str <- format(data$datum, "%d-%m-%Y 00:00:00")

# =============================
# Plotjes maken
# =============================
plot(
  data$datum,
  data$uns1.Rch * -0.010,
  type = "l",
  lwd = 2,
  col = "red",
  xlab = "Date",
  ylab = "Recharge (mm/d)",
  main = "Decade Recharge per Zone"
)
lines(data$datum, data$uns2.Rch * -0.01, col = "blue",lwd = 2)
lines(data$datum, data$uns3.Rch * -0.01, col = "green", lwd = 2)
grid()
legend(
  "topright",
  legend = c("Zone shallow", "Zone medium", "Zone deep","Precipitation"),
  col = c("red", "blue", "green","grey"),
  lty = c(1, 1, 1,1),
  lwd = c(2,2,2,4),
  bty = "n"
)

## adding precipitation as bars
op <- par(no.readonly = TRUE)

par(new = TRUE)

plot(
  data$datum,
  data$ppn.cm.d,
  type = "h",
  lwd = 4,
  col = rgb(0, 0, 0, 0.25),
  axes = FALSE,
  xlab = "",
  ylab = "",
  ylim = c(0, max(data$ppn.cm.d, na.rm = TRUE))
)

axis(4)
mtext("Neerslag (cm/d)", side = 4, line = 3)

# herstel originele grafische instellingen
par(op)


# ===============================
# see if "misfits" are not that big..
# calculate misfit by: precip + (recharge + storage + evapotranspiration)
# be aware that recharge storage and evapotranspiration are negative fluxes
# ===============================
sum.shallow = data$uns1.Rch + data$uns1.Qsto + data$uns1.Qroot
sum.medium = data$uns2.Rch + data$uns2.Qsto + data$uns2.Qroot
sum.deep = data$uns3.Rch + data$uns3.Qsto + data$uns3.Qroot
misfit.shallow = data$ppn.cm.d + (data$uns1.Rch + data$uns1.Qsto + data$uns1.Qroot)
misfit.medium = data$ppn.cm.d + (data$uns2.Rch + data$uns2.Qsto + data$uns2.Qroot)
misfit.deep = data$ppn.cm.d + (data$uns3.Rch + data$uns3.Qsto + data$uns3.Qroot)
# plot aqainst time precip vs. (recharge + storage + evapotranspiration)
plot(data$datum, data$ppn.cm.d, type="l", col="black", xlab="Date", ylab="cm/d", main="Precipitation vs. summed Water balance terms")
lines(data$datum, -(data$uns1.Rch + data$uns1.Qsto + data$uns1.Qroot), col="red")
lines(data$datum, -(data$uns2.Rch + data$uns2.Qsto + data$uns2.Qroot), col="blue")
lines(data$datum, -(data$uns3.Rch + data$uns3.Qsto + data$uns3.Qroot), col="green")
grid()
legend("topright", legend=c("Precipitation","Shallow balance","Medium balance","Deep balance"),
       col=c("black","red","blue","green"), lty=1, bty="n")


#plot(data$datum, data$ppn.cm.d, type="l", col="black", xlab="Date", ylab="cm/d", main="Precipitation vs. Water balance terms")
plot(data$datum, data$ppn.cm.d +(data$uns1.Rch + data$uns1.Qsto + data$uns1.Qroot),type = "l", col="red",xlab = "Date", ylab="cm/d", main="Misfits in Water balance terms")
lines(data$datum,data$ppn.cm.d  +(data$uns2.Rch + data$uns2.Qsto + data$uns2.Qroot), col="blue")
lines(data$datum, data$ppn.cm.d +(data$uns3.Rch + data$uns3.Qsto + data$uns3.Qroot), col="green")
grid()
legend("topright", legend=c("Precipitation","Shallow balance","Medium balance","Deep balance"),
       col=c("black","red","blue","green"), lty=1, bty="n")

## rates are given in cm/d per decade, to get total mm/d rates one needs to
## multiply by 10 for the decades and again 10 for mm/d
# ===============================
# calculate year averages
# ===============================
mean.precip.year = (sum(data$ppn.cm.d) * 10 * 10) / (nrow(data) / (365.25 / 10))
mean.eref.year = (sum(data$eref.cm.d) * 10 * 10) / (nrow(data) / (365.25 / 10))
mean.uns1.rch.year = -(sum(data$uns1.Rch) * 10 * 10) / (nrow(data) / (365.25 / 10))
mean.uns1.qsto.year = -(sum(data$uns1.Qsto) * 10 * 10) / (nrow(data) / (365.25 / 10))
mean.evap.shallow.year = -(sum(data$uns1.Qroot) * 10 * 10) / (nrow(data) / (365.25 / 10))
mean.uns2.rch.year = -(sum(data$uns2.Rch) * 10 * 10) / (nrow(data) / (365.25 / 10))
mean.uns2.qsto.year = -(sum(data$uns2.Qsto) * 10 * 10) / (nrow(data) / (365.25 / 10))
mean.evap.medium.year = -(sum(data$uns2.Qroot) * 10 * 10) / (nrow(data) / (365.25 / 10))
mean.uns3.rch.year = -(sum(data$uns3.Rch) * 10 * 10) / (nrow(data) / (365.25 / 10))
mean.uns3.qsto.year = -(sum(data$uns3.Qsto) * 10 * 10) / (nrow(data) / (365.25 / 10))
mean.evap.deep.year = -(sum(data$uns3.Qroot) * 10 * 10) / (nrow(data) / (365.25 / 10))

mean.precip.year - mean.uns1.rch.year - mean.uns1.qsto.year - mean.evap.shallow.year
mean.precip.year - mean.uns2.rch.year - mean.uns2.qsto.year - mean.evap.medium.year
mean.precip.year - mean.uns3.rch.year - mean.uns3.qsto.year - mean.evap.deep.year


paste("average reference evaporation per year:", (sum(data$eref.cm.d) * 10 * 10) / (nrow(data) / (365.25 / 10)), "mm/year")
paste("average actual evapotranspiration per year shallow:", (sum(data$uns1.Rch) * 10 * 10) / (nrow(data) / (365.25 / 10)), "mm/year")
paste("average recharge shallow zone per year:", (sum(data$uns1.Rch) * 10 * 10) / (nrow(data) / (365.25 / 10)), "mm/year")
paste("average storage shallow zone per year:", (sum(data$uns1.Qsto) * 10 * 10) / (nrow(data) / (365.25 / 10)), "mm/year")
paste("average storage medium zone per year:", (sum(data$uns2.Qsto) * 10 * 10) / (nrow(data) / (365.25 / 10)), "mm/year")
paste("average storage deep zone per year:", (sum(data$uns3.Qsto) * 10 * 10) / (nrow(data) / (365.25 / 10)), "mm/year")

# ===============================
# Export per kolom
# ===============================

for (name in names(value_columns)) {

  col_index <- value_columns[[name]]
  values <- data[[col_index]] * -0.01  # Omzetten van cm/d naar m/d
  
  
  output_file <- paste0("recharge_", name, ".xys")

  lines <- paste0(
    "\"", data$datum_str, "\" ",
    values
  )
#header in XYS file
  # cat("XYS 1 293 \"trans_recharge\"", output_file)
  #writeLines(lines, output_file, append = TRUE)
  
  # data toevoegen
  # cat(paste(lines, collapse = "\n"), "\n",
  #     file = output_file, append = TRUE)
  # 
  writeLines(
    c('XYS 1 293 "trans_recharge"', lines),
    output_file
  )
  
##for urban areas multiply by 0.5
  values = data[[7]] * -0.01 * 0.5  #grass shallow in m/d and urban factor 0.5
  lines <- paste0(
    "\"", data$datum_str, "\" ",
    values
  )
#header in XYS file
  output_file <- paste0("recharge_urban.xys")
  writeLines(
    c('XYS 1 293 "trans_recharge"', lines),
    output_file
  )
  
  
  message("Bestand geschreven: ", output_file)
}
