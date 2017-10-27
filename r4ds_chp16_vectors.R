# Notes from R FOR DATA SCIENCE,
# an O'Reilly guide by Hadley Wickham and Garrett Grolemund
# Availible online at http://r4ds.had.co.nz/
# PART THREE: Program
# Chapter 16: Vectors

library(tidyverse)

# Two types of vectors:
# ATOMIC vectors (six): logical, integer, double, character, complex, raw
# int and dbl are known together as numeric vectors
# LISTS aka recursive vectors bc lists can contain other lists

# main difference b/w atomic vectors and lists is that stomic vectors are
# homogeneous while lists can be heterogeneous
# Also NULL represents the absence of a vector while NA represents the abs of
# a VALUE of a vector

# every vector has two key properties
# TYPE, can determine with typeof():
typeof(letters)
typeof(1:10)
# LENGTH, can determine with length()
x <- list("a", "b", 1:10)
length(x)

# vectors can also has arbitrary metadata in the form of attributes: augmented vectors
# Four types of augmented vectors:
# 1) factors are built on top of integer values
# 2) dates and date-times aer built on top of numeric vectors
# 3) df's and tibbles are built on top of lists

############### Important Types of Atomic Vector ############### 

# LOGCIAL
# can only take three values: TRUE, FALSE, NA
# constructed with comparison operators, can also create by hand with c()
1:10 %% 3 == 0
c(TRUE, T, FALSE, NA)

# NUMERIC
# ints, doubles == numeric
# in R, numbers are doubles by default. Place L after num to make int
typeof(1)
typeof(1L)
1.5L

# Note: doubles are approximations. use near() instead of == for comparison
# ints have one special values, NA, while doubles have four: NA, NaN, Inf, and -Inf
# all can arise during division
c(-1, 0, 1) / 0
# avoid using == to check for these other special values. Instead use is.finite(),
# is.infinite(), and is.nan()

# CHARACTER
# each element of a char vect is a string, and a string can have an arbitrary amt 
# of data

# R uses a global string pool, meaning that each unique string is only stored
# in memory once, and every use of the string points to that representation
# reduces the amt of memory needed by duplicate strings. see w/ pryr::object_size()
x <- "This is a reasonably long string"
pryr::object_size(x)
y <- rep(x, 1000)
pryr::object_size(y) # pointers are only 8 bytes each

# MISSING VALUES
# each type of atomic vector has its own missing value
NA
NA_integer_
NA_real_
NA_character_

# Exercises
near
readr::parse_logical()

#################### Using Atomic Vectors #################### 


# COERSION ----------------------------------------------------------------
# Two ways to convert/coerce one type of vector to another
# 1) explicit coersion happens when you call a function like as.logical(), 
#    as.integer(), etc. Always check if you can avoid this upstream if using this
#    ex: tweak readr col_types specification
# 2) implicit coercion happens when you use a vcetor in a specific context that 
#    expects a certain type of vector. EX: when you use a logical vector
#    with a numeric sum function

# sum of logical vector is number of trues
x <- sample(20, 100, replace = TRUE)
y <- x > 10
sum(y) # how many are greater than 10?
mean(y) # what proportion are greater than 10?

# when trying to create a vector containing multiple types with c(), 
# the most complex one wins
typeof(c(TRUE, 1L))
typeof(c(1L, 1.5))
typeof(c(1.5, "a"))

# TEST FUNCTIONS: better to use purrr::is_* test functions than base
# all versions come with is_scalar_* to test if length is one

############## Scalars and Recycling Rules ############## 
# R will implicitly coerce the length of vecotrs, called vector recycling
# shorter vector is repeated (or recycled) to the same length as the longer vector

# most useful when you are mixing factors and "scalars" (aka single num, length 1)
# most built in functions are vectorized, will operate on a vector of numbers
# why this works:
sample(10) + 100
runif(10) > 0.5

# in R, basic mathematical operations work with vectors. Means you should never need
# to perform explicit iteration when performing simple mathematical computation

# what happens if you add two vectors of different length?
1:10 + 1:2
# here R expands the shortest vector to the same length as the longest
# this is silent except when the length of the longer is not an integer multiple
# of the length of the shorter
1:10 + 1:3

# tidyverse functions will throw errors if you try and use this property
# if want it, need to use rep()
tibble(x = 1:4, y = 1:2)
tibble(x = 1:4, y = rep(1:2, 2))
tibble(x = 1:4, y = rep(1:2, each = 2))

# NAMING VECTORS
# during creation
c(x = 1, y = 2, z = 4)
# after the fact w/ purrr
set_names(1:3, c("a", "b", "c"))

# SUBSETTING --------------------------------------------------------------
# filter() only works with tibble, need [, the subsetting function
# four things you can subset a vector with
# 1) a numeric vecter containing only integers (must be all positive, all neg, 
#    or zero)
x <- c("one", "two", "three", "four", "five")
x[c(3, 2, 5)]
# by repeating a position, you can make a longer output than input
x[c(1, 1, 5, 5, 5, 2)]
# negative values drop elements at the specified positions
x[c(-1, -3, -5)]
# its an error to mix positive and negative values
x[c(1, -1)]
x[0] # not very useful outside of testing functions

