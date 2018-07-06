
##### shRlog #####

###security hub in R using graylog###
### data last 6 hours ###
# inspired by http://shiny.rstudio.com/gallery/movie-explorer.html #
# last changes: 06.07.2018




library(jsonlite)
library(elastic)
library(dplyr)
library(iptools)
library(expss)

# set working directory of your data (can be any place, but should be the same as in file server.R)

setwd("C:/tmp")  

connect(es_host = "192.168.200.9", es_port = 9200)



# modify the name of your index here


res_hour <-  Search(index = "graylog_36", body = '{
                    "query": {
                    "range" : {
                    "timestamp" : {
                    "from" : "now-360m",
                    "to" :  "now-m",
                    "format": "yyyy-MM-dd HH:mm:ss.SSS"
                    }
                    }
                    }
                    }', fields=c('timestamp','full_message','source', 'srcip', 'dstip', 'message','msg_id', 'dst_ip'), size = 10000)


#test
#res_hour <- visits

# can be added to shiny App as a Search Pattern: Specific Date and time range:

#res_day <-  Search(index = "graylog_29", body = '{
#                "query": {
#               "range" : {
#              "timestamp" : {
#             "from" : "2018-06-29 21:00:00.000",
#            "to" :  "2018-06-29 21:10:00.000",
#           "format": "yyyy-MM-dd HH:mm:ss.SSS"
#          }
#         }
#        }
#       }', fields=c('timestamp','full_message','source', 'srcip', 'dstip', 'message','msg_id', 'dst_ip','whois'), size = 10000)


out_hour <- lapply(res_hour$hits$hits, function(x) unlist(x$fields, FALSE))



logbuch_hour <- bind_rows(out_hour)


###generate own IP-Adresses -> define ranges of internal used IP-Adresses here:

IP_range1 <- range_generate("192.168.200.0/24")
IP_range2 <- range_generate("192.168.201.0/24")


eigenIP <- (c(IP_range1,IP_range2))

rm(IP_range1)
rm(IP_range2)

eigenIP <- as.data.frame(eigenIP)


EigenIP <-  filter(logbuch_hour, dstip %in%  eigenIP$eigenIP)

logbuchZ <- setdiff (logbuch_hour,EigenIP)

logbuchZ <- as.data.frame(logbuchZ)

logbuchZ$time <- as.POSIXct(logbuchZ$timestamp)

logbuchZ$date <- format(logbuchZ$time, "%Y-%m-%d")
logbuchZ$mounth <- format(logbuchZ$time, "%m")
logbuchZ$year <- format(logbuchZ$time, "%Y")
logbuchZ$hour <- format(logbuchZ$time, "%H")
logbuchZ$day <- format(logbuchZ$time, "%d")


logbuchZ$connect <- 1



#Org is now dstip, should be org in future (Whois from graylog)
visits <- logbuchZ %>% group_by(Date = date, Day = day, Hour = hour, Srcip = srcip,Org = dstip) %>% summarise(Connect = sum(connect))
visits$ID <- 1 : nrow(visits)

write.csv2(visits, "Visits_Hour.csv")







