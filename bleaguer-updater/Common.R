g_serverName <- ""
g_portNumber <- 0
g_failedSummary <- c()
g_failedBoxscore <- c()

GetWebDriver <- function(){
  library(RSelenium)
  
  webDr <- RSelenium::remoteDriver(remoteServerAddr = g_serverName,
                                   port = g_portNumber,
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