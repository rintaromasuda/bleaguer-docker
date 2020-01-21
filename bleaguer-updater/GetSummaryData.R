.ScrapeSummaryPage <- function(webDr, urlDetail){
  webDr$navigate(urlDetail)
  Sys.sleep(0.5)
  pageSource <- webDr$getPageSource()
  htmlDetail <- read_html(pageSource[[1]])
  tablesDetail <- html_table(htmlDetail)
}

GetSummaryData <- function(webDr, dataGames){
  for (idx in seq(1:nrow(dataGames))) {
    key <- dataGames[idx,]$ScheduleKey
    homeTeamId <- dataGames[idx,]$HomeTeamId
    awayTeamId <- dataGames[idx,]$AwayTeamId

    urlDetail <- paste0("https://www.bleague.jp/game_detail/?ScheduleKey=",
                        as.character(key))
    print(urlDetail)
    .ScrapeSummaryPage(webDr, urlDetail)
  }
}