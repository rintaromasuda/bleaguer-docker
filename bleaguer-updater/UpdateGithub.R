UpdateGithub <- function(targetSeason){
  library(stringr)
  branchName <- paste0("update/", format(Sys.time(), "%Y%m%d%H%M%S"))

  system("git clone https://github.com/rintaromasuda/bleaguer.git")
  setwd("/bleaguer")
  system(paste("git checkout -b", branchName)

  season <- stringr::str_replace(targetSeason, "-", "")
  targetGamesFile <- paste0("inst/extdata/games_", season, ".csv")
  targetSummaryFile <- paste0("inst/extdata/games_summary_", season, ".csv")
  targetBoxscoreFile <- paste0("inst/extdata/games_boxscore_", season, ".csv")
  
  # system("cat DESCRIPTION > test.txt")
  # system("echo \"tete\" > foo.txt ")
  # system("ls")
  # system("git add .")
  # system("git commit -m \"My comment\"")
  # system("git push --set-upstream origin user/rintarom/test2")
}