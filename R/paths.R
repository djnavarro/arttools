
#' Paths to object buckets and repositories
#'
#' @param path Name of the series or a path to a subfolder within it
#'
#' @return Fully qualified path or url
#' @rdname paths
#' @export
bucket_remote_path <- function(path = NULL) {
  base <- getOption("arttools.bucket.remote")
  if (!is.null(path)) base <- paste(base, path, sep = "/")
  base
}

#' @rdname paths
#' @export
bucket_local_path <- function(path = NULL) {
  base <- getOption("arttools.bucket.local")
  if (!is.null(path)) base <- fs::path(base, path)
  fs::path_expand(base)
}

#' @rdname paths
#' @export
repo_remote_path <- function(path = NULL) {
  base <- getOption("arttools.repos.remote")
  if (!is.null(path)) base <- paste(base, path, sep = "/")
  base
}

#' @rdname paths
#' @export
repo_local_path <- function(path = NULL) {
  base <- getOption("arttools.repos.local")
  if (!is.null(path)) base <- fs::path(base, path)
  fs::path_expand(base)
}

is_url <- function(path) {
  grepl("^http", path)
}

agnostic_path <- function(...) {
  if (is_url(..1)) return(paste(..., sep = "/"))
  fs::path(...)
}
