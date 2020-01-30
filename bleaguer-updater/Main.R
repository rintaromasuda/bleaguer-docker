############
# Settings #
############
# Install the latest bleaguer from Github
devtools::install_github("rintaromasuda/bleaguer", force = TRUE)

Sys.setlocale(locale = 'Japanese')
print(paste0("Working Dir: ", getwd()))
system("ls")

targetSeason <- Sys.getenv("SEASON")
hostName <- Sys.getenv("WEBDRHOSTNAME")
print(paste0("SEASON=", targetSeason))
print(paste0("WEBDRHOSTNAME=", hostName))

########
# Load #
########
source("Common.R")
source("GetGamesData.R")
source("GetSummaryData.R")
source("GetBoxscoreData.R")
source("UpdateGithub.R")

########
# Main #
########
exitStatus <- 0
gamesFilePath <- "delta/games.csv"
summaryFilePath <- "delta/summary.csv"
boxscoreFilePath <- "delta/boxscore.csv"

tryCatch({
  webDr <- GetWebDriver(hostName, 4444L)

  print("######################")
  print("# Get data for games #")
  print("######################")
  dataGames <- GetGamesData(webDr, targetSeason)
  if(nrow(dataGames) <= 0)
  {
    stop("No game to be processed.")
  }
  print(head(dataGames))
  write.csv(dataGames, gamesFilePath, fileEncoding = "UTF-8", row.names = FALSE, quote = FALSE)
  
  print("########################")
  print("# Get data for summary #")
  print("########################")
  dataSummary <- GetSummaryData(webDr, dataGames)
  print(head(dataSummary))
  write.csv(dataSummary, summaryFilePath, fileEncoding = "UTF-8", row.names = FALSE, quote = FALSE)

  print("#########################")
  print("# Get data for boxscore #")
  print("#########################")
  dataBoxscore <- GetBoxscoreData(webDr, dataGames)
  print(head(dataBoxscore))
  write.csv(dataBoxscore, boxscoreFilePath, fileEncoding = "UTF-8", row.names = FALSE, quote = FALSE)
  
  webDr$close()

  print("#################")
  print("# Update Github #")
  print("#################")
  UpdateGithub(targetSeason);

  print("###################################")
  print("# Finished updating bleaguer data #")
  print("###################################")
},
error = function(e){
  print(e)
  exitStatus <- 1
},
finally = {
  # Remove bleaguer at the end so that next time you can install it again
  remove.packages("bleaguer")
}
)

quit(status = exitStatus)

