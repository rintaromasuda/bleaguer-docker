UpdateGithub <- function(targetSeason, gamesFilePath, summaryFilePath, boxscoreFilePath){
  library(stringr)

  system("ls")
  system("rm -r bleagur")
  system("git clone https://github.com/rintaromasuda/bleaguer.git")
  setwd("/bleaguer")

  branchName <- paste0("update/", format(Sys.time(), "%Y%m%d%H%M%S"))
  print(paste0("Git branch name: ", branchName))

  # Paths to the delta files
  deltaGamesFile <- paste0("../", gamesFilePath)
  deltaSummaryFile <- paste0("../", summaryFilePath)
  deltaBoxscoreFile <- paste0("../", boxscoreFilePath)

  print("Creating header-less delta files.")
  deltaGamesNoHeader <- paste0(deltaGamesFile, ".noheader")
  deltaSummaryNoHeader <- paste0(deltaSummaryFile, ".noheader")
  deltaBoxscoreNoHeader <- paste0(deltaBoxscoreFile, ".noheader")

  # Remove the first/header line from the delta files
  system(paste("tail -n +2", deltaGamesFile, ">", deltaGamesNoHeader))
  system(paste("tail -n +2", deltaSummaryFile, ">", deltaSummaryNoHeader))
  system(paste("tail -n +2", deltaBoxscoreFile, ">", deltaBoxscoreNoHeader))
  
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
  print("Appending the delta files to the files cloned from Github.")
  system(paste("cat", targetGamesFile, " ", deltaGamesNoHeader, ">", outputGamesFile))
  system(paste("cat", targetSummaryFile, " ", deltaSummaryNoHeader, ">", outputSummaryFile))
  system(paste("cat", targetBoxscoreFile, " ", deltaBoxscoreNoHeader, ">", outputBoxscoreFile))

  #system("git add .")
  #system("git commit -m \"bleaguer-updater commit\"")
  #system(paste("git push --set-upstream origin", branchName))
}