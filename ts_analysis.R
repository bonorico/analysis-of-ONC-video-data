

source("load_data_ONC.R")

names(m2$count_time_series_stratified)

axisc <- m2$count_time_series_stratified[[1]][, "count"] 
dragonc <- m2$count_time_series_stratified[[2]][, "count"] 
subcamc <- m2$count_time_series_stratified[[3]][, "count"]
Nd <- length(dragonc)
Ns <- length(subcamc)

                                        # main statistics

sum(axisc)
sum(dragonc)
sum(subcamc)

sum(axisc) + sum(dragonc) + sum(subcamc)


mean(dragonc)
sd(dragonc)
mean(subcamc) 
sd(subcamc)

summary(lm(as.numeric(dragonc)~as.numeric(time(dragonc))))
summary(lm(as.numeric(subcamc)~as.numeric(time(subcamc))))

devs <- c("Upper Slope", "Node", "Axis") # rename levels
############## MAIN result ###############

png("counts_2.png", width = 4000, height = 2000)

par(mfrow = c(2, 1))
par(cex.axis = 4, cex.lab = 4, cex.main = 4 )
plot(dragonc, xlab = ifelse(m2$ts_freq < 30, "Day", "Month"), ylab = "Counts (Proxy)", main = devs[2], lwd = 2)
plot(subcamc, xlab = ifelse(m2$ts_freq < 30, "Day", "Month"), ylab = "Counts (Proxy)", main = devs[3], lwd = 2)

dev.off()
                                        #

png("counts_3.png", width = 4000, height = 2000)

par(cex.axis = 4, cex.lab = 4, cex.main = 4 )
plot(dragonc, xlab = ifelse(m2$ts_freq < 30, "Day", "Month"), ylab = "Counts (Proxy)", main = devs[2], lwd = 2)
points(as.numeric(time(manualc)), as.numeric(manualc), type = "l", col = "red", lwd = 2)
# abline(v = baittime, lty = 2, col = "green", lwd = 2)
legend("topleft", c("automatic", "manual"), col = c(1, 2), lty = c(1, 1), lwd = c(2,2), bty = "n", cex = 1.5)

dev.off()

png("counts_4.png", width = 4000, height = 2000)

par(mfrow = c(2, 1))
par(cex.axis = 4, cex.lab = 4, cex.main = 4 )
plot(dragonc, xlab = ifelse(m2$ts_freq < 30, "Day", "Month"), ylab = "Counts (Proxy)", main = paste(devs[2], "(automatic count)", sep = " "), lwd = 2)
#abline(v = baittime, lty = 2, col = "green", lwd = 2)
plot(manualc, xlab = ifelse(m2$ts_freq < 30, "Day", "Month"), ylab = "Counts (Proxy)", col = "red", main = paste(devs[2], "(manual count)", sep = " "), lwd = 2)
# abline(v = baittime, lty = 2, col = "green", lwd = 2)

dev.off()


                                        # sensitivity analysis for tracking parameter "m"
png("counts_5.png", width = 4000, height = 2000)

par(mfrow = c(2, 1))
par(cex.axis = 4, cex.lab = 4, cex.main = 4 )
plot(dragonc, xlab = ifelse(m2$ts_freq < 30, "Day", "Month"), ylab = "Counts (Proxy)", main = devs[2], lwd = 2)
text <- colours <- vector("list", 4)
text[[1]] <- 2
colours[[1]] <- 1
for(i in 1:3)
{
    mm <- M[[i]]$count_time_series_stratified[[2]][, "count"]
    points(as.numeric(time(mm)), as.numeric(mm), lwd = 2, col = 2 + i, type = "l")
    colours[[i + 1]] <- text[[i+1]] <- 2 + i
    
}
legend("topleft", paste("m", unlist(text), sep = "="), col = unlist(colours), lty = rep(1,4), lwd = rep(2,4), bty = "n", cex = 4)

plot(subcamc, xlab = ifelse(m2$ts_freq < 30, "Day", "Month"), ylab = "Counts (Proxy)", main = devs[3], lwd = 2)
for(i in 1:3)
{
    mm <- M[[i]]$count_time_series_stratified[[3]][, "count"]
    points(as.numeric(time(mm)), as.numeric(mm), lwd = 2, col = 2 + i, type = "l")
}

dev.off()




