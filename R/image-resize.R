
#' Create resized copies of all images in a directory
#'
#' @param series Name of the series
#' @param images_from Folder within the series containing original images
#' @param images_to Folder within the series to contain resized images
#' @param pixels_wide Width of output images in pixels
#' @param pixels_high Height of output images in pixels description
#' @param origin Location in which to find the series
#'
#' @return Invisibly returns NULL. This may change
#' @export
create_resized_images <- function(series,
                                  images_from,
                                  images_to,
                                  pixels_wide,
                                  pixels_high = pixels_wide,
                                  origin = bucket_local_path()) {
  base <- fs::path(origin, series)
  file_paths <- fs::dir_ls(fs::path(base, images_from))
  file_names <- fs::path_file(file_paths)
  fs::dir_create(fs::path(base, images_to))
  lapply(file_names, function(file) {
    create_resized_image(
      fs::path(base, images_from, file),
      fs::path(base, images_to, file),
      pixels_wide,
      pixels_high
    )
  })
  invisible(NULL)
}

create_resized_image <- function(input_path,
                                 output_path,
                                 pixels_wide,
                                 pixels_high = pixels_wide) {
  geometry <- magick::geometry_size_pixels(
    width = pixels_wide,
    height = pixels_wide
  )
  img <- magick::image_read(input_path)
  img <- magick::image_resize(img, geometry)
  magick::image_write(img, path = output_path)
  rm(img)
  gc()
  cli::cli_alert_success(paste(output_path, "created"))
}
