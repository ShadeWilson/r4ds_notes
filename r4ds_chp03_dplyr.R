# Notes from R FOR DATA SCIENCE,
# an O'Reilly guide by Hadley Wickham and Garrett Grolemund
# Availible online at http://r4ds.had.co.nz/
# PART ONE: EXPLORE
# Chapter 3: Data Transformation with dplyr
library(tidyverse)
library(nycflights13)

flights
# in the row under the column names are 3/4 letter abbreviations indicating the type of data
# int is integer, dbl is double (num too maybe), chr is character vector, dttm is date-time
# lgl is logical (boolean), fctr is factors (used to represent categorical variables), data is date

View(flights)
str(flights)

# There are five key dplyr functions for data-manipulation challenges:
# Pick observations by their values (filter())
# reorder rows with arrange()
# Create new variables with functions of existing variables (mutate())
# Collapse many values down to a single summary (summarize())
# These all can be used in conjunction with group_by(), which changes the function scope

# All functions work similarly:
# 1) the first argument is the dataframe
# 2) Subsequent arguments describe what to do with the dataframe, using the variable names (no quotes)
# 3) The result is a new data frame

################# FILTER ROWS WITH filter() #################
# filter() allows you to subset observations based on their values
# 1st arg is dataframe, 2nd and 3rd are expressions that filter the df
filter(flights, month == 1, day == 1)

# filter doesn't modify the original df, so have to save it if wanted
jan1 <- filter(flights, month == 1, day == 1)
# if youw anted to save results to a variable AND print them using paretheses
(dec25 <- filter(flights, month ==12, day == 25))
# need to use == instead of = for equality

# use near() instead of == when worried about unidentical floating point numbers
sqrt(2) ^ 2 == 2 # vs.
near(sqrt(2) ^ 2, 2)

# Multiple argumetns to filter are combined with "and", "or", "not"
# &, |, !
filter(flights, month == 11 | month == 12)

# a useful shorthand here is x %in% y
# this selects every row where x is one of the values in y
nov_dec <- filter(flights, month %in% c(11, 12))

# De Morgan's law: !(x & y) == !x | !y
# !(x | y) == !x & !y
# IF you wanted to find flights that weren't delayed by more than two hours or could use
# either of the following:
filter(flights, !(arr_delay > 120 | dep_delay > 120))
filter(flights, arr_delay <= 120, dep_delay <= 120)

# R also has && and || in addition to & and | but dont use them here! 
# They're used in conditional formatting

# to determine is a value is missing (NA) use is.na
x <- NA
is.na(x)

# filter only includes rows where the condition is true, it excludes false and NA values
# to preserve NAs, ask for them explicitly
df <- tibble(x = c(1, NA, 3))
filter(df, x > 1) # doesn;t show NA
filter(df, is.na(x) | x > 1) # DOES show NA

# Exercises:
# Find all flights that
# A) had an arrival delay time of 2+ hours
filter(flights, arr_delay >= 120)
# b) flew to houston (IAH or HOU)
filter(flights, dest %in% c("IAH", "HOU"))
# c) were operated by United, american, or Delta
filter(flights, carrier %in% c("UA", "AA", "DL"))
# d) departed in summer
filter(flights, month %in% c(8:10))
# e) arrived more than two hours late but didnt leave late
filter(flights, dep_delay <= 0, arr_delay > 120)
# f) were delayed by at least an hour, but made up over 30 mins in flight
filter(flights, dep_delay >= 60, arr_delay <= dep_delay - 30)
# g) departed between midnight and 6 am (inclusive)
filter(flights, dep_time <= 600)

?between() # shortcut for x>= left & x <= right

# how many flightshave a missing dep_time?
filter(flights, is.na(dep_time)) # 8255 are NA

############## ARRANGE ROWS WITH arrange() ################
# arrange() works similarly to filter() expect instead of selecting rows, it changes their order
# takes a df and a set of column names to order by
arrange(flights, year, month, day)

# use desc() to reorder by a column in descending order
arrange(flights, desc(arr_delay))

# missing values are always sorted at the end

# How to get NA valuse listed first
arrange(flights, desc(is.na(dep_delay)))

# sort flights to find the most delayed flights. Find the flights that left the earliest
arrange(flights, desc(arr_delay - dep_delay))
# fastest flights
arrange(flights, arr_delay - dep_delay)
# longest
arrange(flights, desc(distance))

############### SELECT COLUMNS WITH select() ##################
# allows you to rapidly zoom into meaningful variables
select(flights, year, month, day)
# select all column between year and day (inclusive)
select(flights, year:day)
# select all columns except between year and day
select(flights, -(year:day))

# useful functions with select:
# starts_with("abc")  matches names that begin with "abc"
# ends_with("xyz") matches names that end with "xyz"
# contains("ijk")
# matches("(.)\\1") selects variables that match a regular expression. 
# This one matches any variables that comtain repeated characters
# num_range("x", 1:3) matches x1, x2, x3

