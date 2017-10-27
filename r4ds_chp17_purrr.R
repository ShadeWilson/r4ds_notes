# Notes from R FOR DATA SCIENCE,
# an O'Reilly guide by Hadley Wickham and Garrett Grolemund
# Availible online at http://r4ds.had.co.nz/
# PART THREE: Program
# Chapter 17: Iteration with purrr

library(tidyverse)

################ For Loops ################ 
df <- tibble(a = rnorm(10),
             b = rnorm(10),
             c = rnorm(10),
             d = rnorm(10))
# want to compute median of each col. Could copy/paste
median(df$a)
median(df$b) # etc
# instead use for loop
output <- vector("double", ncol(df))
for (i in seq_along(df)) {
  output[[i]] <- median(df[[i]])
}
output

# every for loop has three components:
# output: before you start loop. must allocate sufficient space for the output
#         much faster this way than using c() at each iteration. General way
#         of creating an empy vecotr of given length is vector() function

# sequence: determines what to loop over: each run of the for loop will assign 
#           i to a diff value from seq_along(df) (safe version of 1:length()
#           except if you have a zero length vector it does right thing):
y <- vector("double", 0)
seq_along(y)
1:length(y)

# body: the code that does the work

# Exercises
# 1
# a
mtcars
mean_col <- vector("double", ncol(mtcars))
for (i in seq_along(mtcars)) {
  mean_col[[i]] <- mean(mtcars[[i]])
}
mean_col <- set_names(mean_col, names(mtcars))
mean_col
# b
# type of each col in nycflights13::flights
library(nycflights13)
flight_type <- vector("character", ncol(flights))
for (i in seq_along(flights)) {
  flight_type[[i]] <- typeof(flights[[i]])
}
flight_type <- set_names(flight_type, names(flights))
# c
str(iris)
unique_iris <- vector("integer", ncol(iris))
for (i in seq_along(iris)) {
  unique_iris[[i]] <- length(unique(iris[[i]]))
}
unique_iris
# d
mu <- c(-10, 0, 10, 100)
output <- list(10,10,10,10)
output <- set_names(output, as.character(mu))
for (i in mu) {
  output[[as.character(i)]] <- rnorm(10, mean = i) 
}
(output <- as_tibble(output))
# 2
out <- ""
for (x in letters) {
  out <- stringr::str_c(out, x)
}
out
stringr::str_c(letters, collapse = "")

x <- sample(100)
sd <- 0
for (i in seq_along(x)) {
  sd <- sd + (x[i] - mean(x)) ^ 2
}
sd <- sqrt(sd / (length(x) - 1))
sd
sd(x)

x <- runif(100)
out <- vector("numeric", length(x))
out[1] <- x[1]
for (i in 2:length(x)) {
  out[i] <- out[i - 1] + x[i]
}
out
cumsum(x)
# 3
# a
alice_the_camel <- function() {
  first <- "Alice the camel has "
  end <- "So go, Alice, go."
  
  for (i in 5:0) {
    for (j in 0:2) {
      print(stringr::str_c(first, i, " humps."))
    }
    print(end)
  }
}
alice_the_camel()
# b
ten_bed <- function(x, struct = "bed") {
  for (i in x:1) {
    cat(stringr::str_c("There were", i, "in the", struct, "\n", sep = " "))
    cat("And the little one said,\n")
    if (i > 1) {
      cat('"Roll over"! "Roll over!"\n')
      cat("So they all rolled over and one fell out.\n\n")
    }
    else {
      cat('"Alone at last!"')
    }
  }
}
ten_bed(10, struct = "palace")

################ For Loop Variations ################ 
# four variants on the basic theme of the for loop:
# 1) modifying an existing obj instead of creating a new obj
# 2) looping over names or values, instead of indices
# 3) handling outputs of unknown length
# 4) handing sequences of unknown length

# MODIFYING EXISITING OBJ
df <- tibble(a = rnorm(10),
             b = rnorm(10),
             c = rnorm(10),
             d = rnorm(10))
rescale01 <- function(x) {
  rng <- range(x, na.rm = TRUE)
  (x - rng[1]) / (rng[2] - rng[1])
}
df$a <- rescale01(df$a) # etc
# can redo as:
for (i in seq_along(df)) {
  df[[i]] <- rescale01(df[[1]])
}

