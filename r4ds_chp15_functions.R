# Notes from R FOR DATA SCIENCE,
# an O'Reilly guide by Hadley Wickham and Garrett Grolemund
# Availible online at http://r4ds.had.co.nz/
# PART THREE: Program
# Chapter 15: Functions

################### When to Write a Function? ###################
# whenever you've copy pasted a block of code more than twice
df <- tibble::tibble(
  a = rnorm(10),
  b = rnorm(10),
  c = rnorm(10),
  d = rnorm(10)
)
x <- df$a
rng <- range(x, na.rm = TRUE)
(x - rng[1]) / (rng[2] - rng[1])

rescale01 <- function(x) {
  rng <- range(x, na.rm = TRUE)
  (x - rng[1]) / (rng[2] - rng[1])
}
rescale01(c(0,5,10))

# Three steps to creating a new function:
# 1) need to pick a NAME for the function that is descriptive
# 2) List the inputs or arguments to the function inside the function call (ie. function(x, y, etc) )
# 3) Place code you have developed in the body of the function

rescale01(c(-10,0,10))
rescale01(c(1,2,3,NA,5))

# unit testing: formal, automated tests for functions
# http://r-pkgs.had.co.nz/tests.html

# simplify orig example with function
df$a <- rescale01(df$a)
df$b <- rescale01(df$b)
df$c <- rescale01(df$c)
df$d <- rescale01(df$d)

# Exercises
# 2
rescale01 <- function(x) {
  x[x == -Inf] <- 0
  x[x == Inf] <- 1
  rng <- range(x, na.rm = TRUE, finite = TRUE)
  (x - rng[1]) / (rng[2] - rng[1])
}
x <- c(1:10, Inf, -Inf)
rescale01(x)

# 3

mean_noNA <- function(x) {
  mean(is.na(x))
}
mean_noNA(c(3,1,1230,4,238,22,NA,55))

prop <- function(x) {
  x / sum(x, na.rm = TRUE)
}
x <- c(3,1,1230,4,238,22,NA,55)
prop(x)

sd_noNA <- function(x) {
  sd(x, na.rm = TRUE) / mean(x, na.rm = TRUE)
}
sd_noNA(x)

# 5 
x <- c(8,5,7,NA,NA,9,1,NA)
y <- c(NA,1,2,NA,NA,10,100,NA)
both_na <- function(x, y) {
  x2 <- is.na(x)
  y2 <- is.na(y)
  sum(x2&y2)
}
both_na(x, y)

################## Functions are for Humans AND Computers ################## 
# name of a function is important
# names should be verbs or well known nouns (mean())


# Can insert a label with Cmd-Shift-R -------------------------------------

################## Conditional Execution ################## 
if (TRUE) {
  # code
} else {
  # code when false
}

# for help on if type: 'if'
# returns a logical vector describing whether or not each element of vect is named
has_name <- function(x) {
  nms <- names(x)
  if (is.null(nms)) {
    rep(FALSE, length(x))
  } else {
    !is.na(nms) & nms != ""
  }
}


# CONDITIONS --------------------------------------------------------------
# condition must evaluate to true or false, cant be a vector
if (c(TRUE, FALSE)) {}

if (NA) {}

# Can use || (or) and && (and) to combine multiple logical expressions
# these are short-circuiting: as soon as || sees  the first true it stops
# and as soon as && sees the first false it stops
# NEVER use | or & in an if statement: they are vectorized operations that apply
# to multiple values ( work in functions like filter())

# Be careful testing for equality: == is vectorized so easy to get moer than
# one output. Can: check length is already 1, collapse with all() or any()
# or use nonvectorized identical(), which is very strict: always returns 
# a single TRUE or a single FALSE and doesn't coerce typos. Have to be careful
# comparing ints and doubles
identical(0L, 0)
# also need to be wary or floats
x <- sqrt(2) ^ 2
x
x == 2
x - 2
# instead use dplyr::near
dplyr::near(x, 2)
# remember: x == NA doesn't do anything useful


# MULTIPLE CONDITIONS -----------------------------------------------------
# can chain multiple if statments together
if (TRUE) {
  # do this
} else if (FALSE) {
  # do something else
} else {
  # qrn
}

# switch() is good replacement for long string of if statements
operate <- function(x, y, op) {
  switch(op,
         plus = x + y,
         minus = x - y,
         times = x * y,
         divide = x / y,
         stop("Unknown op!")
         )
}
operate(5, 3, "times")
operate(5, 3, "plus")
# cut() can also be useful instead of long chains of ifs

# CODE STYLE --------------------------------------------------------------
# GOOD
if (y < 0 && debug) {
  message("Y is negative")
}

if (y == 0) {
  log(x)
} else {
  y ^ x
}

# BAD
# if (y < 0 && debug)
# message("Y is negative")
# 
# if (y == 0) {
#   log(x)
# }
# else {
#   y ^ x
# }

# Exercises
# 2
library(lubridate)
library(stringr)
greeting <- function() {
  hour <- hour(now())
  good <- "Good "
  
  if (hour < 12) {
    day <- "morning"
  } else if (hour >= 12 && hour < 18) {
    day <- "afternoon"
  } else day <- "evening"
  
  str_c(good, day, ", Human!", sep = "")
}
greeting()