# 2) subsetting with a logical vector keeps all values corresponding to a TRUE value
#    useful with comparison functions
x <- c(10, 3, NA, 5, 8, 1, NA)

# all non-missing values of x
x[!is.na(x)]
# all even (or missing) values of x
x[x %% 2 == 0]

# 3) if you have a named vector, you can subset it with a character vector
x <- c(abc = 1, def = 2, xyz = 5)
x[c("xyz", "def")]
# can duplicate single entries this way similar to positive integers

# 4) simplest type of subsetting is nothing: x[], returns complete x
#    not useful for vectors, but useful for subsetting matrices bc lets you select
#    all the rows or all the columns by leaving index blank
#    ex: x[1, ]

# important variation of [ called [[. It only ever extracts a single element 
# and always drops names. Most impt for lists

# Exercises
x <- c(2:20, NA)
# 4 a
last_val <- function(x) {
  len <- length(x)
  x[[len]]
}
last_val(x)
# b
y <- c("one", "two", "three", "four", "five", NA, 7, 8, 9, 10)
sum(y[is.na(y)])
even_pos <- function(x, na.rm = TRUE) {
  
  len <- length(x) + sum(is.na(x))
  i <- 0
  vect <- c(0)
  while (i < len) {
    vect <- c(vect, i)
    i = i + 2
  }
  x[vect]
}
even_pos(y)
# c
except_last <- function(x) {
  x[-length(x)]
}
except_last(x)
# d
only_even <- function(x) {
  x[x %% 2 == 0 & !is.na(x)]
}
only_even(x)

################### Recursive Vectors (Lists) ################### 
# lists can contain other lsits. Good for representing hierarchical or tree-like
# structures. create with list()
x <- list(1,2,3)
x
# str() is useful tool with lists bc focuses on the structure, not the contents
str(x)

x_named <- list(a = 1, b = 2, c = 3)
str(x_named)

# lists can contain a mix of objects, unlike atomic vectors
y <- list("a", 1L, 1.5, TRUE)
str(y)

# can even contain other lists
z <- list(list(1, 2), list(3, 4))
str(z)

# VISUALIZING LISTS
x1 <- list(c(1, 2), c(3, 4))
x2 <- list(list(1, 2), list(3, 4))
x3 <- list(1, list(2, list(3)))

# SUBSETTING
# three ways:
a <- list(a = 1:3, b = "a string", c = pi, d = list(-1, -5))
# 1) [ extracts a sublist. result will always be a list
str(a[1:2])
str(a[4])
# can subset same as with other vectors

# 2) [[ extracts a single component rom a list. removes a level of hierarchy
#    from the list
str(a[[1]])
str(a[[4]])
str(a[[4]][[1]])

# 3) $ is a shorthand for extrcting named elements of a list
a$a
a[["a"]]

# diff b/w [ and [[ really impt for lists because [[ drills down into the list
# while [ returns a new, smaller list

##################### Attributes ##################### 
# any vector can contain any arbitrary amt of metadata thru its attributes
# get and set with attr() or see them all at once with attributes()
x <- 1:10
attr(x, "greeting")
attr(x, "greeting") <- "Hi!"
attr(x, "farewell") <- "Bye!"
attributes(x)

# THree v impt attributes used to implement fundamental parts of R:
# 1) Names are used to name the elements of a vector
# 2) Dimensions (dims) make a vector behave like a matrix or array
# 3) Class is used to implement the S3 object-oriented system

# generic function looks like:
as.Date
# can see all methods for a generic with methods()
methods("as.Date")
# see implementation of a method with getS3method()
getS3method("as.Date", "default")
getS3method("as.Date", "numeric")

# most impt S3 generic is print(): controls how obj is printed when you type its name

# AUGMENTED VECTORS
# vectors with addtional attributes like factors and date-times, times, tibbles

# FACTORS
# designed to represent categorical data that can take a fixed set of possible values
# built on top of ints, have a levels attribute
x <- factor(c("ab", "cd", "ab"), levels = c("ab", "cd", "ef"))
x
typeof(x)
attributes(x)

# DATES AND DATE-TIMES
# dates in R are numeric vectors that rep the num of days since 1 Jan 1970
x <- as.Date("1970-01-01")
unclass(x)
typeof(x)
attributes(x)
# date-times are numeic vectors with class POSIXct that rep numbers of seconds 
# since Jan 1 190 (portable operating system interface, calendar time)
x <- lubridate::ymd_hm("1970-01-01 01:00")
unclass(x)
typeof(x)
attributes(x)
# tzone attribute is optional: controls how it is printed, not the abs time
attr(x, "tzone") <- "US/Pacific"
x
attr(x, "tzone") <- "US/Eastern"
x

# other type of date0times called POSIClt built on top of named lists
y <- as.POSIXlt(x)
typeof(y)
attributes(y)

# TIBBLES
# augmented lists. 3 classe: tbl_df, tbl, and data.frame
# two attributes: (column) names and row.names
tb <- tibble::tibble(x = 1:5, y = 5:1)
typeof(tb)
attributes(tb)

# tranditional data.frames have a very similar structure