# LOOPPING PATTERNS
# 3 basic ways to loop over a vector
# 1) loop over the numeric indices with for (i in seq_along(x))
# 2) loop over elements: for (x in xs). Most useful if you only care about side 
#    effects, bc hard to save outputs
# 3) loop over names: for (nm in names(xs)). Gives you a name, which you can
#    use to access the value with x[[nm]]
#    If creating named output, make sure to name the results vector like so:
results <- vector("list", length(x))
names(results) <- names(x)

# iteration over the numeric indices is the most general form, bc give the position
# you can extract both the name and value
for (i in seq_along(x)) {
  name <- names(x)[[i]]
  value <- x[[i]]
}
name

# UNKNOWN OUTPUT LENGTH
means <- c(0, 1, 2)

output <- double()
for (i in seq_along(means)) {
  n <- sample(100, 1)
  output <- c(output, rnorm(n, means[[i]]))
}
str(output)
# not efficient, this is quadratic (O(n^2)) behavior

# better solution is to save the results in a list, then combine into single
# vector after loop is done using unlist()
out <- vector("list", length(means))
for (i in seq_along(means)) {
  n <- sample(100, 1)
  out[[i]] <- rnorm(n, means[[i]])
}
str(out)
str(unlist(out))
# stricter version of unlist() is purrr::flatten_dbl(), will throw error if
# input isn't a list of doubles

# this pattern occurs elsewhere: if generating a long string, save output
# in a character vector then combine vector into a single string with
# paste(output, collapse = "") or stringr::str_c(output, collapse = "")

# UNKNWON SEQUENCE LENGTH
# use while instead of for loops

# Exercises
# 3
iris
show_mean <- function(x) {
  names <- names(x)
  for (name in names(x)) {
    if (is.numeric(x[[name]])) {
      cat(name, ":\t", mean(x[[name]]), "\n", sep = "")
    }
  }
}
show_mean(mtcars)

################ For Loops Versus Functionals ################ 
# consider again
df <- tibble(a = rnorm(10),
             b = rnorm(10),
             c = rnorm(10),
             d = rnorm(10))
# want to compute mean of every column. # could do with for loop:
output <- vector("double", length(df))
for (i in seq_along(df)) {
  output[[i]] <- mean(df[[i]])
}
output

# if youo do this frequently, can make it into funct
col_mean <- function(df) {
  output <- vector("double", length(df))
  for (i in seq_along(df)) {
    output[[i]] <- mean(df[[i]])
  }
  output
}
col_mean(df)
# now want to do same with median and sd, but not by copy/paste
col_summary <- function(df, fun) {
  out <- vector("double", length(df))
  for (i in seq_along(df)) {
    out[i] <- fun(df[[i]])
  }
  out
}
col_summary(df, mean)

############# The Map Functions ############# 
# map(): list, map_lgl(): logical, map_int(): int, map_dbl(): double, map_chr(): char
# each function takes a vector as input, applies a function and then returns
# a new vector thats the same length and has same names
map_dbl(df, mean)
map_dbl(df, median)
map_dbl(df, sd)

df %>% map_dbl(mean)
df %>% map_dbl(median)
df %>% map_dbl(sd)

# map_*() uses ... to pass along additional args
map_dbl(df, mean, trim = 0.5)
# also preserves names
z <- list(x = 1:3, y = 4:5)
map_int(z, length)

# SHORTCUTS
models <- mtcars %>%
  split(.$cyl) %>%
  map(function(df) lm(mpg ~ wt, data = df))
# can be shortened to using anonymous function shorthand
models <- mtcars %>%
  split(.$cyl) %>%
  map(~lm(mpg ~ wt, data = .))
# get r squared
models %>%
  map(summary) %>%
  map_dbl(~.$r.squared)
# but extracting named components is common so can use (purrr):
models %>%
  map(summary) %>%
  map_dbl("r.squared")
# can also use an integer to select elements by position
x <- list(list(1, 2, 3), list(4, 5, 6), list(7, 8, 9))
x %>% map_dbl(2)

# BASE R has similar functions
# lappy() is basically identical to map(), except map() is consistant with other
# purrr functions and you can use .f shortcuts

