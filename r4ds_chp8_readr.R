# Notes from R FOR DATA SCIENCE,
# an O'Reilly guide by Hadley Wickham and Garrett Grolemund
# Availible online at http://r4ds.had.co.nz/
# PART TWO: Wrangle
# Chapter 8: Data Import with readr

library(tidyverse)

################### Reading in CSVs #######################

# read_csv() reads comma-delimited files
# read_csv2() reads semi-colon separated files
# read_tsv() reads tab-delimited files, and
# read_delim() reads files with any delimiter

# read_fwf() reads fixed-width files
# read_table() reads a common variation of fixed width files where columns are sep'd by white space

# read_log() read Apache style log files

# all have similar syntax!

# first arg to read_csv() is the most important: the path
heights <- read_csv("data/heights.csv")

read_csv("a,b,c
         1,2,3
         4,5,6")
# uses first line of data for the column name
# two cases where you might want to tweak this:
# 1) Sometimes there are extra descriptive lines at top of file.
# skip first n lines with skip = n or use comment = "#" to drop all lines that start with #
read_csv("The first line of metadata
         the second line
         x,y,z
         1,2,3", skip = 2)
# 2) the data might not have column names. Use col_names = FALSE

# alternatively you can pass col_names a character vector which will be used as the column names
read_csv("1,2,3\n4,5,6", col_names = c("x", "y", "z"))

# another option that needs tweaking is na. This specifies the value(s) used
# to represent missing values in file
read_csv("a,b,c\n1,2,.", na = ".")

##################### Parsing a vector ########################
# parse_*() functions take a character vector and return a more specialized vector
str(parse_logical(c("TRUE", "FALSE", "NA")))
str(parse_integer(c("1","2","3")))
str(parse_date(c("2010-01-01", "1979-10-14")))

# parse functions: first arg is a character vector to parse, na arg specifies whihc strings
# to treat as missing
parse_integer(c("1", "231", ".", "456"), na = ".")

# if parsing fails, you'll get a warning and failures will be missing in output
# use problems() if many errors
x <- parse_integer(c("123", "345", "abc", "123.45"))
problems(x)

# Eight particularly important parsers:
# parse_logical() and parse_integer() parse logicals, and ints, respectively
# parse_double() is a strict number parser, parse_number() is flexible number parser
# parse_character(): simple except for character encodings
# parse_factor() creates factors, the data structure R uses to represtent categorical
# variables with fixed and known values
# parse_datetime(), parse_date(), parse_time() allow parsing of various date and times
# most complicated bc there are so many diff ways of writing dates

# NUMBERS: tricky for three reasons
# 1) people write numbers differently in diff parts of the world (. vs. ,)
# 2) Numbers are often surrounded by other characters for context ($100, 10%)
# 3) Numbers often contain "grouping" characters, like "1,000,000" that can vary

# to address 1: readr has a notion of "locale"
parse_double("1.23")
parse_double("1,23", locale = locale(decimal_mark = ","))

# to address 2: parse_number() ignores non-numeric characters before and after number
# good for currencies and percentages
parse_number("$1000")
parse_number("20%")
parse_number("It cost $123.45")

# addressing 3: combination of parse_number() and the locale as parse_number() will ignore
# "grouping mark"
# used in USA
parse_number("$123,456,789")
# use in Europe
parse_number("123.456.789", 
             locale = locale(grouping_mark = "."))

# Strings
#parse_character() seems like it should be simple but there are multiple ways ot represent a string
charToRaw("Hadley") # hexadecimal representation
# UTF-8 encoding is most universal, readr uses it
# good default but may fial for older systems that don't understand UTF-8
# if this happens, it may print gibberish or one or two chars will be wrong
x1 <- "El Ni\xf1o was particularly bad this year"
x2 <- "\x82\xb1\x82\xf1\x82\xc9\x82\xbf\x82\xcd"

# need to specify the encoding
parse_character(x1, locale = locale(encoding = "Latin1"))
parse_character(x2, locale = locale(encoding = "Shift-JIS"))

# guess_encoding() for to help figure out the right encodings
guess_encoding(charToRaw(x1))
guess_encoding(charToRaw(x2))

# Factors
# R uses factors to represent categorical variables that have a known set of possible values
# give parse_factor() a vector of known levels to generate a warning whenever an unexpected
# value is present
fruit <- c("apple", "banana")
parse_factor(c("apple", "banana", "bananana"), levels = fruit)

# Date, date-times, and times
# pick b/w 3 parsers depending on which you want:
# date: number of days since 1970-01-01, 
# date-time: number of seconds singe midnight 1970-01-01,
# or time: number of seconds since midnight

# parse_datetime() expects an ISO8601 (int'l std) date-time. Components go from biggest to smallest:
# year, month, day, hour, minute, second
parse_datetime("2010-10-01T2010")
# if time is omitted, its set to midnight
parse_datetime("20101010")

# parse_date() expects a four-digit year, a - or /, the month, a - or /, then the day
parse_date("2010-10-01")

# parse_time() expects the hour, :, minutes, optionally : and seconds, and an optional am/pm specifier
library(hms)
parse_time("01:10 am")
parse_time("20:10:01")

# date input your own date-time format with different letter specifiers
parse_date("01/02/15", "%m/%d/%y")
parse_date("01/02/15", "%d/%m/%y")
parse_date("01/02/15", "%y/%m/%d")

# Exercise #7:
 d1 <- "January 1, 2010"
 parse_date(d1, "%B %d, %Y")
d2 <- "2015-Mar-07"
parse_date(d2, "%Y-%b-%d")
d3 <- "06-Jun-2017"
parse_date(d3, "%d-%b-%Y")
d4 <- c("August 19 (2015)", "July 1 (2015)")
parse_date(d4, "%B %d (%Y)")
d5 <- "12/30/14"
parse_date(d5, "%m/%d/%y")
t1 <- "1705"
parse_time(t1, "%H%M")
t2 <- "11:15:10.12 PM"
parse_time(t2, "%I:%M:%OS %p")

###################### Parsing a file #########################
guess_parser("2010-10-01")
guess_parser(c("TRUE", "FALSE"))
guess_parser(c("12,329,999"))

# readr can guess the parser to use from first 1000 lines, but doesnt always work right and
# may need to be overwritten, esp if theres lots of NAs
challenge <- read_csv(readr_example("challenge.csv"))
problems(challenge)
# lots of probs with x column, should use double parser instead
challenge <- read_csv(
  readr_example("challenge.csv"),
  col_types = cols(
    x = col_double(),
    y = col_character()
  )
)
# nox x is good, but y is char when is should be date
challenge <- read_csv(
  readr_example("challenge.csv"),
  col_types = cols(
    x = col_double(),
    y = col_date()
  )
)

# every parse_*() function has a corresponding col_*() function
# you use parse() when the data is in a character vector in R already,
# use col_*() when you want to tell readr how to load the data

# best preactive is to always supply the col_types instead of replying on guessing
# to improve reproducibility

# other parsing strategies
challenge2 <- read_csv(readr_example("challenge.csv"),
                      guess_max = 1001)
# sometimes its easier to dianose problems if you just read in all the columns as chaacter vectors
challenge2 <- read_csv(readr_example("challenge.csv"),
                       col_types = cols(.default = col_character()))

# Writing to a file
# readr also comes with two useful fucntions foor writing data bcak to disk:
# write_csv() and write_tsv()
# always encodes in UTF-8 and saves date-times in ISO8601 format

# write_excel_csv() for exporting a csv file to excel

write_csv(challenge, "challenge.csv")
# data types are lost when writing to csv, not the best interim step!
# need to recreate the column specification cada vez or:
# write_rds() and read_rds() are uniform wrappers around the base functions readRDS() and saveRDS()
# store data in R's custom binary format called RDS
write_rds(challenge, "challenge.rds")
read_rds("challenge.rds")

# the feather package impliments a fast binary file format that can be shared
# across programming languages. Faster than RDS and usable outside of R
library(feather)
write_feather(challenge, "challenge.feather")
read_feather("challenge.feather")

# Reading other types of data:
# haven for SPSS, Stata, SAS
# readxl for excel files (.xls and .xlsx)
# DBI along with database-specific backend for SQL queries
# xml2 for XML
