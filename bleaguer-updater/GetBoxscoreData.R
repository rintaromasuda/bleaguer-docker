.ScrapeBoxscorePage <- function(webDr, key, eventId, homeTeamId, awayTeamId){
  urlDetail <- paste0("https://www.bleague.jp/game_detail/?ScheduleKey=",
                      as.character(key),
                      "&TAB=B")
  print(urlDetail)
  
  webDr$navigate(urlDetail)

  result <- data.frame()
  return(result)
}

GetBoxscoreData <- function(webDr, dataGames){
  library(rvest)
  
  result <- data.frame()
  
  for (idx in seq(1:nrow(dataGames))) {
    key <- dataGames[idx,]$ScheduleKey
    homeTeamId <- dataGames[idx,]$HomeTeamId
    awayTeamId <- dataGames[idx,]$AwayTeamId
    eventId <- dataGames[idx,]$EventId

    record <- .ScrapeBoxscorePage(webDr, key, eventId, homeTeamId, awayTeamId)
    result <- rbind(result, record)
  }

  return(result)
}