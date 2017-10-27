# Notes from R FOR DATA SCIENCE,
# an O'Reilly guide by Hadley Wickham and Garrett Grolemund
# Availible online at http://r4ds.had.co.nz/
# PART TWO: Wrangle
# Chapter 11: Strings with stringr

library(tidyverse)
library(stringr)

############### String Basics ############### 
# no differnece between single or double quotes
string1 <- "This is a string"
string2 <- 'To put a "quote" inside a string, use single quotes'

# to include literal single or double quote in string, use \ to escape
double_quote <- "\""
single_quote <- '\''
backslash <- "\\" # has to be double

# writeLines() shows raw contents of strings
x <- c("\"", "\\")
x
writeLines(x)

# all stringr function names start with str_
str_length(c("a", "R for data science", NA))

# use str_c() to combine two+ strings. Vectorized
# similar to paste() and paste0()!
# use sep arg to control how they're separated
str_c("x","y")
str_c("x","y","z")
str_c("x","y", sep = " + ")

# missing values are contageous: if you want NAs to print, use str_replace_na()
x <- c("abc", NA)
str_c("|-",x,"-|")
str_c("|-",str_replace_na(x),"-|")

str_c("prefix-", c("a","b","c"), "-suffix")

# objects of length 0 are silently dropped. Useful with if statements
name <- "Hadley"
time_of_day <- "morning"
birthday <- FALSE
str_c(
  "Good ", time_of_day," ", name,
  if (birthday) " and HAPPY BIRTHDAY",
  "."
)

# can extract parts of a string using str_sub() to subset. Takes start and end args
x <- c("Apple", "Banana", "Pear")
str_sub(x, 1, 3)
# negative numbers count backwards from end
str_sub(x, -3, -1)
# doesnt fail is string is too short, just returns as much as possible
str_sub("a", 1, 5)
# can also use the assignment form of str_sub() to modify strings
str_sub(x, 1, 1) <- str_to_lower(str_sub(x, 1, 1))
x

####################### Regular Expression #######################
# str_view() and str_view_all() take a char vector and a regexp and show how they match

# Basic Matches
# install.packages("htmltools")
# install.packages("htmlwidgets")
str_view(x, "an")

# . matches any character (expect newline)
str_view(x, ".a.")

# how to match a . then?
# to create regexp, we need \\
dot <- "\\."
# but the expression itself only contains one:
writeLines(dot)
# and this tells R to look for an explicit
str_view(c("abc","a.c","bef"), "a\\.c")
# for "\"? need double to escape for regexp but that needs to be a string
# so for both \'s to escape need \\\\ (4) 
x <- "a\\b"
writeLines(x)

str_view(x, "\\\\")

# Exercises
# 2
y <- "\"'\\?"
y
str_view(y, "\\\\")

# 3
z <- "\\..\\..\\.."
writeLines(z)
str_view(".a.b.c", z)

# ANCHORS: anchors regexp to beginning or end of string
# ^ matches start of string
# $ matches end of string
# REMEMBER: if you begin with power(^), get end up with money ($)
x <- c("Apple", "Banana", "Pear")
str_view(x, "^A")
str_view(x, "a$")

# to force regexp to only match a complete string, anchor it with boht ^ and $
y <- c("apple pie", "apple", "apple cake")
str_view(y, "apple")
str_view(y, "^apple$")

# can also match the boundary between words with \b

# Exercises
# 1
a <- "$^$"
str_view(a, "^[$^]+$") # idk
# test <- c("ynjklf78914", "jnklwr", "rq67qbrfx", "yax")
test <- words
str_view(test, "^y", match = T)
str_view(test, "x$", match = T)
str_view(test, "^...$", match = T)
str_view(test, "^.{7,}", match = T)

# CHARACTER CLASSES AND ALTS
# \d matches any digit
# \s matches any whitespace (space, tab, newline)
# [abc] matches a, b, or c
# [^abc] matches anything except a, b, or c
# REMEMBER: still need to escape the \ for the string so really need "\\d" or "\\s"
# precedence is LOW

# can use alternation to pick between one or more alt patterns
str_view(c("grey", "gray"), "gre|ay") # different
str_view(c("grey", "gray"), "gr(e|a)y")

