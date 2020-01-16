FROM rocker/tidyverse:3.5.2

COPY test.R .

RUN install2.r --error \
      rvest \
      RSelenium

CMD ["Rscript", "test.R"]