# 3
fizzbuzz <- function(x) {
  if (x %% 3 == 0 && x %% 5 == 0) {
    "fizzbuzz"
  } else if (x %% 5 == 0) {
    "buzz"
  } else if (x %% 3 == 0) {
    "fizz"
  } else x
}
fizzbuzz(15)
# 4
?cut
x <- c(-4, -2, 0, 1, 3, 10, 10, 22, 50)
cut (x, 
     breaks = c(-Inf, 0, 10, 20, 30, Inf), 
     labels = c("freezing", "cold", "cool", "warm", "hot")) %>%
  summary()

################## Function Arguments ################## 
# args either supply data or provide details for computation
# generally, data args should come first
# detail args go on end and should have default values
# specify defaults same way you call a function with a named arg

# compute confidence intervals around mean using normal approx
mean_ci <- function(x, conf = 0.95) {
  se <- sd(x) / sqrt(length(x))
  alpha <-1 - conf
  mean(x) + se * qnorm(c(alpha / 2, 1 - alpha / 2))
}
 
x <- runif(100)    
mean_ci(x)
mean_ci(x, conf = 0.99)

# typically omit the name of the data args bc they are commonly used, but
# should use full name if overriding the deault value of detail arg

# good
mean(1:10, na.rm = TRUE)
# bad
mean(x = 1:10, ,FALSE)
mean(, TRUE, x = c(1:10, NA))

# can refer to an arg by its unique prefix, but generally better to avoid this


# CHOOSING NAMES ----------------------------------------------------------
# generally want longer, more descriptive names, but there are common
# very short names:
# x, y, z: vectors
# w: a vector of weights
# df: a dataframe
# i, j: numeric indices
# n: length of number of rows
# p: number of columns


# CHECKING VALUES ---------------------------------------------------------
# useful to make constraints explicit so you cant accidently call invalid inputs

# functions for computing weighted summary statistics
wt_mean <- function(x, w) {
  sum(x * w) / sum(x)
}
wt_var <- function(x, w) {
  mu <- wt_mean(x, w)
  sum(w * (x - mu) ^ 2) / sum(w)
}
wt_sd <- function(x, w) {
  sqrt(wt_var(x, w))
}
# what happens if x and w are not the same lenght?
wt_mean(1:6, 1:3) # no error due to R's recycling rules

# good practice to check imp preconditions and throw an error with stop() if violated
wt_mean <- function(x, w) {
  if (length(x) != length(w)) {
    stop("'x' and 'w' must be the same length", call. = FALSE)
  }
  sum(x * w) / sum(x)
}

# but be careful not to take too far!
# useful compromise is stopifnot(): checks if each arg is TRUE, produces err is not
# here you assert what should be true rather than checking for what might be wrong
wt_mean <- function(x, w, na.rm = FALSE) {
  stopifnot(is.logical(na.rm), length(na.rm) == 1)
  stopifnot(length(x) == length(w))
  
  if (na.rm) {
    miss <- is.na(x) | is.na(w)
    x <- x[!miss]
    w <- w[!miss]
  }
  
  sum(x * w) / sum(x)
}
wt_mean(1:6, 6:1, na.rm = "foo")

# DOT-DOT-DOT (…) ---------------------------------------------------------
# many funcitons in R take an arbitrary number of inputs
sum(1,2,3,4,5,6,7,8,9,19)
# ... is a useful catch-all if your function wraps another function
# helper functions that wrap around str_c()
commas <- function(...) stringr::str_c(..., collapse = ", ")
commas(letters[1:10])

rule <- function(..., pad = "-") {
  title <- paste0(...)
  width <- getOption("width") - nchar(title) - 5
  cat(title, " ", stringr::str_dup(pad, width), "\n", sep = "")
}
rule("Important output")

# easy to miss typos this way!
sum(1, 2, na.mr = TRUE)

# Args in R are lazily evaluated

# Exercises
# 1 
commas(letters, collapse = "-")

####################### Return Values ####################### 
# When returning a vlaue consider:
# Does returning early make your function easier to read?
# can you make your function pipeable?

# EXPLICIT RETURN STATEMENTS ----------------------------------------------
# VALUE RETURNED  is usualyl the last statement evaluated, but can return early
# using return().
# return early if the inputs are empty
complicated_function <- function(x, y, z) {
  if (lenghts(x) == 0 || length(y) == 0) {
    return(0)
  }
  
  # blah blah blah
  
}
# return early if u have if statement with one complex block and one simple

# WRITING PIPEABLE FUNCTIONS ----------------------------------------------
# return value is v important
# two main types of pipeable functions: transformation and side-effect

# transformation: clear "primary object that is passed in as the first arg,
# and a modified version is returned. ex: dplyr, tidyr

# side-effect: called to perform an action, like drawing a plot or saving a file,
# not transforming. Should invisibly return first arg. 
# ex: prints out the num of missing values in a df
show_missings <- function(df) {
  n <- sum(is.na(df))
  cat("Missing values: ", n, "\n", sep = "")
  
  invisible(df) # means the input df doesnt get printed out but still there
}
show_missings(mtcars)

x <- show_missings(mtcars)
class(x)
dim(x)

# can still use in pipe
mtcars %>%
  show_missings() %>%
  mutate(mpg = ifelse(mpg < 20, NA, mpg)) %>%
  show_missings()
