# Este script contiene funciones para descargar y consolidar datos de partidos
# de baloncesto universitario masculino desde una API pública de ESPN.

# Cargamos las librerías necesarias
library(tidyverse)
library(httr)
library(httr2)
library(lubridate)
library(jsonlite)

# Función para obtener el calendario de partidos desde la API de ESPN
get_calendar <- function() {
  
  scoreboard_url <- "https://site.api.espn.com/apis/site/v2/sports/basketball/mens-college-basketball/scoreboard"
  
  # Hacemos la petición a la API
  resp <- GET(scoreboard_url)
  
  # Verificamos status
  if (status_code(resp) != 200) {
    warning("Fallo al conectar con API de calendario ESPN")
    return(character(0))
  }
  
  data_raw <- content(resp)
  
  calendario <- pluck(data_raw, "leagues", 1, "calendar") %>% 
    tibble(value = .) %>% 
    unnest(cols = value) %>% 
    mutate(
      # Convertimos a fecha real para poder filtrar fácilmente después
      date_obj = lubridate::ymd_hm(value, tz = "UTC") %>% as_date(),
      # Guardamos el formato string que necesita download_day (YYYYMMDD)
      date_str = format(date_obj, "%Y%m%d")
    ) %>% 
    # Filtramos solo hasta ayer (los partidos de hoy quizás no han terminado)
    filter(date_obj < today()) %>% 
    pull(date_str)
  
  return(calendario)
}

