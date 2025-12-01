source("R/funciones.R")

semanas <- get_calendar() %>% 
  tibble(fecha = .) %>%
  mutate(semana = lubridate::isoweek(lubridate::ymd(fecha))) %>%
  arrange(semana)


semanas_df <- players_all %>% 
  left_join(semanas, join_by(date_id == fecha)) 

spain_df <- semanas_df %>%
  filter(athlete_display_name %in% spain_players) %>%
  summarise(
    gm = sum(ifelse(!did_not_play, 1, 0), na.rm = TRUE),
    across(minutes:points, ~ round(mean(.x, na.rm = TRUE), 1)),
    .by = athlete_display_name
  ) %>%
  arrange(desc(points)) %>%
  purrr::set_names(
    nm = c(
      "jug", "par", "min", "fgm", "fga", "tpm", "tpa", "ftm", "fta",
      "ore", "dre", "reb", "asi", "rob", "tap", "per", "fal", "pts"
    )
  )
