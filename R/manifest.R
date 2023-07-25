
#' Read and write manifest files
#'
#' The manifest for a series is a plain text file that lists the files contained
#' within the series.
#'
#' @param series Name of the series (e.g., "series-rosemary")
#' @param origin Location in which to find the series
#' @param destination Location into which a manifest is written
#' @param file File name for the manifest (default is "manifest.csv")
#' @param date Publication date for the series (defaults to current date)
#'
#' @return Tibble containing the manifest data, returned visibly to the user by
#'   \code{manifest_read()} and invisibly by \code{manifest_write()}. The tibble
#'   contains one row per image file in the series, and the following columns:
#'
#' \itemize{
#'   \item \code{series_name} is a string with the series name (e.g., "series-rosemary")
#'   \item \code{series_date} contains the publication date in YYYY-MM-DD format
#'   \item \code{path} specifies the path to the image (e.g., "800/rosemary_001_1000_short-title.png")
#'   \item \code{folder} specifies the directory part of the path (e.g., "800")
#'   \item \code{file_name} specifies the file name part of the path (e.g., "rosemary_001_1000_short-title.png")
#'   \item \code{file_format} specifies the file format for the image (e.g., "png")
#'   \item \code{system_name} specifies the generative art system name (e.g., "rosemary")
#'   \item \code{system_version} specifies the generative art system version identifier (e.g., "001")
#'   \item \code{image_id} specifies the identifier string for the image (e.g., "1000")
#'   \item \code{image_short_title} specifies the short title for the image, or NA (e.g., "short-title")
#'   \item \code{image_long_title} specifies the long title for the image, or NA (e.g., "The Long Title")
#'   \item \code{manifest_version} specifies the version of the manifest format used (currently always 1)
#' }
#'
#'   For \code{manifest_read()} returning this tibble is the only thing it does.
#'   For \code{manifest_write()} the tibble is written to a csv file whose
#'   location is specified using the \code{destination} argument.
#'
#' @details The manifest file is used to document the content of a published art
#' series, and \code{manifest_*()} functions provide tools to work with
#' manifests with a minimum of pain. The typical workflow is expected to be as
#' follows. Once an art series has been finalised and all images have been
#' written into the "local bucket folder", use \code{manifest_write()} to create
#' a manifest file within the local series folder. Once that is done, you can
#' upload the completed series to the "remote bucket folder".
#'
#' Whenever you need to inspect the contents of the now-online series, read the
#' manifest file from the remote bucket using \code{manifest_read()}. As an
#' example, you can use this to programmatically construct an HTML document that
#' displays all images in a series, by calling \code{manifest_read()} within a
#' code chunk in a quarto or R markdown document.
#'
#' This workflow is one in which manifests are constructed locally, published to
#' a remote, and then read from the remote location. For that reason, the
#' default behaviour is that \code{manifest_read()} sets the \code{origin} to
#' \code{bucket_remote_path()}, whereas \code{manifest_write()} sets the
#' \code{origin} and \code{destination} to \code{bucket_local_path()}.
#'
#' @rdname manifest
#' @export
manifest_read <- function(series,
                          origin = bucket_remote_path(),
                          file = "manifest.csv") {
  path <- agnostic_path(origin, series, file)
  readr::read_csv(path, show_col_types = FALSE)
}

#' @rdname manifest
#' @export
manifest_write <- function(series,
                           date = Sys.Date(),
                           origin = bucket_local_path(),
                           destination = bucket_local_path(),
                           file = "manifest.csv") {

  if (is_url(origin)) {
    rlang::abort("cannot construct manifest from remotes")
  }
  if (is_url(destination)) {
    rlang::abort("cannot write manifest to remotes")
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

  name_parts <- strsplit(gsub("\\.[^.]*$", "", file_name), "_")
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
  image_long_title <- gsub("-", " ", image_short_title)

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
    image_long_title = image_long_title,
    manifest_version = 1L
  )
  ord <- order(manifest$system_version, manifest$image_id)
  manifest <- manifest[ord, ]

  readr::write_csv(manifest, fs::path(destination, series, file))
}