# Exercises
# 1
# start with a vowel
str_view(test, "^[aeiou]", match = TRUE)
# only contain consonants
str_view(test, "^[^aeiou]+$", match = TRUE) # plus says match pattern 1 or more times
# end with ed but not eed
str_view(test, "[^e]ed$", match = TRUE)
# end with ing or ize
str_view(test, "(ing|ize)$", match = TRUE)
# 2
str_view(test, "(cei|ie)", match = TRUE)
# 3
str_view(test, "q[aeiou]", match = T)
# 4
str_view(test, "i(s|z)e", match = T)
# 5
tel <- "1-\\d\\d\\d-\\d\\d\\d-\\d\\d\\d\\d"
writeLines(tel)
str_view("1-804-699-8300", tel)

# REPITITION
# ?: 0 or 1
# +: 1 or more
# *: 0 or more
# precedence is HIGH
x <- "1880 is the longest year in Roman numerals: MDCCCLXXXVIII"
str_view(x, "CC?")
str_view(x, "CC+")
str_view(x, "C[LX]+")

# colou?r to match british spellings

# can also specify the number of matches precisely
# {n}: exactly n times
# {n,} n or more
# {,m} at most m
# {n, m} between n and m
str_view(x, "C{2}")
str_view(x, "C{2,}")
str_view(x, "C{2,3}")

# default is greedy: match match longest possible. Can make them lazy by putting a ? after
str_view(x, "C{2,3}?")
str_view(x, "C[LX]+?")

# Exercises
str_view(test, "o{2}", match = TRUE)
# 3
# words that start with three consonants
str_view(test, "^[^aeiou]{3,}", match = T)
# have three or more vowels in a row
str_view(test, "[aeiou]{3,}", match = TRUE)
# have two or more vowel-consonant pairs in a row
str_view(test, "([aeiou][^aeiou]){2,}", match = T)

# GROUPING AND BACKREFERENCES
# parentheses define groups that you can refer to with backreferences like \1, \2, etc.
fruit
# finds all fruits with repeated pair of letters
str_view(fruit, "(..)\\1", match = TRUE)

# Exercises
screams <- "aaaaaaaaaaaahhhhhhhahahahahah"
str_view("aaaaaaaa", "(.)\\1\\1", match = T)
str_view(screams, "(h)(a)\\1\\2") # number refers to particular group (absolute), not closest
str_view(screams, "(..)\\1")
# 2
# start and end with same letter
str_view(test, "^(.).*\\1$", match = TRUE)
# contain a repeated pair of letters
str_view(test, "(..).*\\1", match = T)
# contain one letter repeated in at least three places
str_view(test, "(.)(.*\\1){2,}", match = T)

# DETECT MATCHES
# to determine if a char vector matches a pattern, use str_detect()
x <- c("apple","banana", "pear")
str_detect(x, "e")
# sum() useful bc FALSE becomes 0, TRUE = 1
# how many common words start with t?
sum(str_detect(words, "^t"))
# what proportion of common words end with a vowel?
mean(str_detect(words, "[aeiou]$"))

# if using complex logical conditions its easier to combine multiple str_detect() calls
# than one regexp
# two ways to find all words that dont contain any vowels
# find all words containing vowels and negate
no_vowels_1 <- !str_detect(words, "[aeiou]")
# find all words consisting only of consonants
no_vowels_2 <- str_detect(words, "^[^aeiou]+$")

identical(no_vowels_1, no_vowels_2)

# common use of str_detect() is to select elements that match a pattern
# can do this with logical subsetting,  or str_subset() wrapper
words[str_detect(words, "x$")]
str_subset(words, "x$")

df <- tibble(
  word = words,
  t = seq_along(word)
)
df %>%
  filter(str_detect(words, "x$"))

# variation of str_detect() is str_count()
# instead of T or F, tells you how many matches are in a string
x
str_count(x, "a")
# on avg, how many vowels per word?
mean(str_count(words, "[aeiou]"))

# can use str_count() with mutate()
df %>%
  mutate(
    vowels = str_count(word, "[aeiou]"),
    consonants = str_count(word, "[^aeiou]")
  ) 

# NOTE: matches never overlap
str_count("abababa", "aba")
str_view_all("abababa", "aba")

