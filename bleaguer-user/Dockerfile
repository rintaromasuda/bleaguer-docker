FROM rocker/tidyverse:3.5.2

# Copy a sample R script
COPY samples.R /home/rstudio/

RUN set -x && \
  apt-get install -y --no-install-recommends \
    # Install Noto fonts to render Japanese
    fonts-noto-cjk && \
  # Install R packages that are always useful for analysis
  install2.r --error \
    dplyr \
    ggplot2 && \
  # Install bleaguer package
  installGithub.r \
    rintaromasuda/bleaguer