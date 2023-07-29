
is_image <- function(file) {
  grepl("png$|jpg$", file)
}

is_url <- function(path) {
  grepl("^http", path)
}

url_path <- function(...) {
  paste(..., sep = "/")
}

agnostic_path <- function(...) {
  if (is_url(..1)) return(url_path(...))
  fs::path(...)
}