# Exercises
# 1
# all words that start or end with x
str_subset(words, "(^x|x$)")
# t1 <- c("x", "xgrkbj", "xnqeklrjbx", "qwerx")
x_start <- str_detect(words, "^x")
x_end <- str_detect(words, "x$")
c(words[x_start], words[x_end])
# all words that start with vowel and end with a consonant
str_subset(words, "^[aeiou].*[^aeiou]$")
v_st <- str_detect(words, "^[aeiou]")
v_end <- str_detect(words, "[^aeiou]$")
vc <- v_st & v_end
words[vc] # better
words[str_detect(words, "^[aeiou]") & str_detect(words, "[^aeiou]$")] # one line, but probs not best
c(words[v_st], words[v_end])
# any words that contain at least one of each different vowel
a <- str_detect(words, "a")
e <- str_detect(words, "e")
i <- str_detect(words, "i")
o <- str_detect(words, "o")
u <- str_detect(words, "u")
words[a&e&i&o&u] # no
cat <- c("wbgwjbgw", "aoieuhaau", "aaaakjkjbka")
str_view_all(cat, "([aeiou]).*(\\1)") # no clue
# which word ha hoghest num of vowels? High proportion?
df %>%
  mutate(
    vowel_num = str_count(word, "[aeiou]"),
    vowel_prop = vowel_num / str_length(word)
  ) %>%
  arrange(desc(vowel_num)) %>% # appropriate
  arrange(desc(vowel_prop)) # a, then area, idea, europe

# EXTRACT MATCHES
# use str_extract()
length(sentences)
head(sentences)
# find all sents that contain a color
colors <- c(" red", "orange", "yellow", "green", "blue", "purple")
color_match <- str_c(colors, collapse = "|")
color_match
# now select sents that contain a color, then extract color
has_color <- str_subset(sentences, color_match) # gets all sents that match exp
matches <- str_extract(has_color, color_match) # gets all words that were matched
head(matches)
# str_extract() only extracts hte first match
more <- sentences[str_count(sentences, color_match) > 1]
str_view_all(more, color_match)
str_extract(more, color_match)
# to get all matches, use str_extract_all()
str_extract_all(more, color_match)
# if you use simplify = TRUE, str_extrct_all() will retunr a matrix with short matches expanded
# to same lenght as longest
str_extract_all(more, color_match, simplify = TRUE)
x <- c("a","a b", "a b c")
str_extract_all(x, "[a-z]", simplify = TRUE)

# Exercises
# 1 
color_match <- str_c(colors, collapse = "| ")
color_match
more <- sentences[str_count(sentences, color_match) > 1]
str_view_all(more, color_match)
# 2
first_word <- "^[A-Z][a-z]+" # . not used here bc it matches whitespace too!
first <- str_subset(sentences, first_word)
str_extract(first, first_word)
str_view(first, first_word)
# all words ending in ing
exp <- "[A-Z]*[a-z]+ing(\\s|\\.)"
ing <- str_subset(sentences, exp)
str_extract(ing, exp)
# all plurals
exp <- "[a-z]+es\\s"
str_subset(sentences, exp) %>%
  str_extract(exp) # too many special cases, Im out.....

# GROUPED MATCHES
noun <- "(a|the) ([^ ]+)"
has_noun <- sentences %>%
  str_subset(noun) %>%
  head(10)
has_noun %>%
  str_extract(noun) # gives complete match
# str_match() gives each individual component
has_noun %>%
  str_match(noun)

tibble(sentence = sentences) %>%
  tidyr::extract(
    sentence, c("article", "noun"), noun,
    remove = FALSE
  )

# Exercises
# find all words that come after a number. pull out both the num and word
numbers <- c("(one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten)") %>%
  str_c(collapse = "|") %>%
  str_c(" ([^ ]+)")
str_subset(sentences, numbers) %>%
  str_match(numbers)
# fins all contractions. Separatr out the pieces before and after the apostrophe
contraction <- "([^ ]+)\\'([^ ]+)"
sentences %>%
  str_subset(contraction) %>%
  str_match(contraction)

