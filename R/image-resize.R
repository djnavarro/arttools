
#' Create resized copies of all images in a directory
#'
#' @param series Path to the series directory description
#' @param input_folder Folder within the series containing original images
#' @param output_folder Folder within the series to contain resized images
#' @param pixels_wide Width of output images in pixels
#' @param pixels_high Height of output images in pixels description
#'
#' @return Invisibly returns NULL. This may change
#' @export
create_resized_images <- function(series,
                                  input_folder,
                                  output_folder,
                                  pixels_wide,
                                  pixels_high = pixels_wide) {
  image_file_names <- fs::path_file(fs::dir_ls(fs::path(series, input_folder)))
  fs::dir_create(fs::path(series, output_folder))
  lapply(image_file_names, function(image) {
    create_resized_image(
      fs::path(series, input_folder, image),
      fs::path(series, output_folder, image),
      pixels_wide,
      pixels_high
    )
  })
  invisible(NULL)
}

create_resized_image <- function(input_image,
                                 output_image,
                                 pixels_wide,
                                 pixels_high = pixels_wide) {
  geometry <- magick::geometry_size_pixels(
    width = pixels_wide,
    height = pixels_wide
  )
  img <- magick::image_read(input_image)
  img <- magick::image_resize(img, geometry)
  magick::image_write(img, path = output_image)
  rm(img)
  gc()
  cli::cli_alert_success(paste(output_image, "created"))
}