# sapply() is a wrapper around lappy() that simplifies output. Good for interactive
# work but is porblematic in a function because you never know what sort of
# output you get
x1 <- list(c(0.27, 0.37, 0.57, 0.91, 0.20),
           c(0.90, 0.94, 0.66, 0.63, 0.06),
           c(0.21, 0.18, 0.69, 0.38, 0.77))
x2 <- list(c(0.50, 0.72, 0.99, 0.38, 0.78),
           c(0.93, 0.21, 0.65, 0.13, 0.27),
           c(0.39, 0.01, 0.38, 0.87, 0.34))
threshold <- function(x, cutoff = 0.8) x[x > cutoff]
x1 %>% sapply(threshold) %>% str()
x2 %>% sapply(threshold) %>% str()

# vapply() is a safe alt to sapply() bc you supply it with an additional arg that
# defines type. Only problem is tha tits a lot of typing:
# vapply(df, is.numeric, logical(1) is equiv to map_lgl(df, is.numeric)
# one advantage of vapply() over purrr's map() is that it can produce matrices
# map function only ever produces vectors

# Exercises
# 1
# a
map_dbl(mtcars, mean)
# b
map_chr(nycflights13::flights, typeof)
# c
iris %>%
  map(length(unique))
map(iris, unique) %>%
  map(length) %>%
  unlist()
# d
mu <- list(-10,0,10,100) %>%
  map(rnorm, n = 10) %>%
  set_names(c("a", "b", "c", "d")) %>%
  as.tibble()
mu
# 2
df
map_lgl(df, is.factor)
# 3
map(1:5, runif)
# 4
map(-2:2, rnorm, n = 5)
map_dbl(-2:2, rnorm, n = 5) # error

############## Dealing with Failure ############## 
# safely() takes a function and returns a modified version
# gives a list with two elements: result and error (NULL is successful)
# like try() in base R
safe_log <- safely(log)
str(safe_log(10))
str(safe_log("a"))

x <-  list(1, 10, "a")
y <- x %>% map(safely(log))
str(y)

# easier if we only had two lists: one with all errors, one with all outputs
# use purrr::transpose()
y <- y %>% transpose
str(y)

is_ok <- y$error %>% map_lgl(is_null)
x[!is_ok] # show what causes erros

y$result[is_ok] %>% flatten_dbl()

# possibly() always succeeds like safely(), simpler too bc you give default value
# to return when there is an error
x <- list(1, 10, "a")
x %>% map_dbl(possibly(log, NA_real_))

# quietly() performs siilar role to safely, but instead of capturing errors,
# it captures printed output, messages, and warnign
x <- list(1, -1)
x %>% map(quietly(log)) %>% str()

# MAPPING OVER MULTIPLE ARGUMENTS -----------------------------------------
# sometimes need to iterate in parallel with map2() and pmap()
# ex: simulate random normals w/ different means
# with map():
mu <- list(5, 10, -3)
mu %>%
  map(rnorm, n = 5) %>%
  str()
# what if you also wanted to vary sd? Could iterate over the indices and index into vects
sigma <- list(1, 5, 10)
seq_along(mu) %>%
  map(~rnorm(5, mu[[.]], sigma[[.]])) %>%
  str()
# but that's confusing code. Instead can use map2() to iterate over two vectors in parallel
map2(mu, sigma, rnorm, n = 5) %>% str()
# note that the args to vary come BEFORE the function; args that are same for every call
# come AFTER

# for multiple args to iterate in parallel, use pmap()
n <- list(1, 3, 5)
args1 <- list(n, mu, sigma)
args1 %>%
  pmap(rnorm) %>%
  str()
# better to name the args, or else pmap uses positional matching in formula
# that means if you switch n and mean by accident, "mean" will be new n and vise versa
args2 <- list(mean = mu, sd = sigma, n = n)
args2 %>%
  pmap(rnorm) %>%
  str()

# since args are all same length, makes sense to store in a df
params <- tribble(
  ~mean, ~sd, ~n,
  5,     1,  1,
  10,     5,  3,
  -3,    10,  5
)
params %>%
  pmap(rnorm)

