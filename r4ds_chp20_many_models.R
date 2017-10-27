# Notes from R FOR DATA SCIENCE,
# an O'Reilly guide by Hadley Wickham and Garrett Grolemund
# Availible online at http://r4ds.had.co.nz/
# PART FOUR: Model
# Chapter 20: Many Models with purrr and broom

library(modelr)
library(tidyverse)

#################### gapminder #################### 
library(gapminder)
gapminder

gapminder %>%
  ggplot(aes(year, lifeExp, group = country)) +
    geom_line(alpha = 1/3)

# if had one country:
nz <- filter(gapminder, country == "New Zealand")
nz %>%
  ggplot(aes(year, lifeExp)) +
    geom_line() +
    ggtitle("Full data = ")

nz_mod <- lm(lifeExp ~ year, data = nz)
nz %>%
  add_predictions(nz_mod) %>%
  ggplot(aes(year, pred)) +
    geom_line() +
    ggtitle("Linear trend + ")

nz %>%
  add_residuals(nz_mod) %>%
  ggplot(aes(year, resid)) +
  geom_hline(yintercept = 0, color = "white", size = 3) +
  geom_line() +
  ggtitle("Remaining Pattern")

# NESTED DATA
# can repeat using a map function from purrr
# need a nested data frame here
by_country <- gapminder %>%
  group_by(country, continent) %>%
  nest()
by_country

# LIST-COLUMNS
country_model <- function(df) {
  lm(lifeExp ~ year, data = df)
}
models <- map(by_country$data, country_model)

by_country <- by_country %>%
  mutate(model = map(data, country_model))

by_country %>%
  filter(continent == "Europe")
by_country %>%
  arrange(continent, country)

# UNNESTING
by_country <- by_country %>%
  mutate(resids = map2(data, model, add_residuals))
by_country

resids <- unnest(by_country, resids)
resids

resids %>%
  ggplot(aes(year, resid)) +
    geom_line(aes(group = country), alpha = 1/3) +
    geom_smooth(se = FALSE)

resids %>%
  ggplot(aes(year, resid)) +
  geom_line(aes(group = country), alpha = 1/3) +
  geom_smooth(se = FALSE) +
  facet_wrap(~continent)

by_country2 <- by_country %>%
  mutate(preds = map2(data, model, add_predictions))
preds <- unnest(by_country2, preds)

preds %>%
  ggplot(aes(year, pred)) +
  geom_line(aes(group = country), color = "blue", alpha = 1/3) +
  geom_line(aes(year, lifeExp, group = country), alpha = 1/3)
preds %>%
  ggplot(aes(year, pred)) +
  geom_line(aes(group = country), color = "blue", alpha = 1/3) +
  geom_line(aes(year, lifeExp, group = country), alpha = 1/3) +
  facet_wrap(~continent)

# MODEL QUALITY
library(broom)
glance(nz_mod)

by_country %>%
  mutate(glance = map(model, glance)) %>%
  unnest(glance)
# dont stilll want the list-columns, use .drop = TRUE
glance <- by_country %>%
  mutate(glance = map(model, glance)) %>%
  unnest(glance, .drop = TRUE)
glance

# look for models that dont fit well
glance %>%
  arrange(r.squared)

glance %>%
  ggplot(aes(continent, r.squared)) +
  geom_jitter(width = 0.5)

bad_fit <- filter(glance, r.squared < 0.25)

gapminder %>%
  semi_join(bad_fit, by = "country") %>% # matches all obs in x that occur in y (ie. bad fits)
  ggplot(aes(year, lifeExp, color = country)) +
  geom_line()

# Exercises
quad_gap <- gapminder %>%
  mutate(year = year - 1980) %>%
  group_by(country, continent) %>%
  nest()

quad_model <- function(df) {
  lm(lifeExp ~ I(year^2), data = df)
}
quad_gap <- quad_gap %>%
  mutate(model = map(data, quad_model),
         resids = map2(data, model, add_residuals))
quad_resids <- quad_gap %>%
  unnest(resids)

quad_resids %>%
  ggplot(aes(year, resid)) +
  geom_line(aes(group = country), alpha = 1/3) +
  geom_smooth(se = FALSE)

quad_resids %>%
  ggplot(aes(year, resid)) +
  geom_line(aes(group = country), alpha = 1/3) +
  facet_wrap(~continent)

# 3
# idk

################# List-Columns ################# 
# data.frame() treats a list as a list of columns
data.frame(x = list(1:3, 3:5))

# can use I() to prevent this
data.frame(x = I(list(1:3, 3:5)),
           y = c("1, 2", "3, 4, 5"))
# tibble makes the print out look better
tibble(x = list(1:3, 3:5),
       y = c("1, 2", "3, 4, 5"))

