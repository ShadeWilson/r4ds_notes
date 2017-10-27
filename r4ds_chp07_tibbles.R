# Notes from R FOR DATA SCIENCE,
# an O'Reilly guide by Hadley Wickham and Garrett Grolemund
# Availible online at http://r4ds.had.co.nz/
# PART TWO: Wrangle
# Chapter 7: Tibbles with tibble

# tibbles are datefrmaes but they tweak some of the older behaviors to make life a littel easier

vignette("tibble")

library(tidyverse)

# convert a datafrmae into a tibble with as_tibble()
as_tibble(iris)
# can create a new tibble from indiv vectors with tibble()
tibble(x = 1:5,
       y = 1,
       z = x^2 + y)
# tibble never changes the type of inputs, never changes the names of variables, 
# and never creates row names

# its possible for a tibble to have column bnmaes that are not valid variable names
# to refer to these, need to surround them with backticks ('')
tb <- tibble(
  ':)' = "smile",
  ' ' = "space",
  '2000' = "number"
)
tb

# tribble: transposed tibble is customize for data entry in code:
# column headings are defined by formulas (ie. start with ~) and entries
# are separated by columns
tribble(
  ~x, ~y, ~z,
  "a", 2, 3.6,
  "b", 1, 8.5
)

############### Tibbles vs. data.frame #################
# Two main differences: printing and subsetting

# Printing:
# tibbles have a refined print method that shows only the first 10 rows 
# and all columns that fit on screen. In addition to name, each column reports type,
# a feature borrowed from str()
tibble(
  a = lubridate::now() + runif(1e3) * 86400,
  b = lubridate::today() + runif(1e3) * 30,
  c = 1:1e3,
  d = runif(1e3),
  e = sample(letters, 1e3, replace = TRUE)
)

# Tibbles are designed so you don't accidentally overwhelm your computer
# But sometimes you need more output than the default display

# can explicitly print() the df and control number of rows(n). width = Inf will display all columns
nycflights13::flights %>%
  print(n = 10, width = Inf)

# can also control the default print behavior by setting options
# options(tibble.print_max = n, tibble.print_min = m):
# if more than m rows, print only n rows. Use options(diplyr.print_min = Inf) to always show all rows
# use options(tibble.width = Inf) to always print all columns, regardless of width of screen

package?tibble

# final option is to use RStudio's built-in data viewer: View()
nycflights13::flights %>%
  View()

# Subsetting
df <- tibble(
  x = runif(5),
  y = rnorm(5)
)
# extract by name
df$x
df[["x"]]

# extract by position
df[[1]]

# need a special placeholder to use these in a pipe
df %>% .$x
df %>% .[["x"]]

# tibbles are more strict than a data.frame: they never do partial matching and generate
# a warning if trying to raech column that DNE

# some older functions dont work with tibble.
# If encountered, use as.data.frame() to turn a tibble back to a data.frame