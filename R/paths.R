

#' Paths to object buckets and repositories
#'
#' @param path Name of the series or a path to a subfolder within it
#'
#' @return Fully qualified path or url
#' @rdname paths
#' @export
bucket_remote_path <- function(path = NULL) {
  base <- getOption("arttools.bucket.remote")
  paste(base, path, sep = "/")
}

#' @rdname paths
#' @export
bucket_local_path <- function(path = NULL) {
  base <- getOption("arttools.bucket.local")
  fs::path_expand(fs::path(base, path))
}

#' @rdname paths
#' @export
repo_remote_path <- function(path = NULL) {
  base <- getOption("arttools.repos.remote")
  paste(base, path, sep = "/")
}

#' @rdname paths
#' @export
repo_local_path <- function(path = NULL) {
  base <- getOption("arttools.repos.local")
  fs::path_expand(fs::path(base, path))
}



