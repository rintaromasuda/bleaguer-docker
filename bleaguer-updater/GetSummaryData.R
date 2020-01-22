.ScrapeSummaryPage <- function(webDr, key, homeTeamId, awayTeamId){
  urlDetail <- paste0("https://www.bleague.jp/game_detail/?ScheduleKey=",
                      as.character(key))
  print(urlDetail)
  
  webDr$navigate(urlDetail)
  Sys.sleep(0.5)
  pageSource <- webDr$getPageSource()
  htmlDetail <- read_html(pageSource[[1]])
  tablesDetail <- html_table(htmlDetail)
  
  # Table for quarter and overtime scores. We do NOT support overtime 5th and later.
  qtScore <- subset(tablesDetail[[1]], X2 != "EX1" & X2 != "EX2" & X2 != "EX3" & X2 != "EX4")
  otScore <- subset(tablesDetail[[1]], X2 == "EX1" | X2 == "EX2" | X2 == "EX3" | X2 == "EX4")
  
  if (nrow(subset(qtScore, (X2 == "1Q" | X2 == "2Q" | X2 == "3Q" | X2 == "4Q" | X2 == "F"))) != 5) {
    qtScore[1, "X2"] <- "1Q"
    qtScore[2, "X2"] <- "2Q"
    qtScore[3, "X2"] <- "3Q"
    qtScore[4, "X2"] <- "4Q"
  }
  
  # Fill 0 for overtimes that didn't happen
  for (i in seq(1:4)) {
    ot <- paste0("EX", as.character(i))
    if (nrow(subset(otScore, X2 == ot)) <= 0) {
      df <- data.frame(X1 = 0, X2 = ot, X3 = 0)
      otScore <- rbind(otScore, df)
    }
  }
  
  # Table for team summary stats
  statsSummary <- tablesDetail[[2]]
  
  # Table for team common stats (we add them to both home and away)
  statsCommon <- tablesDetail[[3]]
  statsCommon <- cbind(statsCommon[, "X2"], statsCommon)
  colnames(statsCommon) <- c("X1", "X2", "X3")
  
  # Combine them all
  combined <- rbind(qtScore, otScore)
  combined <- rbind(combined, statsSummary)
  combined <- rbind(combined, statsCommon)
  
  numRows <- 34 # If the page has correct info, it should be this number of cols
  
  if (nrow(combined) == numRows) {
    # Unpivot data for home team
    dataHome <- data.frame(
      key,
      homeTeamId,
      combined[1, "X1"],
      combined[2, "X1"],
      combined[3, "X1"],
      combined[4, "X1"],
      combined[5, "X1"],
      combined[6, "X1"],
      combined[7, "X1"],
      combined[8, "X1"],
      combined[9, "X1"],
      combined[10, "X1"],
      combined[11, "X1"],
      combined[12, "X1"],
      combined[13, "X1"],
      combined[14, "X1"],
      combined[15, "X1"],
      combined[16, "X1"],
      combined[17, "X1"],
      combined[18, "X1"],
      combined[19, "X1"],
      combined[20, "X1"],
      combined[21, "X1"],
      combined[22, "X1"],
      combined[23, "X1"],
      combined[24, "X1"],
      combined[25, "X1"],
      combined[26, "X1"],
      combined[27, "X1"],
      combined[28, "X1"],
      combined[29, "X1"],
      combined[30, "X1"],
      combined[31, "X1"],
      combined[32, "X1"],
      combined[33, "X1"],
      combined[34, "X1"]
    )
    
    # Unpivot data for away team
    dataAway <- data.frame(
      key,
      awayTeamId,
      combined[1, "X3"],
      combined[2, "X3"],
      combined[3, "X3"],
      combined[4, "X3"],
      combined[5, "X3"],
      combined[6, "X3"],
      combined[7, "X3"],
      combined[8, "X3"],
      combined[9, "X3"],
      combined[10, "X3"],
      combined[11, "X3"],
      combined[12, "X3"],
      combined[13, "X3"],
      combined[14, "X3"],
      combined[15, "X3"],
      combined[16, "X3"],
      combined[17, "X3"],
      combined[18, "X3"],
      combined[19, "X3"],
      combined[20, "X3"],
      combined[21, "X3"],
      combined[22, "X3"],
      combined[23, "X3"],
      combined[24, "X3"],
      combined[25, "X3"],
      combined[26, "X3"],
      combined[27, "X3"],
      combined[28, "X3"],
      combined[29, "X3"],
      combined[30, "X3"],
      combined[31, "X3"],
      combined[32, "X3"],
      combined[33, "X3"],
      combined[34, "X3"]
    )
    
    # Change column names for unpivotted data
    colNames <- c("ScheduleKey", "TeamId", combined$X2)
    colnames(dataHome) <- colNames
    colnames(dataAway) <- colNames
    
    # Add them to the result
    result <- data.frame()
    result <- rbind(result, dataHome)
    result <- rbind(result, dataAway)
  } else {
    stop(paste0("Irregular game result found. -> ", key))
  }
  
  return(result)
}

GetSummaryData <- function(webDr, dataGames){
  for (idx in seq(1:nrow(dataGames))) {
    key <- dataGames[idx,]$ScheduleKey
    homeTeamId <- dataGames[idx,]$HomeTeamId
    awayTeamId <- dataGames[idx,]$AwayTeamId

    record <- .ScrapeSummaryPage(webDr, key, homeTeamId, awayTeamId)
    print(record)
  }
}