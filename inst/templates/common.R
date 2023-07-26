# Use this file for simple helper functions that aren't really part of the
# system itself. I usually only include functions that help me manage the
# file names and paths for output images. Note that this takes a dependency
# on the here package

here_exists <- require("here", quietly = TRUE)
if (!here_exists) {
  message("common.R uses the 'here' package: you may need to install it")
}

output_file <- function(system_name,
                        system_version,
                        image_id,
                        file_format,
                        pattern = "[[:space:]._]+",
                        replacement = "-",
                        separator = "_") {

  # make sure we don't have whitespace, dots, or underscores
  # within each of the constituent parts of the file name
  system_name <- gsub(pattern, replacement, as.character(system_name))
  system_version <- gsub(pattern, replacement, as.character(system_version))
  file_format <- gsub(pattern, "", as.character(file_format))

  # paste the consituents together
  file_name <- paste(system_name, system_version, image_id, sep = separator)

  # append file format and return
  paste(file_name, file_format, sep = ".")
}

output_path <- function(system_name,
                        system_version,
                        image_id,
                        file_format,
                        pattern = "[[:space:]._]+",
                        replacement = "-",
                        separator = "_") {

  # construct the file name
  file_name <- output_file(
    system_name,
    system_version,
    image_id,
    file_format,
    pattern,
    replacement,
    separator
  )

  # specify the path to the relevant output folder, creating it if necessary
  system_version <- gsub(pattern, replacement, as.character(system_version))
  output_dir <- here::here("output", system_version)
  if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

  # return fully qualified path
  file.path(output_dir, file_name)
}