# select can be used to rename variabbles, but its not useful because it drops
# all of the other variables not explicitly mentioned
# rename() is better
rename(flights, tail_num = tailnum)

# another option: can use select() in conjunction with the everything() helper
# useful for if you have a handful of variables you'd like to move to the start of the df
select(flights, time_hour, air_time, everything())

# Exercises
select(flights, starts_with("dep"), starts_with("arr"))

# one_of() function may be useful for eliminating multiple OR statements

select(flights, contains("TIME")) # case INsensitive
select(flights, contains("TIME", ignore.case = FALSE)) # default is true

################## ADD NEW VARIABLES WITH mutate() ######################
# mutate() always adds new columns to the END of a df
flights_sml <- select(flights, 
                      year:day,
                      ends_with("delay"),
                      distance,
                      air_time)
mutate(flights_sml,
                      gain = arr_delay - dep_delay,
                      speed = distance / air_time * 60)

# Note you can refer to columns that you've just created
mutate(flights_sml,
       gain = arr_delay - dep_delay,
       hours = air_time / 60,
       gain_per_hour = gain / hours)

# If you only want to keep the new variables, use transmute()
transmute(flights_sml,
          gain = arr_delay - dep_delay,
          hours = air_time / 60,
          gain_per_hour = gain / hours)
# Remember, nothing saves here unless you assign it to a variable (or back to itself) with <- 

# Useful creation functions that can be used with mutate()
# Key property is that the function must be vectorized: it must take a vector of values as
# an input and return a vector with the same number of values as the output
# Some useful functions:
# arithmetic operators: +, -, *, /, ^
# Modular arithmetic (%/%: integer division, and %%: remainder), where x == y * (x %/% y) + (x %% y)
# Basically, the ex above says x / y plus the remainder equals x when both are ints
# Ex: computing hour and minute from dep_time:
transmute(flights, 
          dep_time,
          hour = dep_time %/% 100, # divide
          minute = dep_time %% 100) # remainder

# Logs: log(), log2(), log10() 
# Offsets: lead() and lag() allow you to refer to leading or lagging values
# allows you to compute running differences or find when values change
# x - lag(x) or x != lag(x)
# most useful in conjunction with group_by()
(x <- 1:10)
lag(x)
x - lag(x)
lead(x)

# Cumulative and rolling aggregates
# R provides functions for running sums, products, mins, and maxes
# cumsum(), cumprod(), cummin(), cummax(), dplyr::cummean()
cumsum(x)
cummean(x)

# logical comparisons <, <=, >, >=, !=
# its a good idea to store interi values in new variables if perfomring a complex sequence 
# of logical operations

# Ranking:
# min_rank() does the most usual type of ranking (1st, 2nd, 3rd, etc). Default gives smallest values
# the smallest ranks; use desc() to give the largest values the smallest ranks
y <- c(1, 2, 2, NA, 3, 4)
min_rank(y)
min_rank(desc(y))

# Exercises
# 1)
select(flights, dep_time, sched_dep_time)
transmute(flights, 
          dep_time,
          sched_dep_time,
          dep_hour = dep_time %/% 100,
          dep_min = dep_time %% 100,
          mins_past_midnight = dep_hour * 60 + dep_min)
# 2
transmute(flights, 
          sched_dep_time,
          sched_arr_time,
          dep_time,
          dep_hour = dep_time %/% 100,
          dep_min = dep_time %% 100,
          arr_time,
          arr_hour = arr_time %/% 100,
          arr_min = arr_time %% 100,
          air_time,
          tot_time = (arr_hour - dep_hour) * 60 + arr_min - dep_min) # in mins
# air_time is based on scheduled dep/arr, not actual. arr_time - dep_time must be converted 
# into minutes or something consistent as time is not base 10 

# 3
transmute(flights, dep_time, sched_dep_time, dep_delay)

# 4
min_rank(desc(flights$dep_delay))

# 5 
1:3 + 1:10

################# GROUPED SUMMARIES WITH summarize() ####################
# collapses a df into a single row
summarize(flights, delay = mean(dep_delay, na.rm = TRUE))
# not terribly useful unless grouped with group_by()
# Ex can get avg delay per date:
by_day <-  group_by(flights, year, month, day)
summarize(by_day, delay = mean(dep_delay, na.rm = TRUE))

# THE PIPE #
by_dest <- group_by(flights, dest)
delay <- summarize(by_dest, count = n(),
                   dist = mean(distance, na.rm = TRUE),
                   delay = mean(arr_delay, na.rm = TRUE))
delay <- filter(delay, count > 20, dest !="HNL")

ggplot(data = delay, mapping = aes(x = dist, y = delay)) +
  geom_point(aes(size = count), alpha = 1/3) +
  geom_smooth(se = FALSE)

