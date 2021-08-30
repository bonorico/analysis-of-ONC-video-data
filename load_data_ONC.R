
# upload 4 months time series on low res images

hy = 365*24 # hours in one year
hm = hy/12 # hours in one month

hm = 24 # use dayly time scale to compare with bait release

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
    hist(counts$filesize[counts$filesize > 50])

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
        
        cts[[i]] <- ts(subset(counts, camera == i, select = "count"), # counts time series
                       start = 0, frequency = hm)
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

m2 <- loadd("ONC_video_tracks.txt", "AXIS", 0)
m3 <- loadd("ONC_video_tracks_m3.txt")
m4 <- loadd("ONC_video_tracks_m4.txt")
m5 <- loadd("ONC_video_tracks_m5.txt")

M <- list(m3, m4, m5)


# validation manual counts

manualc_raw <- read.csv("barkley_node_sablefish manual counts.csv")

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

manualc <- ts(manualc_raw$sable, start = 0, frequency = hm)

plot(manualc)


