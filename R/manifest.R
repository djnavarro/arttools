create_manifest <- function(series_dir, date = Sys.Date()) {

  series_name <- fs::path_split(series_dir)[[1]]
  series_name <- series_name[length(series_name)]

  manifest <- tibble::tibble()
  manifest$series_name <- series_name
  manifest$series_date <- date
  manifest$path <- fs::dir_ls(series_dir, recurse = TRUE, regexp = "jpg$|png$")
  manifest$folder = fs::path_dir(manifest$path)
  manifest$file_name = fs::path_file(manifest$path)
  manifest$format = fs::path_ext(manifest$path)

  name_parts <- strsplit(manifest$file_name, "_")
  num_name_parts <- vapply(name_parts, length, 1L)
  if (any(num_name_parts < 3L | num_name_parts > 4L)) {
    rlang::abort("image file names must have 3 or 4 parts")
  }

  manifest$system_name <- vapply(name_parts, function(x) x[1], "")
  manifest$system_version <- vapply(name_parts, function(x) x[2], "")
  manifest$image_id <- vapply(name_parts, function(x) x[3], "")
  manifest$image_short_title <- NA_character_
  titled_images <- num_name_parts == 4L
  manifest$image_short_title[titled_images] <- vapply(
    name_parts[titled_images],
    function(x) x[4],
    ""
  )

  ord <- order(manifest$system_version, manifest$image_id)
  manifest <- manifest[ord, ]

  manifest$manifest_version <- 1L

  #readr::write_csv(manifest, fs::path(dir, "manifest.csv"))
  manifest
}
