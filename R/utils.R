
# this is a very limited tool by design
is_image <- function(file) {
  grepl("png$|jpg$", file)
}

is_url <- function(path) {
  grepl("^http", path)
}

agnostic_path <- function(...) {
  if (is_url(..1)) return(paste(..., sep = "/"))
  fs::path(...)
}
