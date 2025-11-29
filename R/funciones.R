# Función para descargar los datos de jugadores desde el repositorio de GitHub
source("R/helper.R")

token <- Sys.getenv("NCAA_TOKEN")




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


# Descargar los datos de jugadores
res_players <- list()

for (i in get_calendar()) {
  
  
  players <- request(
    glue::glue("https://raw.githubusercontent.com/IvoVillanueva/ncaa-boxscore/refs/heads/main/data/players/players_{i}.csv")
  ) |>
    req_headers(Authorization = paste("token", token)) |>
    req_perform() |>
    resp_body_string() |>
    readr::read_csv(show_col_types = FALSE) %>% 
    mutate(athlete_jersey = ifelse(athlete_jersey == as.numeric(athlete_jersey), as.character(athlete_jersey), athlete_jersey))
  
  res_players[[i]] <- players
  
  message("Descargado dia " , i)
}

players_all <- dplyr::bind_rows(res_players, .id = "date_id")




# Configuración del manejador de curl con User-Agent y cookies
ua <- "Mozilla/5.0 (...) Safari/537.36"
h <- new_handle()
handle_setheaders(h,
                  "User-Agent" = ua,
                  "Referer" = "https://basketball.realgm.com/"
)
handle_setopt(h, cookiefile = "", cookiejar = "cookies.txt", http_version = 2L)

# Función para obtener y parsear una página de RealGM
get_realgm <- function(url) {
  curl_fetch_memory("https://basketball.realgm.com/", handle = h)
  res <- curl_fetch_memory(url, handle = h)
  read_html(res$content)
}


# etiqueta html para la foto del jugador con el logo del equipo detrás
add_photo_frame <- function(logo_equipo, foto_jugador) {
  glue::glue("
    <div style='
      position: relative;
      width: 110px;
      height: 110px;
      margin: 0;
      padding: 0;
      overflow: hidden;
    '>

      <!-- LOGO DETRÁS (perspectiva), z-index bajo -->
      <div style='
        position: absolute;
        top: 20px;            /* ajusta para que asome a la altura que quieras */
        right: 20px;           /* cuánto asoma por la izquierda */
        width: 92px;
        height: 92px;
        perspective: 50px;
        z-index: 1;          /* detrás */
        opacity: 0.98;
      '>
        <img src='{logo_equipo}' style='
          width: 100%;
          height: 100%;
          transform: rotateY(44deg);
          transform-origin: left center;
          backface-visibility: hidden;
          display: block;
        '/>
      </div>

      <!-- FOTO DEL JUGADOR ENCIMA y pegada al borde inferior
           desplazada a la derecha para que el logo asome por la izquierda -->
      <img src='{foto_jugador}' style='
        position: absolute;
        bottom: 0;
        left: 8px;               /* desplaza la foto a la derecha: el logo asoma por la izda */
        width: 100% ; /* rellena el espacio restante */
        height: auto;
        object-fit: cover;
        object-position: bottom center;
        z-index: 2;               /* encima del logo */
        margin: 0;
        padding: 0;
        display: block;
      '/>

    </div>
  ")
}

# etiqueta html para el nombre del jugador y equipo
label_html <- function(name, surname, equipo) {
  glue::glue("
    <div style='line-height: 1; margin-bottom: -4px; text-align: left;'>
      <span style='font-size: 30px; font-weight: 400; color: #000000;'>
        {name }
      </span>
      <span style='font-size: 30px; font-weight: 700; color: #000000;'>
        {surname}
      </span>
      <br>
      <span style='font-size: 26px; font-weight: 400; color: #AAAAAA;'>
        {equipo}
      </span>
    </div>
  ")
}