tribble(
  ~x, ~y,
  1:3, "1, 2",
  3:5, "3, 4, 5"
)

# list columns are monst useflu as intermediate data structures, can keep items together
# Three parts of an effective list-column pipeline
# 1) create using nest(), summarize() + list() or mutate() + map()
# 2) create other intermediate list columns by transforming existing list columns with a
#   map function
# 3) simplify list-column back down to a df or aotmic vector

# CREATING LIST-COLUMNS ---------------------------------------------------
# CREATE FROM REGULAR COLUMNS USING ONE OF THREE METHODS
# 1) with tidyr::nest() to convert a grouped data frame into a nested df where you have a 
#    list-column of dfs
# 2) with mutate() and vectorized functions that return a list
# 3) with summarize() and asummary functions that return multiple results

# WITH NESTING
# two ways to use nest()
# with grouped df, keeps groups columns as is, bundles everything else
gapminder %>%
  group_by(country, continent) %>%
  nest()

# can use on an ungrouped df, specifying which cols you want to nest
gapminder %>%
  nest(year:gdpPercap)

# FROM VECTORIZED FUNCTIONS
df <- tribble(
  ~x1,
  "a,b,c",
  "d,e,f,g"
)
df %>%
  mutate(x2 = stringr::str_split(x1, ","))

df %>%
  mutate(x2 = stringr::str_split(x1, ",")) %>%
  unnest()

sim <- tribble(
  ~f, ~params,
  "runif", list(min = -1, max = -1),
  "rnorm", list(sd = 5),
  "rpois", list(lambda = 10)
)

sim %>%
  mutate(sims = invoke_map(f, params, n = 10))

# FROM MULTIVARIED SUMMARIES
# summarize() only works with summary functions that retunr a single value
# doesnt work with quartile() for ex
mtcars %>%
  group_by(cyl) %>%
  summarize(q = quantile(mpg))
# HOWEVER, you can wrap the rsult in a list
probs <- c(0.01, 0.25, 0.5, 0.75, 0.99)
mtcars %>%
  group_by(cyl) %>%
  summarize(p = list(probs), q = list(quantile(mpg, probs))) %>%
  unnest()

# FROM A NAMED LIST
# tibble::enframe()
x <- list(
  a = 1:5,
  b = 3:4,
  c = 5:6
)
  
df = enframe(x)
df

# if you want to iterate over names and values in parallel, can use map2()
# I think the ~ and the .x is used here because normally you dont specify the args
# of the function called within map, so when you do, you hve to do this?
# .x refers to the first column, .y refers to the 2nd. Idk how far it goes
df %>% 
  mutate(smry = map2_chr(name, value, ~ stringr::str_c(.x, ":", .y[1])))

# Exercises
mtcars %>%
  group_by(cyl) %>%
  summarize(q = list(quantile(mpg))) %>%
  unnest()

# 4
mtcars %>%
  group_by(cyl) %>%
  summarize_all(funs(list)) %>%
  str()

############## Simplifying List-Columns ############## 
# if you want a single value per element, use mutate() with map_lgl(), map_int(), 
# map_dbl(), map_chr() to creat an atomic vector

# if you want mnay values per elements, use unnest() to convert list-columns back to 
# regular columns, repeating the rows as many times as necessary

# LIST TO VECTOR ----------------------------------------------------------
df <- tribble(
  ~x,
  letters[1:5],
  1:3,
  runif(5)
)
df %>% mutate(type = map_chr(x, typeof),
              length = map_int(x, length))

# can use map_chr(x, "apple") to extract the string stored in apple of each element of x
df <- tribble(
  ~x,
  list(a = 1, b = 2),
  list(a = 2, d = 4)
)
df %>%
  mutate(a = map_dbl(x, "a", .null = NA_real_),
         b = map_dbl(x, "b", .null = NA_real_))

# UNNESTING ---------------------------------------------------------------
# unnest() wokrs by repeating the regular cols once for each element in the list
tibble(x = 1:2, y = list(1:4, 1)) %>% unnest()
# cant simultaneously unnest two cols with diff num of elements
df1 <- tribble(
  ~x, ~y, ~z,
  1, c("a","b"), 1:2,
  2, "c", 3
)
df1
df1 %>% unnest(y, z) # ok because y and z have same num of elements in every row

df2 <- tribble(
  ~x, ~y, ~z,
  1, "a", 1:2,
  2, c("a", "b"), 3
)
df2
df2 %>% unnest(y, z)

# broom package for making tidy data:
# glance, tidy, augment
broom::glance(nz_mod)
broom::tidy(nz_mod)
broom::augment(nz_mod, nz)
