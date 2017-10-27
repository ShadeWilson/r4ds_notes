# Notes from R FOR DATA SCIENCE,
# an O'Reilly guide by Hadley Wickham and Garrett Grolemund
# Availible online at http://r4ds.had.co.nz/
# PART TWO: Wrangle
# Chapter 10: Relational Data with dplyr

# to work with relational data, need verbs that work with pairs of tables. THree families:
# 1) mutating joins, which add new variables to one data frame form matching obs from another
# 2) filtering joins, which filter obs from one df based on whther or not they match an obs in another
# 3) set operations, which treat obs as if they were set elements

library(tidyverse)
library(nycflights13)

airlines # shows full carrier names from abbr. code
airports # gives info on each airport, ID'd by the faa airport code
planes # gives info about each plane, ID'd by tailnum
weather # gives weather at each NYC airport for each hour

######################## Keys ######################## 
# variables used to connect each pair of tables are keys
# primary keys uniquey identify an obs in its own table(ie. planes$tailnum)
# foreign keys uniquely ID an obs in another table (ie. flights$tailnum)
# a variable can be BOTH a primary key and a foreign key (ex: origin is part of weather
# primary key and is also a foreign key for the airport table)

# tailnum is a primary key that does uniquely ID each observation
planes %>%
  count(tailnum) %>%
  filter(n > 1)
weather %>%
  count(year, month, day, hour, origin) %>%
  filter(n >1)

# sometimes a table doesn't have an explicit primary key
# year, month, day, flight is not a unique identifier, nor is year, month, day, tailnum
flights %>%
  count(year, month, day, flight) %>%
  filter(n > 1)
flights %>%
  count(year, month, day, tailnum) %>%
  filter(n > 1)

# if a table lacks a primary key it is sometimes useful to add one with mutate() and row_number()
# called a surrogate key

# Exercises
# 2
library(Lahman)
Batting %>%
  count(playerID, yearID, teamID, stint) %>%
  filter(n > 1)

diamonds %>%
  count(cut, color, clarity, table) %>%
  filter(n > 1) # doesn't look like there is one

######################### Mutating Joins ######################### 
# allos you to combine variable from two tables. ads variables to the right

# make dataset narrower
(flights2 <- flights %>%
  select(year:day, hour, origin, dest, tailnum, carrier))

# adding full airline naem to flights2 data using left_join()
# result is an additional variable (name)
flights2 %>%
  select(-origin, -dest) %>%
  left_join(airlines, by = "carrier")
# could do same thing with mutate and R's base subseting:
flights2 %>%
  select(-origin, -dest) %>%
  mutate(name = airlines$name[match(carrier, airlines$carrier)])

# Understanding joins
x <- tribble(
  ~key, ~val_x,
  1, "x1",
  2, "x2",
  3, "x3"
)
y <-  tribble(
  ~key, ~val_y,
  1, "y1",
  2, "y2",
  4, "y4"
)

# INNER JOIN: simplest type of join, which matches pairs of obs whenever keys are equal
# equijoin: keys are matched using the equality operator
# output of join is a new df that contains the key, and both matched values
# determine key with by = ""
x %>%
  inner_join(y, by = "key")
# unmatched rows are NOT included! Usually this can't be used in analysis bc too easy to lose obs

# OUTER JOINS: keeps ovs that appear in at least one of the tables. Three types:
# 1) left join keeps all obs in x
# 2) right join keeps all obs in y
# 3) full join keeps all obs in x and y
# works by adding additional "virtual" obs to each table (NA)

# default join should be left_join() bc preserves original obs even when no match

# DUPLICATE KEYS: what happens when keys aren't unique? Two possibilities:
# 1) One table has duplicate keys
x <- tribble(
  ~key, ~val_x,
  1, "x1",
  2, "x2",
  2, "x3",
  1, "x4"
)
y <-  tribble(
  ~key, ~val_y,
  1, "y1",
  2, "y2"
)
left_join(x, y, by = "key")
# 2) both tables have a duplicate key. usually an error
x <- tribble(
  ~key, ~val_x,
  1, "x1",
  2, "x2",
  2, "x3",
  3, "x4"
)
y <-  tribble(
  ~key, ~val_y,
  1, "y1",
  2, "y2",
  2, "y3",
  3, "y4"
)
left_join(x, y, by= "key") # get all possible combos of the duplicate keys (Cartesian product)

# Defining the key Columns
# other ways to join other than using single variable (by = "key")

