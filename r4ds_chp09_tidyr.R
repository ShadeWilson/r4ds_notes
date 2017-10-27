# Notes from R FOR DATA SCIENCE,
# an O'Reilly guide by Hadley Wickham and Garrett Grolemund
# Availible online at http://r4ds.had.co.nz/
# PART TWO: Wrangle
# Chapter 9: Tidy Data with tidyr

library(tidyverse)

table1
table2
table3
table4a
table4b

# only table1 is tidy!

# Three rules that make a dataset tidy:
# 1) each variable must have its own column
# 2) each observation must have its own row
# 3) each value must have its own cell

# Put more simply: 1) put each dataset in a tibble, and 2) put each variable in a column

##################### GATHER() and SPREAD() #####################
# common problem is some of column names are not names of variables but vaules of variables (table4a)
# to gather those columns into new pair of variables nned 3 parameters:
# 1) set of columns that represent values, not variables (1999, 2000)
# 2) name of the variable whose values form the column names (key = "year") (new col name)
# 3) name of the variable whose values are spread over the cells (value = "cases") (2nd new col name)
(tidy4a <- table4a %>%
  gather('1999', '2000', key = "year", value = "cases"))
# use dplyr::select() style callings to specify which columns to gather (chp 3)
# here they are directly named bc theres only 2 (surrounded by backticks bc nonsyntactic)
(tidy4b <- table4b %>%
  gather('1999', '2000', key = "year", value = "population"))

# to combine table4a and 4b, need dplyr::left_join()
left_join(tidy4a, tidy4b)

# Spreading: opposite of gathering
# used when an observation is scatterd across multiple rows
# ex: table2, an obs is a country in a year but each obs is spread across two rows
table2
# spread(): need two parameters: column that contains variable names (key = type)
# column that contains values for multiple variables (value = count)
spread(table2, key = type, value = count)

# Exercises 
# 1
stocks <- tibble(year = c(2015, 2015, 2016, 2016),
                 half = c(1, 2, 1, 2),
                 return = c(1.88, 0.59, 0.92, 0.17)
                 )
stocks %>%
  spread(year, return) %>%
  gather(key = "year", value = "return", '2015', '2016')
# 2 need backticks
# 4
preg <- tribble(
  ~pregnant, ~male, ~female,
      "yes",    NA,      10,
       "no",    20,      12
)
preg %>%
  gather(male, female, key = "gender", value = "count")

################### Separate and Pull ################### 
table3 # need to use separate() to fix this table!

# separate() pulls apart one column into multiple columns, by splitting
# wherever a separator character appears
table3 %>%
  separate(rate, into = c("cases", "population"))
# by default, separate() splits values wherever it sees a non-alphanumeric character(here: /)
# if you wish to use a specific character, use sep = "/"
# formally, sep is regular expression
table3 %>%
  separate(rate, into = c("cases", "population"), sep = "/")

# columns split this way are stored as char vectors (bc default is to leave the type of
# column as is). Can convert to better types with convert = TRUE
table3 %>%
  separate(rate, 
           into = c("cases", "population"), 
           sep = "/",
           convert = TRUE)

# can use sep.separate() to separate integer values at the specified position??
# confusing wording but I think it cuts after number given
# ie sep = 2 cuts after 2nd character
table3 %>%
  separate(year, into = c("century", "year"), sep = 2)

# Unite: the inverse of separate()
# combines multiple columns into a single column
table5
table5 %>%
  unite(new, century, year)
# default places an underscore between values. need to use sep to specify
table5 %>%
  unite(new, century, year, sep = "")

# Exercises
# 1
?separate
tibble(x = c("a,b,c", "d,e,f,g", "h,i,j")) %>%
  separate(x, c("one", "two","three"), extra = "merge")
# extra controls what happens if there are too many pieces. Can warn, drop or merge
# fill controls what happens when there's not enough pieces
tibble(x = c("a,b,c", "d,e", "h,i,j")) %>%
  separate(x, c("one", "two","three"), fill = "right")