# INVOKING DIFFERENT FUNCTIONS --------------------------------------------
# can vary functions as well as args
f <- c("runif", "rnorm", "rpois")
param <- list(
  list(min = -1, max = 1),
  list(sd = 5),
  list(lambda = 10)
)
invoke_map(f, param, n = 5) %>% str()
# first args is a list of functions or char vector of function names
# second arg is a list of lists giving the args that vary for each function
# next args are passed to every function

# can use tribble to make easier
sim <- tribble(
  ~f,      ~params,
  "runif", list(min = -1, max = 1),
  "rnorm", list(sd = 5),
  "rpois", list(lambda = 10)
)
sim %>% 
  mutate(sim = invoke_map(f, params, n = 10)) %>%
  str()

# WALK --------------------------------------------------------------------
# alternative to map, use when you want to call a function for its side effects, not return
# ex: render output to screen or save files ot disk
x <- list(1, "a", 3)
x %>% walk(print)
# walk() not that useful compared to walk2() or pwalk()
# ex: if you had a list of plots and a vector of filenames, could use
# pwalk() to save each file to the corresponding location on disk
library(ggplot2)
plots <- mtcars %>%
  split(.$cyl) %>%
  map(~ggplot(., aes(mpg, wt)) + geom_point())
paths <- stringr::str_c(names(plots), ".pdf")

pwalk(list(paths, plots), ggsave, path = tempdir())
# walk(), walk2() and pwalk() all invisibly return .x so CAN use in pipelines

# OTHER PATTERNS OF FOR LOOPS ---------------------------------------------

# PREDICATE FUNCTIONS
# retunr either a single true or false
# keep() and discard() keep elements of the input where the predicate is TRUE or FALSE,
# respectively
iris %>%
  keep(is.factor) %>%
  str()
iris %>%
  discard(is.factor) %>%
  str()

# some() and every() determine if the predicate is true for any or for all of the elements
x <- list(1:5, letters, list(10))
x %>%
  some(is.character)
x %>%
  every(is.character)

# detect() finds the first element where the predicate is true, detect_index() returns its pos
x <- sample(10)
x
x %>%
  detect(~ . > 5)
x %>%
  detect_index(~ . > 5)

# head_while() and tail_while() take elements from the start or end of a vector while
# predicate is true
x %>%
  head_while(~ . > 5)
x %>% tail_while(~ . > 2)

# REDUCE AND ACCUMULATE ---------------------------------------------------
dfs <- list(
  age = tibble(name = "John", age = 30),
  sex = tibble(name = c("John", "Mary"), sex = c("M", "F")),
  trt = tibble(name = "Mary", treatment = "A")
)
dfs %>% reduce(full_join)

# can also find intersection in list of vectors
vs <- list(
  c(1, 3, 5, 6, 10),
  c(1, 2, 3, 7, 8, 10),
  c(1, 2, 3, 4, 8, 9, 10)
)
vs %>% reduce(intersect)
# reduce() takes a binary function (one that takes two args) and applies it repeatedly
# to a list until there is only a single element left

# accumulate is similar but keeps all the interim results
x <- sample(10)
x
x %>% accumulate(`+`)

# Exercises
# 1
x <- list(c(TRUE, F, T, T), T, 3:10)
y <- list(T, F, T, c(T, T, T, F))
my_every <- function(list, is_check) {
  out <- vector("logical", length(list))
  for (i in seq_along(list)) {
    if (is_check(list[[i]]) == FALSE) {
      return(FALSE)
    }
  }
  return(TRUE)
}
my_every(y, is_logical)
# 2
col_summary <- function(df, fun) {
  out <- vector("double", length(df))
  for (i in seq_along(df)) {
    out[i] <- fun(df[[i]])
    print(summary(df[i]))
  }
  out <- set_names(out, names(df))
  out
}
col_summary(mtcars, mean)
# 3
col_sum3 <- function(df, f) {
  is_num <- sapply(df, is.numeric)
  df_num <- df[, is_num]
  
  sapply(df_num, f)
}
df <- tibble(
  x = 1:3, 
  y = 3:1,
  z = c("a", "b", "c"),
  a = 4:6
)
col_sum3(df, mean)

col_sum3(df[1:2], mean)
col_sum3(df[1], mean)
col_sum3(df, mean)
