
#' Read a series manifest file
#'
#' @param series Name of the series
#' @param origin Location in which to find the series
#' @param file File name for the manifest
#'
#' @return Tibble containing the manifest data
#' @export
manifest_read <- function(series,
                          origin = bucket_remote_path(),
                          file = "manifest.csv") {
  path <- agnostic_path(origin, series, file)
  readr::read_csv(path, show_col_types = FALSE)
}

#' Write a series manifest file
#'
#' @param series Path to the series directory
#' @param date Publication date for the series
#' @param origin Location in which to find the series
#' @param destination Location into which the manifest is written
#' @param file File name for the manifest
#'
#' @return A tibble
#' @export
manifest_write <- function(series,
                           date = Sys.Date(),
                           origin = bucket_local_path(),
                           destination = bucket_local_path(),
                           file = "manifest.csv") {

  if (is_url(origin)) {
    abort("cannot construct manifest from remotes")
  }
  if (is_url(destination)) {
    abort("cannot write manifest to remotes")
  }

  series_name <- series
  series_date <- date

  path <- fs::dir_ls(
    fs::path(origin, series),
    recurse = TRUE,
    regexp = "jpg$|png$"
  )
  path <- gsub(fs::path(origin, series), "", path)
  path <- gsub("^/", "", path)

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

  readr::write_csv(manifest, fs::path(destination, series, file))
}
