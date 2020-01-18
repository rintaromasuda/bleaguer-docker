############
# Settings #
############
# Install the latest bleaguer from Github
devtools::install_github("rintaromasuda/bleaguer", force = TRUE)
Sys.setlocale(locale = 'Japanese')

########
# Load #
########
source("Common.R")
source("GetGamesData.R")

########
# Main #
########
exitStatus <- 0

tryCatch({
  webDr <- GetWebDriver("selenium", 4444L)
  GetGamesData(webDr)
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

