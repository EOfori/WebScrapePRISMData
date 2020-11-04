rm(list=ls(all=TRUE));library(RSelenium)
cat(crayon::green$bold$italic$underline("Start browser", Sys.time()),fill=T)
rD <- rsDriver(browser = c("chrome"),chromever = "78.0.3904.105") #install java, then download latest version of ChromeDriver and place in R source file
remDr <- rD[["client"]]
cat(crayon::green$bold$italic$underline("Go to website", "started on", Sys.time()),fill=T)
remDr$navigate("http://prism.oregonstate.edu/explorer/");Sys.sleep(5)

remDr$findElement(using = "xpath", '//*[(@id = "loc_state")]')$sendKeysToElement(list("Kansas"))

cat(crayon::green$bold$italic$underline("Sellect needed data", Sys.time()),fill=T)

for(varbl in c("cvar_tmin","cvar_tmax","cvar_tdmean","cvar_vpdmin","cvar_vpdmax")){
  eval(parse(text=paste0("webElem <- remDr$findElement(using = 'xpath'",",","'//*[(@id = ",'"',varbl,'"',")]')")));webElem$clickElement()
  
}

webElem <- remDr$findElement(using = "xpath", '//*[(@id = "tper_daily")]');webElem$clickElement()
remDr$findElement(using = "xpath", '//*[(@id = "tper_daily_start_year")]')$sendKeysToElement(list("1990"))
remDr$findElement(using = "xpath", '//*[(@id = "tper_daily_end_year")]')$sendKeysToElement(list("2018"))
remDr$findElement(using = 'id', value='tper_daily_start_month')$sendKeysToElement(list("January"))
remDr$findElement(using = 'id', value='tper_daily_end_month')$sendKeysToElement(list("D"))
StartDay <- remDr$findElement(using = 'id', value='tper_daily_start_day')
for(i in 1:31){StartDay$sendKeysToElement(list(key = "up_arrow"))}
EndDay <- remDr$findElement(using = 'id', value='tper_daily_end_day')
for(i in 1:31){EndDay$sendKeysToElement(list(key = "down_arrow"))}
webElem <-remDr$findElement(using = "xpath", '//*[(@id = "units_si")]');webElem$clickElement()

for(county in 1:105){
  remDr$findElement(using = "xpath", '//*[(@id = "loc_county")]')$sendKeysToElement(list(key = "down_arrow"))
  Sys.sleep(1)
  webElem <- remDr$findElement(using = "xpath", '//*[(@id = "submit_button")]');webElem$clickElement();Sys.sleep(30)
  webElem <- remDr$findElement(using = "xpath", '//*[(@id = "download_button")]');webElem$clickElement();Sys.sleep(30)
  File.List<-c(list.files(path="C:/Users/Eric/Downloads",pattern = "PRISM_",full.names = T))
  data <- readr::read_csv(File.List,skip = 10)
  data$Cut<-county
  file.remove(File.List)
  if(county==1) Final<- data
  if(county> 1) Final<- rbind(Final,data)
}

remDr$close()
rD[["server"]]$stop()

library(tidyverse)
cw_names<-read.csv("county_names_weather.csv")
#merge with county_names_weather
dat<-inner_join(cw_names, Final, by="Cut")

write.csv(dat,"weatherdat.csv")

