GetWebDriver <- function(serverName, portNumber){
  library(RSelenium)
  
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
