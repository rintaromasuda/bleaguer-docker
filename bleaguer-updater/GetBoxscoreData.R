.ScrapeBoxscorePage <- function(webDr, key, eventId, homeTeamId, awayTeamId){
  result <- data.frame()
  
  urlBoxscore <- paste0("https://www.bleague.jp/game_detail/?ScheduleKey=",
                      as.character(key),
                      "&TAB=B")
  print(urlBoxscore)
  
  tryCount <- 1
  tryThreshold <- 60
  isSuccess <- FALSE
  # Post-season Game 3s in 2016-17 and 2017-18 have less tables (because they are short)
  numTables <- ifelse(eventId %in% c(300,400,800), 9, 13)
  while (tryCount <= tryThreshold) {
    webDr$navigate(urlBoxscore)
    pageSource <- webDr$getPageSource()
    htmlBoxscore <- xml2::read_html(pageSource[[1]])
    tablesBoxscore <- rvest::html_table(htmlBoxscore)
    if ((length(tablesBoxscore) >= numTables) &&
        (nrow(tablesBoxscore[[4]]) > 0) &&
        (nrow(tablesBoxscore[[5]]) > 0)) {
      isSuccess <- TRUE
      break
    } else {
      Sys.sleep(0.5)
      print(paste0("Retry the page load...(", tryCount, ")"))
      tryCount <- tryCount + 1
    }
  }
  
  if(!isSuccess){
    stop(paste0("Error loding page: ", urlBoxscore))
  }
  
  # Read player URLs and name separately as just reading the tables don't give us them
  homePlayersUrls <- htmlBoxscore %>%
    rvest::html_nodes("#game__boxscore__inner > ul.boxscore_contents > li.select > div:nth-child(2) > table > tbody > tr > td:nth-child(3) > a") %>%
    rvest::html_attr("href")
  
  awayPlayersUrls <- htmlBoxscore %>%
    rvest::html_nodes("#game__boxscore__inner > ul.boxscore_contents > li.select > div:nth-child(4) > table > tbody > tr > td:nth-child(3) > a") %>%
    rvest::html_attr("href")
  
  homePlayerNames <- htmlBoxscore %>%
    rvest::html_nodes("  #game__boxscore__inner > ul.boxscore_contents > li.select > div:nth-child(2) > table > tbody > tr > td:nth-child(3) > a > span.for-pc") %>%
    rvest::html_text(trim = TRUE)
  
  awayPlayerNames <- htmlBoxscore %>%
    rvest::html_nodes("  #game__boxscore__inner > ul.boxscore_contents > li.select > div:nth-child(4) > table > tbody > tr > td:nth-child(3) > a > span.for-pc") %>%
    rvest::html_text(trim = TRUE)
  
  homePlayerNames <- gsub(" ", "", homePlayerNames) # Hankaku
  homePlayerNames <- gsub("　", "", homePlayerNames) # Zenkaku
  awayPlayerNames <- gsub(" ", "", awayPlayerNames) # Hankaku
  awayPlayerNames <- gsub("　", "", awayPlayerNames) # Zenkaku
  
  # Get IDs out of URLs and trim the names
  startStr <- "PlayerID="
  homePlayerIds <- substring(homePlayersUrls,
                              regexpr(startStr, homePlayersUrls) + nchar(startStr))
  awayPlayerIds <- substring(awayPlayersUrls,
                              regexpr(startStr, awayPlayersUrls) + nchar(startStr))

  # Boxscore tables for one entire game.
  tableHome <- tablesBoxscore[[4]]
  tableAway <- tablesBoxscore[[5]]
  
  # Removing summary rows at the bottom
  tableHome <- tableHome[!is.na(tableHome$`#`),]
  tableAway <- tableAway[!is.na(tableAway$`#`),]
  
  # Validate row numbers
  if ((nrow(tableHome) != length(homePlayerNames)) |
      (nrow(tableHome) != length(homePlayerIds)) |
      (nrow(tableAway) != length(awayPlayerNames)) |
      (nrow(tableAway) != length(awayPlayerIds))) {
    stop(paste0("Data row num mis-match: ", urlBoxscore))
  }
  
  # Replacing names and adding more columns
  tableHome$PLAYER <- homePlayerNames
  tableAway$PLAYER <- awayPlayerNames
  
  tableHome$PlayerId <- homePlayerIds
  tableAway$PlayerId <- awayPlayerIds
  
  tableHome$ScheduleKey <- key
  tableAway$ScheduleKey <- key
  tableHome$TeamId <- homeTeamId
  tableAway$TeamId <- awayTeamId
  
  result <- rbind(tableHome, tableAway)
  result$BoxType <- "Total"

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
  
  result$Number <- result$`#`
  result$StarterBench <- ifelse(result$S == "〇", "Starter", "Bench")
  result$Player <- result$PLAYER
  result$Position <- result$PO
  result$F3GM <- result$`3FGM`
  result$F3GA <- result$`3FGA`
  result$MIN.STR <- result$MIN
  result$MIN <- bleaguer::ConvertMinStrToDec(result$MIN.STR)

  result <- result %>%
    dplyr::select(
      "ScheduleKey",
      "TeamId",
      "BoxType",
      "PlayerId",
      "Player",
      "Number",
      "Position",
      "StarterBench",
      "MIN",
      "MIN.STR",
      "PTS",
      "FGM",
      "FGA",
      "F3GM",
      "F3GA",
      "FTM",
      "FTA",
      "OR",
      "DR",
      "TR",
      "AS",
      "TO",
      "ST",
      "BS",
      "BSR",
      "F",
      "FD",
      "DUNK",
      "EFF"
    )

  return(result)
}