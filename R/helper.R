# Este script contiene funciones para descargar y consolidar datos de partidos
# de baloncesto universitario masculino desde una API pública de ESPN.

# Cargamos las librerías necesarias
library(tidyverse)
library(httr)
library(httr2)
library(lubridate)
library(jsonlite)
library(rvest)
library(curl)
library(gt)
library(gtExtras)
library(glue)


if (!dir.exists("png")) dir.create("png")



# Información del autor para el pie de gráfico
twitter <- "<span style='color:#000000;font-family: \"Font Awesome 6 Brands\"'>&#xe61a;</span>"
tweetelcheff <- "<span>*@elcheff*</span>"
insta <- "<span style='color:#E1306C;font-family: \"Font Awesome 6 Brands\"'>&#xE055;</span>"
instaelcheff <- "<span>*@sport_iv0*</span>"
github <- "<span style='color:#000000;font-family: \"Font Awesome 6 Brands\"'>&#xF092;</span>"
githubelcheff <- "<span>*IvoVillanueva*</span>"
caption <- glue("**Datos**: *@ESPN* **Gráfico**: *Ivo Villanueva* • {twitter} {tweetelcheff} • {insta} {instaelcheff} • {github} {githubelcheff}")