# Naming things is no fun! We can tackle this problem with the pipe: %>%
delays <- flights %>% # can pronounce as "then"
  group_by(dest) %>%
  summarize(
    count = n(),
    dist = mean(distance, na.rm = TRUE),
    delay = mean(arr_delay, na.rm = TRUE)
    ) %>%
  filter(count > 20, dest != "HNL")

# if we dont use na.rm = TRUE we get a lot of NAs!
not_cancelled <- flights %>%
  filter(!is.na(dep_delay), !is.na(arr_delay))
not_cancelled %>%
  group_by(year, month, day) %>%
  summarize(mean = mean(dep_delay))

# Counts
# whenever doing aggregation, it's a good idea to include either a count (n()) or a count of 
# nonmissing values (sum(!is.na(x))). That way you can check that youre not drawing conclusions 
# based on very small amounts of data
# Ex: look at planes (ID'd by tail number) that have the highest avg delays:
delays <- not_cancelled %>%
  group_by(tailnum) %>%
  summarize(
    delay = mean(arr_delay)
  )
ggplot(data = delays, mapping = aes(x = delay)) +
  geom_freqpoly(binwidth = 10)

# Looks like there are some planes that have and avg of 3 hrs fligth delay BUT
# we get more insight looking at scaterplot of number of flights vs avg delay
delays <- not_cancelled %>%
  group_by(tailnum) %>%
  summarize(
    delay = mean(arr_delay, na.rm = TRUE),
    n = n()
  )
ggplot(data = delays, mapping = aes(x = n, y = delay)) + 
  geom_point(alpha = 1/10)
# useful to filter out groups with the smallest number of observations when 
# looking at this type of plot
delays %>%
  filter(n > 25) %>%
  ggplot(mapping = aes(x = n, y = delay)) +
    geom_point(alpha = 1/10)

batting <- as_tibble(Lahman::Batting)
batters <- batting %>%
  group_by(playerID) %>%
  summarize(
    ba = sum(H, na.rm = TRUE) / sum(AB, na.rm = TRUE),
    ab = sum(AB, na.rm = TRUE)
  )

batters %>%
  filter(ab > 1000) %>%
  ggplot(mapping = aes(x = ab, y = ba)) +
    geom_point() +
    geom_smooth(se = FALSE)

batters %>%
  arrange(desc(ba))

# Useful summary functions
# Measures of locations:
# in addition to mean(x), median(x) is useful
# its sometimes useful to combine aggregation with logical subsetting
not_cancelled %>%
  group_by(year, month, day) %>%
  summarize(
    avg_delay1 = mean(arr_delay), # average delay
    avg_delay2 = mean(arr_delay[arr_delay > 0]) # average positive delay
  )

# Measures of spread: sd(x), IQR(x), mad(x)
# the mean squared deviation or std is the standard measure of spread
# IQR or interquartile range and median absolute deviation (mad) are robust equivalents
# that may be more useful if you have outliers

# why is distance to some destinations more variable than to others?
not_cancelled %>%
  group_by(dest) %>%
  summarize( distance_sd = sd(distance)) %>%
  arrange(desc(distance_sd))

# Measures of rank: min, quantile(), max
# Quantiles are a generalization of the median. Ex: quantile(x, 0.25) will find
# a value of x that is greater than 25% of the values and less than the remaining 75%

# when do the first and last flights leave each day?
not_cancelled %>%
  group_by(year, month, day) %>%
  summarize(
    first = min(dep_time),
    last = max(dep_time)
  )

# Measures of positione: first, nth, last
# THese work similarly to x[1], x[2], and x[length(x)] but let you set a default value if that
# position does not exist
# same ex as above (first and last flight of day)
not_cancelled %>%
  group_by(year, month, day) %>%
  summarize(
    first_dep = first(dep_time),
    last_dep = last(dep_time)
  )
# these functions are complimentary to filtering on ranks. Filtering gives you all variables
# with each observation in a separate row
not_cancelled %>%
  group_by(year, month, day) %>%
  mutate(r = min_rank(desc(dep_time))) %>%
  filter(r %in% range(r)) # range returns lowest and highest values

# Counts
# you've seen n() which takes no args. To count the number of nonmissing values use 
# sum(!is.na(x)). TO count the number of distinct values, use n_distinct(x)

#which dests have the most carriers?
not_cancelled %>%
  group_by(dest) %>%
  summarize(carriers = n_distinct(carrier)) %>%
  arrange(desc(carriers))
# dplyr has a simple helper if all you want is a count
not_cancelled %>%
  count(dest)

# you can optionally provide a weight variable
not_cancelled %>%
  count(tailnum, wt = distance)

