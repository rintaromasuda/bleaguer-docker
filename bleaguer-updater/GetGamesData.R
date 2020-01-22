.ScrapeGamePage <- function(webDr, urlGame){
  webDr$navigate(urlGame)
  Sys.sleep(0.5) # Consider making this event-based
  
  pageSource <- webDr$getPageSource()
  htmlGame <- read_html(pageSource[[1]], encoding = "utf-8")
  
  ########
  # Parsing all the necessary information
  ########
  date <- htmlGame %>%
    html_nodes("#game__top__inner > div.date_wrap > p:nth-child(2) > span") %>%
    html_text()
  
  arena <- htmlGame %>%
    html_nodes("#game__top__inner > div.place_wrap > p.StadiumNameJ") %>%
    html_text()
  arena <- gsub("会場：", "", arena)
  
  attendance <- htmlGame %>%
    html_nodes("#game__top__inner > div.place_wrap > p.Attendance") %>%
    html_text()
  attendance <- as.integer(gsub("人", "", gsub("人数：", "", attendance)))  

  home <- htmlGame %>%
    html_nodes("#game__top__inner > div.result_wrap > div.team_wrap.home.win > div.team_name > p.for-sp") %>%
    html_text()
  if (identical(home, character(0))) {
    home <- htmlGame %>%
      html_nodes("#game__top__inner > div.result_wrap > div.team_wrap.home > div.team_name > p.for-sp") %>%
      html_text()
  }
  
  away <- htmlGame %>%
    html_nodes("#game__top__inner > div.result_wrap > div.team_wrap.away.win > div.team_name > p.for-sp") %>%
    html_text()
  if (identical(away, character(0))) {
    away <- htmlGame %>%
      html_nodes("#game__top__inner > div.result_wrap > div.team_wrap.away > div.team_name > p.for-sp") %>%
      html_text()
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
  b1.events <- c(2)
  b2.events <- c(7)

  keysInData <- subset(bleaguer::b.games, Season == season)$ScheduleKey
    
  for (league in leagues) {
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
        Sys.sleep(0.5) # Consider making this event-based
        pageSource <- webDr$getPageSource()
        htmlTeam <- read_html(pageSource[[1]], encoding = "utf-8")
        
        urlGames <- htmlTeam %>%
          html_nodes("#round_list > dd > ul > li > div.gamedata_left > div.data_link > div.state_link.btn.report > a") %>%
          html_attr("href")
        for (urlGame in urlGames) {
          startStr <- "ScheduleKey="
          key <- substring(urlGame,
                           regexpr(startStr, urlGame) + nchar(startStr))
          
          # Duplicate check
          if (!(key %in% keysInData)) {
            keysInData <- append(keysInData, key)
            record <- .ScrapeGamePage(webDr, urlGame)
            record$ScheduleKey <- key
            record$Season <- season
            record$League <- league
            record$EventId <- eventId
            
            print(paste(record$ScheduleKey,
                        record$Season,
                        record$League,
                        record$EventId,
                        record$Date,
                        record$Arena,
                        record$Attendance,
                        record$HomeTeam,
                        record$AwayTeam))
            
            result <- rbind(result, record)
          }
        }
        break
      }
    }
  }
  
  result$Date <- bleaguer::GetFullDateString(result$Date, result$Season)

  teams <- bleaguer::b.teams[, c("TeamId", "Season", "NameShort")]
  result <- merge(result, teams, by.x = c("Season","HomeTeam"),by.y = c("Season","NameShort"))
  names(result)[names(result) == 'TeamId'] <- 'HomeTeamId'
  result <- merge(result, teams, by.x = c("Season","AwayTeam"),by.y = c("Season","NameShort"))
  names(result)[names(result) == 'TeamId'] <- 'AwayTeamId'
  
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

