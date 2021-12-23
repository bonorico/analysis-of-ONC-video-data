library(xts)
library(zoo)
library(tidyverse)

split_path <- function(path) {
  if (dirname(path) %in% c(".", path)) return(basename(path))
  return(c(basename(path), split_path(dirname(path))))
}

# upload 4 months time series on low res images

                                        # file names path
data_dir <- paste(rev(split_path(getwd())[-1]), collapse = "/")  #  "./"
data_patt <- "_reproduce"   # "ONC_video_tracks"

all_data <- grep(data_patt, list.files(path = data_dir), value = TRUE)[c(4,1:3)]


# funtion to load data
loadd <- function(path, subgr = "DRAGONFISHSUBC13112", ctresh = 130, hm = 24 )
{

    counts <- read.table(path)   # at 80% conf
    names(counts) <- c("videoclip", "filesize", "camera", "year", "month", "day", "hour", "min", "sec", "count" )
    counts <- counts[, -c(8:9)]
    counts$videoclip <- as.factor(counts$videoclip)
    length(levels(counts$videoclip))

    counts <- counts[order(counts$year, counts$month, counts$day, counts$hour), ]

    dim(counts)

    summary(counts$filesize)
    hist(counts$filesize)
    length(counts$filesize[counts$filesize > 50])
    table(counts[counts$filesize > 50, "camera"])
    summary(counts$filesize[counts$filesize > 50])
   # hist(counts$filesize[counts$filesize > 50])  # error if data is empty

    summary(counts$count)

    hist(counts$count)

                                        # inspect high numbers at DRAGON
    this <- unique(counts$camera)[grep(subgr, unique(counts$camera))]
    print(
        counts[counts$camera == this & counts$count > ctresh, ]
        )


##################


    true_calendar <- apply(
        cbind(
            apply(counts[, 4:6], 1, function(x) paste(x, collapse = "-")),
            paste0(counts[, 7], ":00:00")
        ), 1, function(x) paste(x, collapse = " ")
    )

    
    true_dates <-  as.POSIXct(true_calendar, format = "%Y-%m-%d  %H:%M:%S", tz = "PDT")

    study_period <- diff(range(true_dates))

### stratify by device 

    devs <- levels(as.factor(counts$camera))
    cts <- vector("list", length(devs))
    names(cts) <- devs
    tis <- obn <- ors <- ths <- sph <- sp <- hs <- cts

                                        # hourly frequency for ts

   
    for (i in devs)
    {
        hs[[i]] <- true_dates[counts$camera == i]
        sp[[i]] <- diff(range(hs[[i]]))                                # total study period in days
        sph[[i]] <- as.numeric(sp[[i]])*24                             # in hours
        obn[[i]] <- dim(subset(counts, camera == i))[1]                # total observations 
        ths[[i]] <- obn[[i]]*4/60                                      # total hours recorded 
        ors[[i]] <- obn[[i]]/sph[[i]]                                  #  observation fraction: ca 1 (every hour)
        
        cts[[i]] <- xts(subset(counts, camera == i, select = "count"), # counts time series
                       order.by = hs[[i]])
        tis[[i]] <- as.numeric(diff(hs[[i]]))/60/60                     # observation time-intervals in hours
    }

    sp
    sph
    obn
    ths
    ors
    
    return(
        list("study_period" = study_period,
             "devices" = devs,
             "true_dates_stratified" = hs,
             "total_study_period_days_stratified" = sp,
             "total_study_period_hours_stratified" = sph,
             "total_observations_stratified" = obn,
             "total_hours_recorded_stratified" = ths,
             "obs_fraction_stratified" = ors,
             "obs_time_intervals_hours_stratified" = tis,
             "count_time_series_stratified" = cts,
             "ts_freq" = hm
             
        )
    )

}


M <- lapply(1:4,
            function(i){
                if (i == 1)
                    loadd(file.path(data_dir, all_data[i]), "AXIS", 0)
                else
                    loadd(file.path(data_dir, all_data[i]))
            }  )
names(M) <- as.character(2:5)

# validation manual counts

manualc_raw <- read.csv(file.path(data_dir, "barkley_node_sablefish manual counts.csv"))

manualc_raw$time <- as.POSIXct(
    sapply(manualc_raw$time,
           function(x)
           {
               splitblock <- strsplit(x[1], "T")[[1]]
               split1 <- splitblock[1]        
               split2 <- substr(splitblock[2], 1, 8)
               paste(split1, split2, sep = " ")
           }
           ),
    format = "%Y-%m-%d  %H:%M:%S", tz = "PDT")

manualc_raw <- manualc_raw[order(manualc_raw$time), ]

tail(manualc_raw$time[], n = 1) - manualc_raw$time[1]

manualc <- xts(manualc_raw$sable, order.by = manualc_raw$time)

plot(manualc)

#

manualc_rest <- lapply(c("axis", "slope"), function(d)
    read.csv(file.path(data_dir, paste0("manual_counts_", d,".csv")))
    )
names(manualc_rest) <- c("axis", "slope")

manualc_rest <- lapply(manualc_rest,
                       function(x)
                       {                      
                           countcol <- grep("sablefish", names(x), value = TRUE)
                           x$time <- as.POSIXct(
                               paste(x$date, x$annotation, sep = " "),
                               format = "%m/%d/%Y  %H:%M:%S", tz = "PDT")
                           dat <- x[!is.na(x$time), ]
                           xts(dat[[countcol]], order.by = dat$time)                           
                       } )

