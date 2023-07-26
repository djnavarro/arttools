
name <- "my-art-system" # only change this for an entirely new system
version <- "001"        # change to "002" for "my-art-system_002.R", etc
format <- "png"         # png is usually a good choice!

# define common helper functions
source(here::here("source", "common.R"), echo = FALSE)

# define a generative art system using base R only
art_generator <- function(seed) {

  set.seed(seed)

  # specify the output path and message the user
  output <- output_path(name, version, seed, format)
  message("generating art at ", output)

  # generate high-level parameters for this piece
  n <- sample(50:150, size = 1)
  palette <- sample(colours(distinct = TRUE), 10)
  background <- sample(colours(), 1)

  # generate low-level details for this piece
  x_coord <- sample(1:10, size = n, replace = TRUE)
  y_coord <- sample(1:10, size = n, replace = TRUE)
  size <- sample(2 * (1:5), size = n, replace = TRUE)
  color <- sample(palette, size = n, replace = TRUE)
  thickness <- sample(1:3, size = n, replace = TRUE, prob = c(.8, .1, .1))

  # write the image
  op <- par(mar = c(0, 0, 0, 0))
  png(
    filename = output,
    width = 1000,
    height = 1000,
    units = "px"
  )
  plot.new()
  plot.window(xlim = c(0, 11), ylim = c(0, 11))
  points(x = x_coord, y = y_coord, cex = size, col = color, lwd = thickness)
  dev.off()
  par(op)
}

# uncomment this line to run the system five times
# for(seed in 101:105) art_generator(seed)

