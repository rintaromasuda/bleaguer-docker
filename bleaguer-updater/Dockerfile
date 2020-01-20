FROM rocker/tidyverse:3.5.2

COPY Main.R .
COPY Common.R .
COPY GetGamesData.R .
COPY GetSummaryData.R .

RUN set -x && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
      git

RUN install2.r --error \
      rvest \
      RSelenium

CMD ["Rscript", "Main.R"]