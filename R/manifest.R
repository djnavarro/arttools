
#' Write a manifest file
#'
#' @param series Path to the series directory
#' @param date Publication date for the series
#'
#' @return A tibble
#' @export
create_manifest <- function(series, date = Sys.Date()) {

  series_name <- fs::path_split(series)[[1]]
  series_name <- series_name[length(series_name)]
  series_date <- date

  path <- fs::dir_ls(series, recurse = TRUE, regexp = "jpg$|png$")
  folder = fs::path_dir(path)
  file_name = fs::path_file(path)
  file_format = fs::path_ext(path)

  name_parts <- strsplit(file_name, "_")
  num_name_parts <- vapply(name_parts, length, 1L)
  if (any(num_name_parts < 3L | num_name_parts > 4L)) {
    rlang::abort("image file names must have 3 or 4 parts")
  }

  system_name <- vapply(name_parts, function(x) x[1], "")
  system_version <- vapply(name_parts, function(x) x[2], "")
  image_id <- vapply(name_parts, function(x) x[3], "")
  image_short_title <- NA_character_
  titled_images <- num_name_parts == 4L
  image_short_title[titled_images] <- vapply(
    name_parts[titled_images],
    function(x) x[4],
    ""
  )

  manifest <- tibble::tibble(
    series_name = series_name,
    series_date = series_date,
    path = path,
    folder = folder,
    file_name = file_name,
    file_format = file_format,
    system_name = system_name,
    system_version = system_version,
    image_id = image_id,
    image_short_title = image_short_title,
    manifest_version = 1L
  )
  ord <- order(manifest$system_version, manifest$image_id)
  manifest <- manifest[ord, ]
  #readr::write_csv(manifest, fs::path(dir, "manifest.csv"))
  manifest
}
