write_manifest <- function(dir, date) {

  paths <- list.files(dir, recursive = TRUE) |>
    stringr::str_subset("jpg$|png$")

  manifest <- tibble::tibble(path = paths) |>
    tidyr::separate(
      col = path,
      into = c("resolution", "filename"),
      sep = "/",
      remove = FALSE
    ) |>
    tidyr::separate(
      col = filename,
      into = c("filespec", "format"),
      sep = "\\."
    ) |>
    tidyr::separate(
      col = filespec,
      into = c("series", "sys_id", "img_id"),
      sep = "_"
    ) |>
    dplyr::mutate(
      resolution = as.integer(resolution),
      date = date
    ) |>
    dplyr::arrange(date, img_id)

  readr::write_csv(manifest, fs::path(dir, "manifest.csv"))

}
