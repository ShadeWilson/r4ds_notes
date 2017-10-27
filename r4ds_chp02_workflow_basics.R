# sqroot(shade sucks) - EMA, 07/04/17

# Notes from R FOR DATA SCIENCE,
# an O'Reilly guide by Hadley Wickham and Garrett Grolemund
# Chapter Two: Workflow: Basics
library(tidyverse)


1 / 200 * 30 
(59 + 73 + 2) / 3
sin(pi / 2)

x <- 3 * 4
# shortcut for <- is Alt-- 

# object names start with a letter and only contain letters, numbers, _'s, and .'s.
# different conventions
# some_use_underscores
# someUseCamelCase
# seom.use.periods

thisa_ok <- 5
r_rocks <- 2^3

################# CALLING FUNCTIONS #################
# if you make an assignment you dont get to see the value
# youre then tempted to double check
y <- seq(1, 10, length.out = 5)
y
# this can be shorted by surrounding the assignment with paretheses
(y <- seq(1, 10, length.out = 5))
