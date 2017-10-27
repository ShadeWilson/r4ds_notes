# Notes from R FOR DATA SCIENCE,
# an O'Reilly guide by Hadley Wickham and Garrett Grolemund
# Availible online at http://r4ds.had.co.nz/
# PART THREE: Program
# Chapter 14: Pipes with magrittr

library(magrittr)

################### Piping Alternatives ################### 
# foo_foo <- little_bunny()
# To retell stroy, can:
# 1) save each intermediate step as a new object
# 2) overwrite the original object many times
# 3) compose functions
# 4) use the pipe

# INTERMEDIATE STEPS
# foo_foo1 <- hop(foo_foo, through = forest)
# foo_foo2 <- scoop(foo_foo1, up = field_mice)
# foo_foo3 <- bop(foo_foo2, on = head)

# main downside is that it forces you to name each intermed element. Good if there are natural names
# but here there are not
# clutters code w/ unimportant names, have to carefully increment suffix on each line

# R shares columns across dataframes where possible to save memory
diamonds <- ggplot2::diamonds
diamonds2 <- diamonds %>%
  dplyr::mutate(price_per_carat = price / carat)

pryr::object_size(diamonds)
pryr::object_size(diamonds2)
pryr::object_size(diamonds, diamonds2)
# since diamonds2 has 10 columns in common with diamondss, theres no need to duplicate the data
# if we modify a single value in carat, the columns are no longer identical and thus no longer be shared
diamonds$carat[1] <- NA
pryr::object_size(diamonds)
pryr::object_size(diamonds2)
pryr::object_size(diamonds, diamonds2) # now much greater than just diamonds2
# not using object.size (built in fction) bc it only takes a single object, cant compute shared data

# OVERWRITE THE ORIGINAL
# foo_foo <- hop(foo_foo, through = forest)
# foo_foo <- scoop(foo_foo, up = field_mice)
# foo_foo <- bop(foo_foo, on = head)

# less typing, less thinking, less mistakes, but two problems
# 1) Debugging is painful
# 2) repetition of object being transformed obscures whats changing on each line

# FUNCTION COMPOSITION
# abandon assignment and string the function calls together
# bop(
#   scoop(
#     hop(foo_foo, through = forest),
#     up = field_mice),
#   on = head)

# disadvantage is that you have to read from the inside out (right to left) and 
# args are spread out (Dagwood sandwich) so hard to understand!

# USE THE PIPE!
# foo_foo %>%
#   hop(through = forest) %>%
#   scoop(up = field_mice) %>%
#   bop(on = head)

# focuses on verbs, not nouns
# works by performing a lexical transformation. Reassembles code in the pipe to a form that 
# works by overwriting an intermediate object

# Pipe DOESNT work fro two classes of functions
# 1) Functions that use the current environment. Ex: assign() will create a new variable
#    with the given name in the current environment
assign("x", 20)
x
"x" %>% assign(100)
# doesnt work bc the pipe assigns it to a temporary environment used by %>%
# if you do want to use assign, must be explicit:
env <- environment()
"x" %>% assign(100, envir = env)
x
# other functions with this problem are get() and load()

# 2) functions that use lazy evaluation. ex: supressMessages(), tryCatch(), supressWarnings()

############### When Not to Use the Pipe ############### 
# most useful for writing fairly short linear sequence of operations

# Use another tool when:
#   pipes are longer than 10 steps. Create intermediate objects with meaningful names
# then easier to debug and easier to understand (with clear variable names)

#   you have multiple inputs or outputs. If there isnt one primary object being transfomred, but 2+
# being combined tg, don't use the pip

#   you are starting to think about a directed graph with a complex dependency structure. Pipes
# are fundamentally linear and expressing complex relationships with them will typically
# yield confusing code

############### Other Tools from magrittr ############### 
# When working on complex pipes, its sometimes useful to call a function for its side effects
# (ie print out current obj or plot or save). Such functions dont return anything, ending pipe
# to work around this porblem, can use "tee" pipe: %T>% works like %>% except it returns the left-
# hand side instead of the right hand side.
rnorm(100) %>%
  matrix(ncol = 2) %>%
  plot() %>%
  str()

rnorm(100) %>%
  matrix(ncol = 2) %T>% # returns the 100 random nums, not matrix
  plot() %>% # plot can take either matrix or jsut numbers, so its order here doenst matter
  str()
  
# if working with functions that dont have a dataframe-based API (ex: you pass indiv vectors, not a df)
# %$% might be useful. It "explodes" out the variables in a dataframe so you can refer to them 
# explicitly. Useful when working with many functions in base R
mtcars %$%
  cor(disp, mpg)

# For assingment, %<>% allows you to replace code like so:
mtcars <- mtcars %>%
  transform(cyl = cyl * 2) # to
mtcars %<>% transform(cyl = cyl * 2)
# allows you to more concisely overwrite variable, but at the cost of potentially being more confusing