# Counts and proportions of logical vectors: sum(x > 10), mean(y == 0)
# When used in numeric functions TRUE is converted to 1 and FALSE to 0
# this makes sum() and mean() very useful: sum(x) gives the number of trues in x
# and mean(x) gives the proportion

# how many flights left before 5 am? thes usually indicate delayed flights from the prev day
not_cancelled %>%
  group_by(year, month, day) %>%
  summarise(n_early = sum(dep_time < 500))

# what proportion of flights are delayed by more than an hour?
not_cancelled %>%
  group_by(year, month, day) %>%
  summarize(hour_perc = mean(arr_delay > 60))

# Grouping by multiple variables:
# when you group by multiple variabes, each summary peels off one level of grouping.
# that makes it easy to progressively roll up a data set
daily <- group_by(flights, year, month, day)
(per_day <- summarize(daily, flights = n()))
(per_month <- summarize(per_day,  flights = sum(flights)))
(per_year <- summarize(per_month, flights = sum(flights)))

# be careful when progressively rolling up summaries: ok for sums and counts
# but the median of groupwise medians is not the overall median

# Ungrouping
# if you need to remove grouping, and return to operations on ungrouped data, use ungroup()
daily %>%
  ungroup() %>%
  summarize(flights = n())

# Exercises
# 1
not_cancelled %>%
  group_by(year, month, day) %>%
  summarise(norm_early = sum(arr_delay <= -15),
            norm_late = sum(arr_delay >= 15))
not_cancelled %>%
  group_by(dest) %>%
  summarize(avg_dep_delay = mean(dep_delay)) %>%
  arrange(desc(avg_dep_delay))
# 2
not_cancelled %>%
  count(dest)
not_cancelled %>%
  group_by(dest) %>%
  summarise(count = n())

not_cancelled %>%
  count(tailnum, wt = distance)
not_cancelled %>%
  group_by(tailnum) %>%
  summarize(distance = sum(distance))
# 3
filter(flights, is.na(dep_delay))
# 4
flights %>%
  filter(is.na(dep_delay) | is.na(arr_delay)) %>%
  group_by(year, month, day) %>%
  summarise(flights = n(),
            avg_delay = mean(dep_delay))
  
# 5
not_cancelled %>%
  group_by(carrier) %>%
  summarize(avg_dep_delay = mean(dep_delay),
            avg_arr_delay = mean(arr_delay),
            avg_delay = mean(arr_delay - dep_delay)
            ) %>%
  arrange(desc(avg_delay))

not_cancelled %>%
  group_by(carrier, dest) %>%
  summarize(count = n(),
            delay = mean(arr_delay - dep_delay)) %>%
  filter(count > 10) %>%
  arrange(desc(delay)) %>%
  group_by(carrier) %>%
  summarise(delay = mean(delay)) %>%
  arrange(desc(delay))

# 6
not_cancelled %>%
  group_by(tailnum) %>%
  summarize(flights = sum(dep_delay < 60),
            delay = mean(dep_delay))

# Grouped mutates (and filters)
# grouping is most useful in conjunction with summarize() but
# you can also do convenient operations with mutate() and filter()

# find the worst mems of each group
flights_sml %>%
  group_by(year, month, day) %>%
  filter(rank(desc(arr_delay)) < 10) # grabs the top 40 worst in arr_delay category from each day

# find all groups bigger than a threshold
popular_dests <- flights %>%
  group_by(dest) %>%
  filter(n() > 350)
popular_dests %>%
  summarise(count = n()) %>%
  arrange(count)

# Standardize to compute per group metrics
popular_dests %>%
  filter(arr_delay > 0) %>%
  mutate(prop_delay = arr_delay / sum(arr_delay)) %>%
  select(year:day, dest, arr_delay, prop_delay)

# Exercises
# 2
not_cancelled %>%
  group_by(tailnum) %>%
  summarize(count = n(),
            avg_delay = mean(arr_delay - dep_delay)) %>%
  filter(count > 10) %>%
  filter(rank(desc(avg_delay)) == 1)
# 3: worst time appears to be around 6 - 8 PM if wanting to avoid departure delays
not_cancelled %>%
  group_by(sched_dep_time) %>%
  summarise(delay = mean(dep_delay),
            count = n()) %>%
  filter(count > 50) %>%
  ggplot(mapping = aes(x = sched_dep_time, y = delay)) +
    geom_jitter() +
    geom_smooth(se = FALSE)

# 4
not_cancelled %>%
  group_by(dest) %>%
  summarise(delay = sum(arr_delay - dep_delay))

# 6
not_cancelled %>%
    group_by(dest) %>%
    filter(n_distinct(carrier) > 1) %>%
    ungroup() %>%
    group_by(carrier) %>%
    summarize(count = n()) %>%
    arrange(desc(count)) %>%
    ggplot() +
      geom_bar(mapping = aes(x = carrier, y = count, fill = carrier), stat = "identity")
    
