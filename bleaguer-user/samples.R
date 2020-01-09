# Load libraries that are supposed to be installed by Docker
library(bleaguer)
library(dplyr)
library(ggplot2)

# Set Japanese env
Sys.setlocale(locale = 'Japanese')

# Pre-defined objects
b.current.season
b.teams
b.events
b.games
b.games.summary
b.games.boxscore

# Check how many games bleaguer gets at this moment. Please note bleaguer is NOT ALWAYS up-to-date.
GetNumOfGames(season = b.current.season)

# Get standings
GetStanding(season = b.current.season, league = "B1")

# Search a player
SearchPlayer("富樫")

# Get boxscore for a player
GetBoxscore(9055, season = b.current.season)

# Get per-team per-game record. Please note you have 2 records for 1 game since each team has a record for the game.
df <- GetGameSummary()
View(df)

# Summarize example: Get per-team per-season average points and average opponent points
df %>%
  group_by(TeamId) %>%
  mutate(LatestTeamName = last(TeamName)) %>%
  filter(Category == "Regular") %>%
  group_by(TeamId, LatestTeamName, Season) %>%
  summarize(AvgPts = mean(PTS),
            AvgOppPts = mean(Opp.PTS)) %>%
  as.data.frame()

# Visualize example: Boxplot for Offensive Rebound Rate of B1 in the current season
gp <- ggplot() +
  geom_boxplot(data = subset(df, Season == b.current.season &
                               Category == "Regular" &
                               League == "B1"),
               aes(x = TeamName,
                   y = ORR)) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1)
  )
print(gp)