################### Missing Values ###################
# Value can be missing explicitly (listed as NA) or implicitly (not present in data)
stocks <- tibble(
year   = c(2015, 2015, 2015, 2015, 2016, 2016, 2016),
qtr    = c(   1,    2,    3,    4,    2,    3,    4),
return = c(1.88, 0.59, 0.35,   NA, 0.92, 0.17, 2.66)
)
# two missing values here: return for 4th quarter of 2015 is explicitly missing (NA)
# return for first quarter of 2016 implicitly missing (not in dataset)

# can make implicit missing value explicit by putting years in columns
stocks %>%
  spread(year, return)

# can set na.rm = TRUE in gather() to turn explicit missing values implicit
stocks %>%
  spread(year, return) %>%
  gather(year, return, '2015','2016', na.rm = TRUE)

# another tool for making NAs explicit is complete()
# complete() takes a set of cols, finds all unique combos
# then it ensures the original dataset contains all thoe values, filling in NAs when necessary
stocks %>%
  complete(year, qtr)

# if missing value indicate that previous value should be used, can fill with fill()
treatment <- tribble(
  ~person,            ~treatment, ~response,
  "Derrick Whitmore", 1,          7,
  NA,                 2,         10,
  NA,                 3,          9,
  "Katherine Burke",  1,         4
)
treatment %>%
  fill(person)

#################### Case Study ####################
# practice!
who
who1 <- who %>%
  gather(
    new_sp_m014:newrel_f65, key = "key",
    value = "cases",
    na.rm = TRUE
  )
who1 %>%
  count(key)
# who1 %>%
#   group_by(year) %>%
#   summarize(count = n()) %>%
#   View()

# data dictionary says:
# 1) first three letter of each column denote whether the col contains new or old cases of TB
#    in this case, each column contains new cases
# 2) next two letters describe the type of TB: rel (relapse), ep (extrapulmonary TB),
#    sn (TB that couldn't be diagnosed by a pulmonary smear (smear neg)),
#    sp (smear positive, cases of pulmonary TB that could be diagnosed by pulmonary smear)
# 3) 6th letter gives the sex of the TB patients (m or f)
# 4) remaining numbers give the age group: 014 = 0-14, 1524 = 15-24, etc.

# inconsistnacy prob: newrel needs to be new_rel, use str_replace()
(who2 <- who1 %>%
  mutate(key = stringr::str_replace(key, "newrel", "new_rel")))
# who2 %>%
#   select(key, cases, contains("new_rel"))

# we can separate the values in each code with two passes of separate()
who3 <- who2 %>%
  separate(key, c("new", "type", "sexage"), sep = "_")
who3 %>%
  count(new)
# drop redundant columns
who4 <- who3 %>%
  select(-new, -iso2, -iso3)
# separate sex and age
who5 <- who4 %>%
  separate(sexage, c("sex", "age"), sep = 1) 
who5

# the same code, all together in pipe form
who_upd <- who %>%
  gather(code, value, new_sp_m014:newrel_f65, na.rm = TRUE) %>%
  mutate(code = stringr::str_replace(code, "newrel", "new_rel")) %>%
  separate(code, c("new", "var", "sexage")) %>%
  select(-new, -iso2, -iso3) %>%
  separate(sexage, c("sex", "age"), sep = 1)

# Exercises
# 4
who_upd %>%
  group_by(country, year, sex) %>%
  summarize(tot_cases = sum(value)) %>%
  ggplot(aes(x = year)) +
    geom_bar(aes(fill = sex))

who_upd %>%
  group_by(year) %>%
  summarize(tot_cases = sum(value)) %>%
  ggplot(aes(x = year, y = tot_cases)) +
  geom_bar(stat = "identity")

# plot of afghanistan. could switch for any country
who_upd %>%
  group_by(country, year, sex) %>%
  summarize(tot_cases = sum(value)) %>%
  select(country, starts_with("Afgh"), everything()) %>%
  ggplot(aes(x = year)) +
    geom_bar(aes(fill = sex))

who_upd %>%
  group_by(country, year, sex) %>%
  summarize(tot_cases = sum(value)) %>%
  ggplot(aes(x = year, y = tot_cases)) +
    geom_point(aes(color = country)) # yikes
