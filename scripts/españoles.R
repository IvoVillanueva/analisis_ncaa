source("R/helper.R")
source("R/funciones.R")

# Descargar la tabla de jugadores españoles en NCAA
spain_players <-
  read_csv(
   "https://raw.githubusercontent.com/IvoVillanueva/NCAA-ANALISIS/refs/heads/main/data/spain_players.csv",
show_col_types = FALSE
  ) %>%
  mutate(Player = gsub("\\s+", " ", Player),
         Player = ifelse( Player== "Ruben Dominguez", "Rubén Dominguez", Player
        ) %>%
  pull(Player)

spain_players_games <-
  read_csv(
   "https://raw.githubusercontent.com/IvoVillanueva/NCAA-ANALISIS/refs/heads/main/data/spain_players.csv",
show_col_types = FALSE
  ) %>%
  mutate(Player = gsub("\\s+", " ", Player),
         Player = ifelse( Player== "Ruben Dominguez", "Rubén Dominguez", Player) %>%
  select(Player, gm = GP)


# Filtrar y resumir los datos de los jugadores españoles
spain_df <- players_all %>%
  filter(athlete_display_name %in% spain_players) %>%
  summarise(
    across(minutes:points, ~ round(mean(.x, na.rm = TRUE), 1)),
    .by = athlete_display_name
  ) %>%
  drop_na() %>%
  left_join(
    spain_players_games,
    join_by("athlete_display_name" == "Player")
  ) %>%
  relocate(gm, .after = athlete_display_name) %>%
  arrange(desc(points)) %>%
  purrr::set_names(
    nm = c(
      "jug", "par", "min", "fgm", "fga", "tpm", "tpa", "ftm", "fta",
      "ore", "dre", "reb", "asi", "rob", "tap", "per", "fal", "pts"
    )
  )

spain_df_final <- players_all %>%
  filter(athlete_display_name %in% spain_players) %>%
  select(
    jug = athlete_display_name, pos = athlete_position_abbreviation,
    team_display_name, team_logo, athlete_headshot_href
  ) %>%
  unique() %>%
  drop_na() %>%
  left_join(spain_df, join_by(jug)) %>%
  arrange(desc(pts)) %>%
  rename(
    equipo = team_display_name,
    logo_equipo = team_logo,
    foto_jugador = athlete_headshot_href
  )