# default (by = NULL) uses all variables that appear in both tables (natural join)
# ex: flights and weather match on their common variables: year, month, day, hour, origin
flights2 %>%
  left_join(weather)

# a character vector, by = "x". This is like natural join but only uses some of the common variables
# ex: flights and planes have year variables, but mean diff things so we only want tailnum
# note year variables are disambiguated in the output w/ suffix
flights2 %>%
  left_join(planes, by = "tailnum")

# a named character vector: by = c("a" = "b"). This matches variable a in table.x to var b
# in table.y. Variables from x will be used in output
# ex: for drawing map, need to combine the flight data with the airports data (lat and long)
# each flight has origin and dest airport, so we need to specify
flights2 %>%
  left_join(airports, c("dest" = "faa"))
flights2 %>%
  left_join(airports, c("origin" = "faa"))

# Exercises
# 1
flights %>%
  filter(!is.na(dep_delay), !is.na(arr_delay)) %>%
  group_by(dest) %>%
  summarize(avg_dep_delay = mean(dep_delay)) %>%
  left_join(airports, by = c("dest" = "faa")) %>%
  filter(!is.na(name)) %>%
  ggplot(aes(lon, lat)) +
    borders("state") +
    geom_point(aes(color = avg_dep_delay, size = avg_dep_delay)) +
    coord_quickmap()

# 2
airports %>%
  select(faa, lat, lon) %>%
  right_join(flights, by = c("faa" = "dest")) # or
# better
flights %>%
  left_join(airports, by = c("dest" = "faa")) %>%
  select(-name, -(alt:tzone))
# 3
# add plane age column
planes2 <- planes %>%
  mutate(age = 2013 - year) %>%
  select(tailnum, age)
flights %>% 
  filter(!is.na(dep_delay), !is.na(arr_delay)) %>%
  group_by(tailnum) %>%
  summarize(avg_delay = mean(arr_delay - dep_delay),
            count = n()) %>%
  left_join(planes2, by = "tailnum") %>%
  filter(!is.na(age), count > 20, age < 30) %>% # take out NAs and outliers, zoom in
  ggplot(aes(x = age, y = avg_delay)) +
    geom_jitter(aes(color = count)) +
    geom_smooth(se = FALSE)
# 4
flights %>% 
  filter(!is.na(dep_delay), !is.na(arr_delay)) %>%
  left_join(weather, by = c("year", "month", "day", "hour")) %>%
  filter(month == 1) %>%
  ggplot(aes(dep_delay, wind_speed)) +
    geom_point()

# Other implementations
# base::merge() can perform all 4 types of mutating joins, but dplyr's are more clear and faster

######################### Filtering Joins #########################
# filtering joins affect obs, not the variables. Two types:
# 1) semi_join(x, y) keeps all obs in x that have a match in y
# 2) anti_join(x, y) drops all obs in x that have a match in y

# semi joins are useful for matching filtered summary tables back to the original rows. 
# ex: imagine you've found top 10 most popular dests
top_dest <- flights %>%
  count(dest, sort = TRUE) %>%
  head(10)
# now you want to find each flight that went to one of those dests. Could filter yourself
flights %>%
  filter(dest %in% top_dest$dest)
# this is difficult to extend to multiple cars though. instead , use semi_join()
# connects two tables like a mutating join, but instead of adding new columns, 
# only keeps the rows in x that have a match in y
nycflights13::flights %>%
  semi_join(top_dest)

# anti_joins are the oppositee of a semi_join: only gives obs that DONT have a match
# useful for diagnoseing join mismatches
# ex: checking flights that don't have a match in planes
flights %>%
  anti_join(planes, by = "tailnum") %>%
  count(tailnum, sort = TRUE)

# Exercises
# 1: almost all have the same carrier: MQ
# 2
many <- flights %>%
  count(tailnum) %>%
  filter(n >= 100)

flights %>%
  semi_join(many) 
  
# Set Operations: expect x and y inputs to have the same variab;les and treat obs like sets
# intersect(x, y) returns only observations in both x and y
# union() returns unique obs in x and y
# setdiff() returns obs in x, but not y
df1 <- tribble(
  ~x, ~y,
  1, 1,
  2, 1
)
df2 <- tribble(
  ~x, ~y,
  1, 1,
  1, 2
)
# Four possibilities
intersect(df1, df2)

union(df1, df2)

setdiff(df1, df2)

setdiff(df2, df1)
