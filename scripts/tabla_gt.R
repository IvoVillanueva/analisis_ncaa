source("scripts/españoles.R")
source("R/funciones.R")
source("R/helper.R")


# Crear la tabla gt
spain_df_final %>%
  filter(pts > 2) %>%
  mutate(
    name = word(jug, 1),
    surname = word(jug, 2, -1),
    combo_img = add_photo_frame(logo_equipo, foto_jugador),
    combo_img = map(combo_img, gt::html),
    combo = label_html(name, surname, equipo),
    combo = map(combo, gt::html),
  ) %>%
  select(combo_img, combo, pos, par:pts) %>%
  gt() %>%
  cols_align(
    align = "right",
    columns = c(min:fal)
  ) %>%
  cols_align(
    align = "center",
    columns = c(pts, pos, par)
  ) %>%
  cols_width(
    colums = c(combo) ~ (290),
    columns = c(combo_img) ~ (110),
    columns = c(par, pos) ~ (55),
    columns = everything() ~ px(75)
  ) |>
  cols_label(
    combo_img = "",
    combo = "",
    pos = "POS",
    par = "PJ",
    min = "MIN",
    fgm = "FGM",
    fga = "FGA",
    tpm = "3PM",
    tpa = "3PA",
    ftm = "FTM",
    fta = "FTA",
    ore = "OREB",
    dre = "DREB",
    reb = "REB",
    asi = "AST",
    rob = "STL",
    tap = "BLK",
    per = "PER",
    fal = "PF",
    pts = "PTS"
  ) %>%
  tab_options(
    heading.align = "left",
    heading.border.bottom.style = "none",
    table.border.top.style = "black", # transparent
    table.border.bottom.style = "none",
    column_labels.border.top.style = "none",
    column_labels.border.bottom.color = "black",
    row_group.border.top.style = "none",
    row_group.border.top.color = "black",
    data_row.padding = px(0), # 🔥 quita el espacio vertical
    column_labels.padding = px(0),
    table.font.size = 30,
    footnotes.font.size = 15,
    heading.title.font.weight = "bold",
    column_labels.font.size = 20,
    column_labels.font.weight = "bold",
    source_notes.font.size = 20,
    table_body.hlines.color = "gray90",
    table.font.names = "Oswald",
    table.additional_css = ".gt_table {
                margin-bottom: 40px;
  @import url('https://fonts.googleapis.com/css2?family=Oswald:wght@400;600;700&display=swap');
  @import url('https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/fontawesome.min.css');
  @import url('https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/brands.min.css');
              }"
  ) %>%
  gt_color_rows(pts, palette = c("white", "#009CDE")) %>%
  tab_header(
    title = md("<div style='display: flex; align-items: center;
    justify-content: left; height: 58px; text-align: center; font-weight: 600;
    font-size: 75px;'>
               <span style='text-align:left;'>Españoles en la NCAA</div>"),
    subtitle = md(paste0(
      "<span style='display:block;text-align:left;font-weight:400;color:#8C8C8C;
                     font-size:40px;
      '>Filtrados por puntos por partido | medias al ",
      format(Sys.Date(), format = "%d/%m/%Y"),
      " temporada 25-26</span>"
    ))
  ) %>%
  tab_source_note(source_note = md(caption)) |>
  gtsave("png/ncaaspain.png", vwidth = 3700, vheight = 1500, expand = 300)

