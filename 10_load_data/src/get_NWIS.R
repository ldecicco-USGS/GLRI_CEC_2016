library(dataRetrieval)
library(tidyr)
library(dplyr)

# This should include both schedule 4433 (wastewater indicators)
# and 2437 pesticides

get_NWIS <- function(site.file){
  
  dfSites <- readRDS(file = site.file)

  ## define sites for data retrieval ##
  sites <- dfSites$USGS.station.number #Use all sites in list for now

  df <- readWQPdata(siteNumbers = paste0("USGS-",sites), 
                      startDate = '2015-10-01',
                      endDate = '2016-09-30')

  df$remark_cd <- ""
  df$remark_cd[grep("^Not Detected$",df$ResultDetectionConditionText)] <- "<"

  df$occur <-  df$remark_cd != "<"
  df$occur <- ifelse(is.na(df$occur),TRUE,df$occur)
  
  df_sub <- df %>%
    select(pdate = ActivityStartDateTime, FullsiteID = MonitoringLocationIdentifier, ActivityIdentifier,
           CharacteristicName,pCode=USGSPCode,value = ResultMeasureValue,remark_cd,units = ResultMeasure.MeasureUnitCode,
           ActivityTypeCode, HydrologicCondition, HydrologicEvent,ResultValueTypeName,
           lab.comments = ResultLaboratoryCommentText,
           detection.type = DetectionQuantitationLimitTypeName,
           detection.limit = DetectionQuantitationLimitMeasure.MeasureValue,
           detection.units = DetectionQuantitationLimitMeasure.MeasureUnitCode) %>%
    mutate(SiteID = gsub(pattern = "USGS-","",FullsiteID),
           NWISRecordNumber = sapply(strsplit(ActivityIdentifier,"\\."), function(x) x[3])) %>%
    select(-ActivityIdentifier, -FullsiteID)
  

  return(df_sub)
  
}

get_pCode <- function(pest.file){
  dfPest <- readRDS(file=pest.file)
  dfPest$USGS.Parameter.code <- as.character(dfPest$USGS.Parameter.code)
  pCodeInfo <- readNWISpCode(dfPest$USGS.Parameter.code)
  return(pCodeInfo)
}