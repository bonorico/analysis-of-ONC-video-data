
source("load_data_ONC.R")

names(M[["2"]]$count_time_series_stratified)

slopec <- M[["2"]]$count_time_series_stratified[[1]][, "count"] 
dragonc <- M[["2"]]$count_time_series_stratified[[2]][, "count"] 
subcamc <- M[["2"]]$count_time_series_stratified[[3]][, "count"]
# truncated subcam for comparison with manual sount
subcamc_short <- subcamc[time(subcamc) >= min(time(manualc_rest$axis)) & time(subcamc) <= max(time(manualc_rest$axis))]

Nd <- length(dragonc)
Ns <- length(subcamc)

                                        # main statistics

sum(slopec)
sum(dragonc)
sum(subcamc)

sum(slopec) + sum(dragonc) + sum(subcamc)


mean(dragonc)
sd(dragonc)
mean(subcamc) 
sd(subcamc)

tdragonc <- as.numeric(time(dragonc) - time(dragonc)[1])/2.628e06   # months
summary(lm(as.numeric(dragonc)~tdragonc))
tsubcamc <- as.numeric(time(subcamc) - time(subcamc)[1])/2.628e06   # months
summary(lm(as.numeric(subcamc)~as.numeric(time(subcamc))))

mean(subcamc_short) 
sd(subcamc_short)
tsubcamc_short <- as.numeric(time(subcamc_short) - time(subcamc_short)[1])/2.628e06   # months
summary(lm(as.numeric(subcamc_short)~tsubcamc_short))


                                        # manual counts
mean(manualc, na.rm = T) # vs dragonc
sd(manualc, na.rm = T)
mean(manualc_rest$axis, na.rm = T) # vs subcam_short
sd(manualc_rest$axis, na.rm = T)

tmanualc <- as.numeric(time(manualc) - time(manualc)[1])/2.628e06   # months
summary(lm(as.numeric(manualc)~tmanualc, na.action = na.omit))
tmanualc_axis <- as.numeric(time(manualc_rest$axis) - time(manualc_rest$axis)[1])/2.628e06   # months
summary(lm(as.numeric(manualc_rest$axis)~as.numeric(time(manualc_rest$axis)), na.action = na.omit))



devs <- c("Upper Slope", "Node", "Axis") # rename levels
############## MAIN result ###############

# resolution

resol <- 300
w <- 26
h <- 14
cxa <- 1.5
cxl <- 1.7
cxm <- 2.5
#
jpeg("Figure_5.jpeg", units="in", width= w, height= h, res= resol)

par(mfrow = c(2, 1))
par(cex.lab = cxl)
plot(dragonc, xlab = ifelse(M[["2"]]$ts_freq < 30, "Day", "Month"), ylab = "Counts (Proxy)", main = "", lwd = 2, cex.axis = cxa)
title("A", cex.main = cxm)
plot(subcamc, xlab = ifelse(M[["2"]]$ts_freq < 30, "Day", "Month"), ylab = "Counts (Proxy)", main = "", lwd = 2, cex.axis = cxa)
title("B", cex.main = cxm)

dev.off()

                                        #
jpeg("Figure_6.jpeg", units="in", width= w, height= h, res= resol)

par(mfrow = c(2, 1))
par(cex.lab = cxl)
plot(dragonc, xlab = ifelse(M[["2"]]$ts_freq < 30, "Day", "Month"), ylab = "Counts (Proxy)", main = "", lwd = 2, cex.axis = cxa)
title("A", cex.main = cxm)
plot(manualc, xlab = ifelse(M[["2"]]$ts_freq < 30, "Day", "Month"), ylab = "Counts (Proxy)", col = "red", main = "", lwd = 2, cex.axis = cxa)
title("B", cex.main = cxm)

dev.off()

jpeg("Figure_7.jpeg", units="in", width= w, height= h, res= resol)

par(mfrow = c(2, 1))
par( cex.lab = cxl )
plot(subcamc_short, xlab = ifelse(M[["2"]]$ts_freq < 30, "Day", "Month"), ylab = "Counts (Proxy)", main = "", lwd = 2, cex.axis = cxa)
title("A", cex.main = cxm)
plot(manualc_rest$axis, xlab = ifelse(M[["2"]]$ts_freq < 30, "Day", "Month"), ylab = "Counts (Proxy)", col = "red", main = "", lwd = 2, cex.axis = cxa)
title("B", cex.main = cxm)

dev.off()


 # COUNTS at upper slope

manualc_slope <- na.omit(manualc_rest$slope)
sum(manualc_slope)
sum(slopec)

range(time(manualc_slope)[manualc_slope > 0])
range(time(slopec)[slopec > 0])


                                        # sensitivity analysis for tracking parameter "m"

multic <- lapply(2:3, function(s)
    do.call("cbind",
            lapply(2:5, function(i)
                M[[as.character(i)]]$count_time_series_stratified[[s]][, "count"]
                )) 
    )
names(multic) <- c("node", "axis")


jpeg("Figure_8.jpeg", units="in", width= w, height= 18, res= resol)

par(mfrow = c(2, 1))
par(cex.axis = cxa, cex.lab = cxl, cex.main = cxm )
plot.zoo(multic$node, plot.type = "single", xlab = "Month", ylab = "Counts (Proxy)", main = "A", lwd = 2, col = 1:4)
legend("topleft", paste("m", 2:5, sep = "="), col = 1:4, lty = rep(1,4), lwd = rep(2,4), bty = "n", cex = cxm)
plot.zoo(multic$axis, plot.type = "single", xlab = "Month", ylab = "Counts (Proxy)", main = "B", lwd = 2, col = 1:4)

dev.off()


                                        # print series

## write.zoo(dragonc, "node_automatic_yolo.csv")
## write.zoo(manualc, "node_manual.csv")
## write.zoo(subcamc_short, "axis_automatic_yolo.csv")
## write.zoo(manualc_rest$axis, "axis_manual.csv")
