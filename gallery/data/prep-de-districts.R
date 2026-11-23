# Prepare the data for gallery/bivariate-germany.qmd. Run once, from gallery/:
#
#   Rscript data/prep-de-districts.R
#
# Writes two small files that the page reads at render time, so the page never
# downloads anything itself:
#
#   data/de-districts.geojson    400 German districts (NUTS 3, 2024 boundaries)
#   data/de-districts.csv        GDP per inhabitant and median age per district
#
# Sources (both Eurostat, both free to reuse with attribution):
#   * Boundaries: GISCO, NUTS 2024, 1:10 million, EPSG:4326
#     https://ec.europa.eu/eurostat/web/gisco/geodata/statistical-units/territorial-units-statistics
#     (c) EuroGeographics for the administrative boundaries
#   * GDP per inhabitant, EUR, current prices: table nama_10r_3gdp (unit EUR_HAB)
#     https://ec.europa.eu/eurostat/databrowser/view/nama_10r_3gdp/default/table
#   * Median age of the population: table demo_r_pjanind3 (indic_de MEDAGEPOP)
#     https://ec.europa.eu/eurostat/databrowser/view/demo_r_pjanind3/default/table
#
# Needs sf and jsonlite (both already used elsewhere in the gallery).

year <- "2023"

eurostat <- function(table, filter) {
  url <- sprintf(
    "https://ec.europa.eu/eurostat/api/dissemination/statistics/1.0/data/%s?format=JSON&lang=EN&geoLevel=nuts3&time=%s&%s",
    table, year, filter
  )
  j <- jsonlite::fromJSON(url)
  geo <- j$dimension$geo$category$index
  geo <- names(geo)[order(unlist(geo))]
  val <- rep(NA_real_, length(geo))
  idx <- as.integer(names(j$value)) + 1L
  val[idx] <- unlist(j$value)
  data.frame(nuts_id = geo, value = val)
}

gdp <- eurostat("nama_10r_3gdp", "unit=EUR_HAB")
age <- eurostat("demo_r_pjanind3", "indic_de=MEDAGEPOP")
names(gdp)[2] <- "gdp_per_inhabitant"
names(age)[2] <- "median_age"

geo <- sf::st_read(
  "https://gisco-services.ec.europa.eu/distribution/v2/nuts/geojson/NUTS_RG_10M_2024_4326_LEVL_3.geojson",
  quiet = TRUE
)
geo <- geo[geo$CNTR_CODE == "DE", c("NUTS_ID", "NAME_LATN")]
names(geo)[1:2] <- c("nuts_id", "name")

ind <- merge(gdp, age, by = "nuts_id")
ind <- ind[ind$nuts_id %in% geo$nuts_id, ]
ind <- merge(sf::st_drop_geometry(geo), ind, by = "nuts_id", all.x = TRUE)
ind$year <- as.integer(year)
stopifnot(nrow(ind) == nrow(geo), !anyNA(ind$gdp_per_inhabitant), !anyNA(ind$median_age))

dir.create("data", showWarnings = FALSE)
write.csv(ind, "data/de-districts.csv", row.names = FALSE)
sf::st_write(geo, "data/de-districts.geojson", delete_dsn = TRUE, quiet = TRUE,
             layer_options = "COORDINATE_PRECISION=4")