# REPLACING MATCHES
# str_replace() and str_replace_all() allow you to replace matches with new strings
x <- c("apple", "pear", "banana")
str_replace(x, "[aeiou]", "-")
str_replace_all(x, "[aeiou]", "-")
# can perfomr multiple replacements with str_replace_all() by supplying named vector
x <- c("1 house", "2 cars", "3 people")
str_replace_all(x, c("1" = "one", "2" = "two", "3" = "three"))
# instead of replacing with a fixed string, you can use backreferences to insert components
# flip order of second and third word
sentences %>%
  str_replace("([^ ]+) ([^ ]+) ([^ ]+)", "\\1 \\3 \\2") %>%
  head(5)

# Exercises
# replace all forward slashes to backslashes
string <- "qr/wr  kjneqw\\/ qw//"
writeLines(string)
writeLines(str_replace_all(string, "/", "\\\\"))

# 3 switch the first and last letters in words
rev_words <- str_replace(words, "^([a-z])(.*)([a-z])$", "\\3\\2\\1")
rev_words
words[!is.na(str_match(words, rev_words))] # words still in words

# SPLITTING
# use str_split() to split a string up into pieces
sentences %>%
  head(5) %>%
  str_split(" ")
# bc each component is a diff length, returns a list
# if working with lenght 1 vector, easiest is to extract first element
"a|b|c|d" %>%
  str_split("\\|") %>%
  .[[1]]
# otherwise, can use simplify to return a matrix
sentences %>%
  head(5) %>%
  str_split(" ", simplify = TRUE)
# can also request maximum number of pieces
fields <- c("Name: Hadley", "Country: NZ", "Age: 35")
fields %>%
  str_split(": ", n = 2, simplify = TRUE)
# instead of splitting strings by patterns, can split by character, line , sent, and word boundary()
x <- "This is a sentence. This is anohter sentence."
str_view_all(x, boundary("word"))
str_split(x, " ")[[1]]
str_split(x, boundary("word"))[[1]]

# FIND MATCHES
# str_locate() and str_locate_all() give you the starting and ending positions of each match
# useful when none of the other functions does exactly what you want
# use str_locate() to find matching pattern and str_sub() to extract/modify

# OTHER PATTERNS
# when you use a pattern that's a string, its automatically wrapped into a call to regex()
# regular call
str_view(fruit, "nana")
# is shorthand for
str_view(fruit, regex("nana"))

# cna use other arguments of regex() to control details of match
# 1) ignore_case = TRUE allows characters to match either their uppercase or lowercase forms
#    always uses current locale
bananas <- c("banana", "Banana", "BANANA")
str_view(bananas, "banana")
str_view(bananas, regex("banana", ignore_case = TRUE))
# 2) multiline = TRUE allows ^ and $ to match the start and end of each line rather than the start
#    and end of the complete string
x <- "Line 1\nLine 2\nLine 3"
str_extract_all(x, "^Line")[[1]]
str_extract_all(x, regex("^Line", multiline = TRUE))[[1]]
# 3) comments = TRUE allows use of comments and white space to make complex regex more understandable
#    spaces are ignored, as is everything after #. TO match literal space, need to escape it: "\\ "
phone <- regex("
               \\(?     # optional opening parens
               (\\d{3}) # area code
               [)- ]?   # opt closing parens, dash, or space
               (\\d{3}) # another 3 nums
               [ -]?    # opt space or dash
               (\\d{3}) # 3 more nums
               ", comments = TRUE)
str_match("514-791-8141", phone)
# 4) dotall = TRUE allows . to match everything, including \n

# Other functions you can use instead of regex():
# 1) fixed() match exactly the specified sequence of bytes. It ignores all special regexps
#    and operates at a very low level. Allows avoiding complex escaping and can be much faster
#    than regex. Beware using with no-english data
# 2) coll() compares strings using standard collation rules. useful for doing case-
#    insensitive matching. Takes locale param. Downside is speed
# 3) boundary() as seen with str_split(), can use with other funcitons
str_view_all(x, boundary("word"))

# see default locale with:
stringi::stri_locale_info()

# Other uses of Regular Expressions
# two usful functions in base R that also use regex
# 1) apropos() searches all objects availible from the global environment. Useful if you cant
#    quite remember name of the function
apropos("replace")
# 2) dir() lists all the files in the directory. pattern arg takes a regex and only returns
#    filenames that match pattern
# find all R script files in current directory
head(dir(pattern = "\\.R$"))

# stringi is much more comprehensive than stringr! 
