.ScrapeGamePage <- function(webDr, urlGame){
  webDr$navigate(urlGame)
  Sys.sleep(0.5) # Consider making this event-based

  pageSource <- webDr$getPageSource()
  htmlGame <- xml2::read_html(pageSource[[1]], encoding = "utf-8")

  ########
  # Parsing all the necessary information
  ########
  date <- htmlGame %>%
    rvest::html_nodes("#game__top__inner > div.date_wrap > p:nth-child(2) > span") %>%
    rvest::html_text()
  
  arena <- htmlGame %>%
    rvest::html_nodes("#game__top__inner > div.place_wrap > p.StadiumNameJ") %>%
    rvest::html_text()
  arena <- gsub("会場：", "", arena)
  
  attendance <- htmlGame %>%
    rvest::html_nodes("#game__top__inner > div.place_wrap > p.Attendance") %>%
    rvest::html_text()
  attendance <- as.integer(gsub("人", "", gsub("人数：", "", attendance)))  

  home <- htmlGame %>%
    rvest::html_nodes("#game__top__inner > div.result_wrap > div.team_wrap.home.win > div.team_name > p.for-sp") %>%
    rvest::html_text()
  if (identical(home, character(0))) {
    home <- htmlGame %>%
      rvest::html_nodes("#game__top__inner > div.result_wrap > div.team_wrap.home > div.team_name > p.for-sp") %>%
      rvest::html_text()
  }
  
  away <- htmlGame %>%
    rvest::html_nodes("#game__top__inner > div.result_wrap > div.team_wrap.away.win > div.team_name > p.for-sp") %>%
    rvest::html_text()
  if (identical(away, character(0))) {
    away <- htmlGame %>%
      rvest::html_nodes("#game__top__inner > div.result_wrap > div.team_wrap.away > div.team_name > p.for-sp") %>%
      rvest::html_text()
  }

  result <- data.frame(
    Date = date,
    Arena = arena,
    Attendance = attendance,
    HomeTeam = home,
    AwayTeam = away
  )

  return(result)
}

GetGamesData <- function(webDr, season){
  library(bleaguer)
  library(rvest)
  
  result <- data.frame()
  
  leagues <- c("B1", "B2")
  b1.events <- c(3)
  b2.events <- c(8)

  keysInData <- subset(bleaguer::b.games, Season == season)$ScheduleKey
    
  for (league in leagues) {
    print(paste0(league, " scraping start..."))

    # Target events
    if (league == "B1") {
      events <- subset(bleaguer::b.events, EventId %in% b1.events)
    } else {
      events <- subset(bleaguer::b.events, EventId %in% b2.events)
    }

    # Target teams
    teams <- subset(bleaguer::b.teams, Season == season & League == league)
    
    for (eventRow in seq(1:nrow(events))) {
      eventId <- events[eventRow, ]$EventId
      eventName <- events[eventRow, ]$ShortName
      eventCategory <- events[eventRow, ]$Category
      print(paste0("Target event: ", eventName))

      for (teamRow in seq(1:nrow(teams))) {
        teamId <- teams[teamRow, ]$TeamId
        teamName <- teams[teamRow, ]$NameShort
        urlTeam <- paste0("https://www.bleague.jp/schedule/?",
                          "tab=",
                          gsub("B", "", league),
                          "&year=",
                          substr(season, 0, 4),
                          "&event=",
                          as.character(eventId),
                          "&club=",
                          as.character(teamId))
        print(paste(teamName,
                    urlTeam))
        
        webDr$navigate(urlTeam)
        Sys.sleep(3) # Consider making this event-based
        pageSource <- webDr$getPageSource()
        htmlTeam <- xml2::read_html(pageSource[[1]], encoding = "utf-8")
        
        btnName <- paste0("btn btn-bk schedule-b",
                          gsub("B", "", league),
                          "-report")
        urlGames <- htmlTeam %>%
          rvest::html_nodes(xpath = paste0("//a[@class=\"",
                                           btnName,
                                           "\"]")) %>%
          rvest::html_attr("href")
        print(paste0("Number of games found: ", length(urlGames)))
        gameIndex <- 1
        gameCount <- length(urlGames)
        while (gameIndex <= gameCount) {
          urlGame <- urlGames[gameIndex]
          startStr <- "ScheduleKey="
          key <- substring(urlGame,
                           regexpr(startStr, urlGame) + nchar(startStr))
          print(paste0("[", gameIndex,"] ","Target ScheduleKey: ", key))
          # Duplicate check
          if (!(key %in% keysInData)) {
            tryCatch(
              {
                record <- .ScrapeGamePage(webDr, urlGame)

                if (nrow(record) <= 0) {
                   stop("Error scraping the game page")
                }

                record$ScheduleKey <- key
                record$Season <- season
                record$League <- league
                record$EventId <- eventId
                
                print(paste("Scraped:",
                            record$ScheduleKey,
                            record$Season,
                            record$League,
                            record$EventId,
                            record$Date,
                            record$Arena,
                            record$Attendance,
                            record$HomeTeam,
                            record$AwayTeam))
                
                result <- rbind(result, record)
                keysInData <- append(keysInData, key)
                gameIndex <- gameIndex + 1
              },
              error = function(e){
                # Re-opening the browser
                print("Re-opening the browser...")
                webDr$close()
                webDr$open()
              },
              finally = {
                # Do nothing
              }
            )
          } else {
            print(paste0("Skipped: ", key))
            gameIndex <- gameIndex + 1
          }
        }

        print("Re-opening the browser for the next team...")
        webDr$close()
        webDr$open()
      }
    }
    print(paste0(league, " scraping end..."))
  }
  
  print("Converting dates...")
  result$Date <- bleaguer::GetFullDateString(result$Date, result$Season)

  print("Converting Team IDs...")
  teams <- bleaguer::b.teams[, c("TeamId", "Season", "NameShort")]
  result <- merge(result, teams, by.x = c("Season","HomeTeam"),by.y = c("Season","NameShort"))
  names(result)[names(result) == 'TeamId'] <- 'HomeTeamId'
  result <- merge(result, teams, by.x = c("Season","AwayTeam"),by.y = c("Season","NameShort"))
  names(result)[names(result) == 'TeamId'] <- 'AwayTeamId'

  print("Generating the finale result...")
  result <- result[, c("ScheduleKey",
                       "Season",
                       "EventId",
                       "Date",
                       "Arena",
                       "Attendance",
                       "HomeTeamId",
                       "AwayTeamId")]
  return(result)
}

