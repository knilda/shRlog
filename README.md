# shRlog

Security Hub in R using Graylog

created by knilda from lachenmair.info IT-Consulting


An overview of firewall log data in R via Shiny App

This is the first version of the App. 
We select data from the last 6 hours of a graylog stream via elasticsearch REST API.

Approved in R Version 3.4.2 (2017-09-28) and latest version (at date 01.07.2018) of following packages: 

shiny, jsonlite, elastic, dplyr, iptools, ggvis

The graylog stream is on a single index called graylog_1 and should include 'timestamp','full_message','source', 'srcip', 'dstip', 'message','msg_id', 'dst_ip'

First run data_last_hours.R file in the folder shinyApp/overview_app to get the data. Then open server.R and press the "Run App"-Button. 

I am open for any Questions, so please ask. 
