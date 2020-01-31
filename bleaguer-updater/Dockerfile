FROM rocker/tidyverse:3.5.2

COPY Main.R .
COPY Common.R .
COPY GetGamesData.R .
COPY GetSummaryData.R .
COPY GetBoxscoreData.R .
COPY UpdateGithub.R .

RUN set -x && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
      git

RUN install2.r --error \
      stringr \
      rvest \
      RSelenium

CMD ["Rscript", "Main.R"]