# Notes from R FOR DATA SCIENCE,
# an O'Reilly guide by Hadley Wickham and Garrett Grolemund
# Availible online at http://r4ds.had.co.nz/
# PART TWO: Wrangle
# Chapter 12: Factors with forcats

library(tidyverse)
library(forcats)

################# Creating Factors #################
x1 <- c("Dec", "Apr", "Jan", "Mar")
# two problems w/ using a string for thisL
# 1) only 12 possible months, nothing saving you from typos
x2 <- c("Dec", "Apr", "Jam", "Mar")
# 2) doesn't sort in a meaningful way

# can fi both probs with a factor. to create, must start by creating list of the valid levels
month_levels <- c("Jan", "Feb", "Mar", "Apr", "May","June","July","Aug","Sep","Oct","Nov","Dec")
# now can create factor
y1 <- factor(x1, levels = month_levels)
y1
sort(y1)
# any values not in set will be silently converted to NA
y2 <- factor(x2, levels = month_levels)
y2
# if you omit levels, they will be taken from data in alpha order
factor(x1)

# sometimes you'd prefer the order of levels match the order of first appearance in data
# can do that when creating factor by setting levels to unique(x), or after the fact with fct_inorder()
f1 <- factor(x1, levels = unique(x1))
f1
f2 <- x1 %>% factor() %>% fct_inorder()
# if you need to access the set of valid levels directly, can do so with levels()
levels(f2)

forcats::gss_cat

# when factors are stored in a tibble, you can't see their levels so easily. Can see with count()
gss_cat %>%
  count(race)
# or with bar chart
gss_cat %>%
  ggplot(aes(race)) +
    geom_bar()
# ggplot2 default will drop levels that dont have any values. Can force display with:
gss_cat %>%
  ggplot(aes(race)) +
    geom_bar() +
    scale_x_discrete(drop = FALSE)

# Exercises
ggplot(gss_cat, aes(rincome)) +
  geom_bar() +
  coord_flip()
# This doesn't work
ggplot(gss_cat, aes(x = reorder(relig, n), n)) +
  geom_bar(stat = "identity") +
  coord_flip()
# reordering categoies based on count (rank)
gss_cat %>%
  count(relig) %>% # might have to creat this count? seems unnessary but here we are...
  ggplot(aes(reorder(relig, -n), n)) +
    geom_bar(stat = "identity") +
    coord_flip()

gss_cat %>%
  count(partyid) %>% # might have to creat this count? seems unnessary but here we are...
  ggplot(aes(reorder(partyid, -n), n)) +
  geom_bar(stat = "identity") +
  coord_flip()
# obviously protestant
library(stringr)
gss_cat %>%
  group_by(relig, denom) %>%
  count(relig) %>%
  filter(!str_detect(denom, "(No|Don)"))

################ Modifying Factor Order ################ 
relig <- gss_cat %>%
  group_by(relig) %>%
  summarize(
    age = mean(age, na.rm = TRUE),
    tvhours = mean(tvhours, na.rm = TRUE),
    n = n()
  )
ggplot(relig, aes(tvhours, relig)) +
  geom_point()
# can improve by reordering levels of relig using fct_reorder(). Takes 3 args:
# 1) f, the factor whose levels you want to modify
# 2) x, a numeric vector you want to use to reorder the levels
# 3) optionally fun, a funciton used if there are multiple values of x fro each value of f
ggplot(relig, aes(tvhours, fct_reorder(relig, tvhours))) +
  geom_point()

# as you start making more complicated transformations, good idea to move out of aes() and
# into separate mutate() step. ex:
relig %>%
  mutate(relig = fct_reorder(relig, tvhours)) %>%
  ggplot(aes(tvhours, relig)) +
  geom_point()
# similar plot looking at how avg age varies across reported income level
rincome <- gss_cat %>%
  group_by(rincome) %>%
  summarize(
    age = mean(age, na.rm = TRUE),
    tvhours = mean(tvhours, na.rm = TRUE),
    n = n()
  )
ggplot(rincome,
       aes(age, fct_reorder(rincome, age))) +
  geom_point()
# here it doesn't make sense to reorder rincome! 
# makes sense to pull not applicable though with fct_relevel()
ggplot(rincome, aes(age, fct_relevel(rincome, "Not applicable"))) +
  geom_point()

# another type of reordering is useful when you are coloring the lines ona  plot
# fct_reorder2() reorders the factor by the y values associated with the largest x values
by_age <- gss_cat %>%
  filter(!is.na(age)) %>%
  group_by(age, marital) %>%
  count() %>%
  mutate(prop = n / 21407) # gotten from sum(by_age$n), NOT from sum(n)

ggplot(by_age, aes(age, prop, color = marital)) +
  geom_line(na.rm = TRUE)

ggplot(by_age, aes(age, prop, color = fct_reorder2(marital, age, prop))) +
  geom_line() +
  labs(color = "marital")

# for bar plots, can use fct_infreq() to order levels in increasing frequency
# can combine with fct_rev(), which reverses the order (lowest - highest vs. highest - lowest)
gss_cat %>%
  mutate(marital = marital %>% fct_infreq() %>% fct_rev()) %>%
  ggplot(aes(marital, fill = "red")) +
    geom_bar(show.legend = F)

################### Modifying Factor Levels ###################
# most general and powerful: fct_recode()
gss_cat %>% count(partyid)
# levels terse, inconsistant
gss_cat %>%
  mutate(partyid = fct_recode(partyid, 
    "Republican, strong" = "Strong republican",
    "Republican, weak"   = "Not str republican",
    "Independent, near rep" = "Ind,near rep",
    "Independent, near dem" = "Ind,near dem",
    "Democrat, weak"     = "Not str democrat",
    "Democrat, strong"   = "Strong democrat"
  )) %>%
  count(partyid)
# fct_recode() will leave levels that aren't explicitly mentioned as is and will warm is you refer
# to a nonexistant level

# to combine groups you can assign multiple old levels to the same new level
gss_cat %>%
  mutate(partyid = fct_recode(partyid,
                              "Republican, strong" = "Strong republican",
                              "Republican, weak"   = "Not str republican",
                              "Independent, near rep" = "Ind,near rep",
                              "Independent, near dem" = "Ind,near dem",
                              "Democrat, weak"     = "Not str democrat",
                              "Democrat, strong"   = "Strong democrat",
                              "Other" = "No answer",
                              "Other" = "Don't know",
                              "Other" = "Other party"
  )) %>%
  count(partyid)

# if you want to collapse a lot of levels, fct_collaspe is a useful variant of fct_recode()

# to lump together all the small groups to make a plot or table simpler use fct_lump()
gss_cat %>%
  mutate(relig = fct_lump(relig)) %>%
  count(relig)
# can use n parameter to avoid overcollapsing
gss_cat %>%
  mutate(relig = fct_lump(relig, n = 10)) %>%
  count(relig, sort = TRUE) %>%
  print(n = Inf)

# Exercises
gss_cat %>%
  mutate(partyid = fct_collapse(partyid,
    other = c("No answer", "Don't know", "Other party"),
    rep = c("Strong republican", "Not str republican"),
    ind = c("Ind,near rep", "Independent", "Ind,near dem"),
    dem = c("Not str democrat", "Strong democrat")
  )) %>%
  group_by(year) %>%
  count(partyid) %>%
  mutate(prop = n / sum(n)) %>%
  ggplot(aes(year, prop, color = fct_reorder2(partyid, year, prop))) +
    geom_line() +
    labs(color = "partyid")


 
  