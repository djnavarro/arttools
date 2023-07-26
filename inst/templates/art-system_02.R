
name <- "art-system" # only change this for an entirely new system
version <- 2         # increment to 3 for "my-art-system_03.R", etc
format <- "png"      # png is usually a good choice!

# define common helper functions
source(here::here("source", "common.R"), echo = FALSE)

# define a generative art system using base R only
art_generator <- function(seed) {

  set.seed(seed)

  # specify the output path and message the user
  output <- output_path(name, version, seed, format)
  message("generating art at ", output)

  # generate high-level parameters for this piece
  n <- sample(80:160, size = 1)
  palette <- sample(colours(distinct = TRUE), 5)

  # generate low-level details for this piece
  x_coord <- sample(1:10, size = n, replace = TRUE)
  y_coord <- sample(1:10, size = n, replace = TRUE)
  size <- sample(6 * (1:5), size = n, replace = TRUE, prob = seq(5, 1, -1))
  color <- sample(palette, size = n, replace = TRUE)

  # write the image
  op <- par(mar = c(0, 0, 0, 0))
  png(
    filename = output,
    width = 1000,
    height = 1000,
    units = "px",
    bg = "black"
  )
  plot.new()
  plot.window(xlim = c(0, 11), ylim = c(0, 11))
  points(
    x = x_coord,
    y = y_coord,
    cex = size,
    col = color,
    bg = color,
    lwd = 1,
    pch = 22
  )
  dev.off()
  par(op)
}

# uncomment this line to run the system five times
# for(seed in 201:205) art_generator(seed)

