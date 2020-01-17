library(dplyr)
library(stringr)
library(rvest)
library(RSelenium)

GetWebDriver <- function(serverName, portNumber){
  webDr <- RSelenium::remoteDriver(remoteServerAddr = serverName,
                                   port = portNumber,
                                   browserName = "chrome")
  tryCount <- 1
  tryThreshold <- 60
  isSuccess <- FALSE
  while(tryCount < tryThreshold){
    tryCatch(
      {
        webDr$open()
        isSuccess <- TRUE
        break
      },
        error = function(e){
          print(paste0("Error connecting to Selenium (", tryCount, ")"))
      },
        finally = {
          # Do nothing
        }
    )

    tryCount <- tryCount + 1
    Sys.sleep(0.5)
  }

  if(!isSuccess){
    stop("Failed to connect to Selenium")
  }

  return(webDr)
}

ScrapeGames <- function(webDr){
  season <- "2019-20"
  leagues <- c("B1", "B2")
  scheduleKeys <- subset(b.games, Season == season)$ScheduleKey

  b1.events <- c(2)
  b2.events <- c(7)

  for (league in leagues) {
    # Target relevant events only
    if (league == "B1") {
      events <- subset(b.events, EventId %in% b1.events)
    } else {
      events <- subset(b.events, EventId %in% b2.events)
    }
    # Retrieve teams
    teams <- subset(b.teams, Season == season & League == league)

    for (event_row in seq(1:nrow(events))) {
      # Iterate each event
      event.Id <- events[event_row, ]$EventId
      event.Name <- events[event_row, ]$ShortName
      event.Category <- events[event_row, ]$Category

      for (team_row in seq(1:nrow(teams))) {
        # Iterate each team
        team.Id <- teams[team_row, ]$TeamId
        team.Name <- teams[team_row, ]$NameShort
        url.team <- paste("https://www.bleague.jp/schedule/?",
                          "tab=",
                          gsub("B", "", league),
                          "&year=",
                          substr(season, 0, 4),
                          "&event=",
                          as.character(event.Id),
                          "&club=",
                          as.character(team.Id),
                          sep = "")
        print(url.team)
        webDr$navigate(url.team)
        Sys.sleep(0.5)
        pageSource <- webDr$getPageSource()
        html.team <- read_html(pageSource[[1]], encoding = "utf-8")
        urls.game <- html.team %>%
          html_nodes("#round_list > dd > ul > li > div.gamedata_left > div.data_link > div.state_link.btn.report > a") %>%
          html_attr("href")
        num.games = length(urls.game)
        print(num.games)
        for (url.game in urls.game) {
          startStr <- "ScheduleKey="
          key <- substring(url.game,
                           regexpr(startStr, url.game) + nchar(startStr))

          # Duplicate check
          if (!(key %in% scheduleKeys)) {
            scheduleKeys <- append(scheduleKeys, key)
            webDr$navigate(url.game)
            Sys.sleep(1)
            pageSource2 <- webDr$getPageSource()
            html.game <- read_html(pageSource2[[1]], encoding = "utf-8")

            ########
            # Parsing all the necessary information
            ########
            date <- html.game %>%
              html_nodes("#game__top__inner > div.date_wrap > p:nth-child(2) > span") %>%
              html_text()

            arena <- html.game %>%
              html_nodes("#game__top__inner > div.place_wrap > p.StadiumNameJ") %>%
              html_text()

            attendance <- html.game %>%
              html_nodes("#game__top__inner > div.place_wrap > p.Attendance") %>%
              html_text()

            home <- html.game %>%
              html_nodes("#game__top__inner > div.result_wrap > div.team_wrap.home.win > div.team_name > p.for-sp") %>%
              html_text()
            if (identical(home, character(0))) {
              home <- html.game %>%
                html_nodes("#game__top__inner > div.result_wrap > div.team_wrap.home > div.team_name > p.for-sp") %>%
                html_text()
            }

            away <- html.game %>%
              html_nodes("#game__top__inner > div.result_wrap > div.team_wrap.away.win > div.team_name > p.for-sp") %>%
              html_text()
            if (identical(away, character(0))) {
              away <- html.game %>%
                html_nodes("#game__top__inner > div.result_wrap > div.team_wrap.away > div.team_name > p.for-sp") %>%
                html_text()
            }

            ########
            # Create the result
            ########
            str <- paste(key,
                         season,
                         league,
                         event.Category,
                         event.Name,
                         date,
                         arena,
                         attendance,
                         home,
                         away)
            print(str)

            df.record <- data.frame(
              ScheduleKey = key,
              Season = season,
              League = league,
              EventId = event.Id,
              Date = date,
              Arena = arena,
              Attendance = attendance,
              HomeTeam = home,
              AwayTeam = away
            )

            df.result <- rbind(df.result, df.record)
          }
        }
      }
    }
  }
}

############
# Settings #
############
# Install the latest bleaguer from Github
devtools::install_github("rintaromasuda/bleaguer", force = TRUE)
Sys.setlocale(locale = 'Japanese')

########
# Main #
########
exitStatus <- 0

tryCatch({
  library(bleaguer)
  webDr <- GetWebDriver("localhost", 4444L)
  ScrapeGames(webDr)
},
error = function(e){
  print(e)
  exitStatus <- 1
},
finally = {
  # Remove bleaguer at the end
  remove.packages("bleaguer")
}
)

quit(status = exitStatus)

