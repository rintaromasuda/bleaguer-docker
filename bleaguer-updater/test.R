library(rvest)
library(RSelenium)

GetWebDriver <- function(serverName, portNumber){
  remDr <- RSelenium::remoteDriver(remoteServerAddr = serverName,
                                   port = portNumber,
                                   browserName = "chrome")
  tryCount <- 1
  tryThreshold <- 60
  isSuccess <- FALSE
  while(tryCount < tryThreshold){
    tryCatch({
      remDr$open()
      isSuccess <- TRUE
      break
      },
      error = function(e){
        # Do nothing
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

  return(remDr)
}

# Install the latest bleaguer from Github
devtools::install_github("rintaromasuda/bleaguer", force = TRUE)

########
# Main #
########
exitStatus <- 0

tryCatch({
  library(bleaguer)
  remDr <- GetWebDriver("selenium", 4444L)

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

