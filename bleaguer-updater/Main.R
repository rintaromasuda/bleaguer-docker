############
# Settings #
############
# Install the latest bleaguer from Github
devtools::install_github("rintaromasuda/bleaguer", force = TRUE)

Sys.setlocale(locale = 'Japanese')
print(paste0("Working Dir: ", getwd()))

########
# Load #
########
source("Common.R")
source("GetGamesData.R")
source("GetSummaryData.R")

########
# Main #
########
exitStatus <- 0

tryCatch({
  webDr <- GetWebDriver("selenium", 4444L)
  
  #dataGames <- GetGamesData(webDr, "2019-20")
  #print(head(dataGames))
  #write.csv(dataGames, "games.csv", fileEncoding = "UTF-8", row.names = FALSE, quote = FALSE)
  
  #dataSummary <- GetSummaryData(webDr, dataGames$ScheduleKey)
  #print(head(dataSummary))
  #write.csv(dataSummary, "summary.csv", fileEncoding = "UTF-8", row.names = FALSE, quote = FALSE)

  #dataBoxscore <- GetBoxscoreData(webDr, dataGames$ScheduleKey)
  #print(head(dataBoxscore))
  #write.csv(dataBoxscore, "boxscore.csv", fileEncoding = "UTF-8", row.names = FALSE, quote = FALSE)
  
  webDr$close()

  system("git clone https://github.com/rintaromasuda/bleaguer.git")
  setwd("/bleaguer")
  system("git checkout -b user/rintarom/test2")
  system("cat DESCRIPTION > test.txt")
  system("echo \"tete\" > foo.txt ")
  system("ls")
  system("git add .")
  system("git commit -m \"My comment\"")
  system("git push --set-upstream origin user/rintarom/test2")
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

