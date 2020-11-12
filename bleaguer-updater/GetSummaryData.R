.ScrapeSummaryPage <- function(webDr, key, homeTeamId, awayTeamId){
  urlDetail <- paste0("https://www.bleague.jp/game_detail/?ScheduleKey=",
                      as.character(key))
  print(urlDetail)

  webDr$navigate(urlDetail)
  Sys.sleep(0.5) # Consider making this event-based
  pageSource <- webDr$getPageSource()
  htmlDetail <- xml2::read_html(pageSource[[1]])
  tablesDetail <- rvest::html_table(htmlDetail)
  
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
  library(dplyr)
  library(rvest)
  
  result <- data.frame()
  
  gameIndex <- 1
  gameCount <- nrow(dataGames)
  tryCount <- 1
  tryThreshold <- 5
  while (gameIndex <= gameCount) {
    tryCatch(
      {
        isFinished <- FALSE
        key <- dataGames[gameIndex,]$ScheduleKey
        homeTeamId <- dataGames[gameIndex,]$HomeTeamId
        awayTeamId <- dataGames[gameIndex,]$AwayTeamId

        if (tryCount <= tryThreshold) {
          record <- .ScrapeSummaryPage(webDr, key, homeTeamId, awayTeamId)
          result <- rbind(result, record)
        } else {
          print(paste0("Gave up scraping Summary of :", key))
          g_failedSummary <<- append(g_failedSummary, key)
        }

        isFinished <- TRUE
      },
      error = function(e){
        # Re-opening the browser
        print(paste0("[", tryCount,"] Re-opening the browser..."))
        webDr$close()
        webDr$open()
      },
      finally = {
        if (isFinished) {
          gameIndex <- gameIndex + 1
          tryCount <- 1
        } else {
          tryCount <- tryCount + 1
        }
      }
    )
  }
  
  result$Q1 <- result$`1Q`
  result$Q2 <- result$`2Q`
  result$Q3 <- result$`3Q`
  result$Q4 <- result$`4Q`
  
  result$OT1 <- result$EX1
  result$OT2 <- result$EX2
  result$OT3 <- result$EX3
  result$OT4 <- result$EX4
  
  result$PTS <- result$F
  
  result$F2GM <- result$`2 Points FGM`
  result$F2GA <- result$`2 Points FGA`
  result$F3GM <- result$`3 Points FGM`
  result$F3GA <- result$`3 Points FGA`
  result$FTM <- result$`Free-ThrowsM`
  result$FTA <- result$`Free-ThrowsA`
  
  result$OR <- result$`Offensive Rebounds`
  result$DR <- result$`Defensive Rebounds`
  result$TR <- result$`Total Rebounds`
  
  result$AS <- result$Assist
  
  result$TO <- result$Turnover
  
  result$ST <- result$Steals
  
  result$BS <- result$Blocks
  
  result$F <- result$Fouls
  
  result$PtsFastBreak <- result$`Fast Break Points`
  result$PtsBiggestLead <- result$`Biggest Lead`
  result$PtsInPaint <- result$`Points in the Paint`
  result$PtsFromTurnover <- result$`Points From Turnover`
  result$PtsSecondChance <- result$`Second Chance Points`
  
  result$BiggestScoringRun <- result$`Biggest Scoring Run`
  
  result$LeadChanges <- result$`Lead Changes`
  result$TimesTied <-  result$`Times Tied`
  
  result <- result %>%
    dplyr::select(
      "ScheduleKey",
      "TeamId",
      "PTS",
      "Q1",
      "Q2",
      "Q3",
      "Q4",
      "OT1",
      "OT2",
      "OT3",
      "OT4",
      "F2GM",
      "F2GA",
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
      "F",
      "PtsBiggestLead",
      "PtsInPaint",
      "PtsFastBreak",
      "PtsSecondChance",
      "PtsFromTurnover",
      "BiggestScoringRun",
      "LeadChanges",
      "TimesTied"
    )
  
  return(result)
}