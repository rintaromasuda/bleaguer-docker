UpdateGithub <- function(targetSeason, gamesFilePath, summaryFilePath, boxscoreFilePath){
  library(stringr)

  system("ls")
  system("rm -r bleagur")
  system("git clone https://github.com/rintaromasuda/bleaguer.git")
  setwd("/bleaguer")

  branchName <- paste0("update/", format(Sys.time(), "%Y%m%d%H%M%S"))

  # Paths to the delta files
  deltaGamesFile <- paste0("../", gamesFilePath)
  deltaSummaryFile <- paste0("../", summaryFilePath)
  deltaBoxscoreFile <- paste0("../", boxscoreFilePath)

  season <- stringr::str_replace(targetSeason, "-", "")
  gamesFileName <- paste0("games_", season, ".csv")
  summaryFileName <- paste0("games_summary_", season, ".csv")
  boxscoreFileName <- paste0("games_boxscore_", season, ".csv")

  # Paths to the target files in the cloned GIT repository
  targetGamesFile <- paste0("inst/extdata/", gamesFileName)
  targetSummaryFile <- paste0("inst/extdata/", summaryFileName)
  targetBoxscoreFile <- paste0("inst/extdata/", boxscoreFileName)

  # Paths to the output files that can be used for manual check-in to Github
  outputGamesFile <- paste0("../output/", gamesFileName)
  outputSummaryFile <- paste0("../output/", summaryFileName)
  outputBoxscoreFile <- paste0("../output/", boxscoreFileName)
 
  # Appending the delta files to the files in the GIT repository
  system(paste("cat", targetGamesFile, " ", deltaGamesFile, ">", outputGamesFile))
  system(paste("cat", targetSummaryFile, " ", deltaSummaryFile, ">", outputSummaryFile))
  system(paste("cat", targetBoxscoreFile, " ", deltaBoxscoreFile, ">", outputBoxscoreFile))

  #system("git add .")
  #system("git commit -m \"bleaguer-updater commit\"")
  #system(paste("git push --set-upstream origin", branchName))
}