FROM rocker/tidyverse:3.5.2

COPY samples.R /home/rstudio/

RUN set -x && \
  apt-get install -y --no-install-recommends \
    fonts-noto-cjk && \
  install2.r --error \
    dplyr \
    ggplot2 && \
  installGithub.r \
    rintaromasuda/bleaguer