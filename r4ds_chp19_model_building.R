# Notes from R FOR DATA SCIENCE,
# an O'Reilly guide by Hadley Wickham and Garrett Grolemund
# Availible online at http://r4ds.had.co.nz/
# PART FOUR: Model
# Chapter 19: Model Building

library(tidyverse)
library(modelr)
options(na.action = na.warn)

library(nycflights13)
library(lubridate)

################# Why are Low-Quality Diamonds More Expensive? #############
ggplot(diamonds, aes(cut, price)) + geom_boxplot()
ggplot(diamonds, aes(color, price)) + geom_boxplot()
ggplot(diamonds, aes(clarity, price)) + geom_boxplot()

ggplot(diamonds, aes(carat, price)) +
  geom_hex(bins = 50)

# tweak diamond dataset: focus on diamonds smaller than 2.5 carats, 
# log transform carat and price
diamonds2 <- diamonds %>%
  filter(carat <= 2.5) %>%
  mutate(lprice = log2(price), lcarat = log2(carat))

ggplot(diamonds2, aes(lcarat, lprice)) +
  geom_hex(bins = 50)

mod_diamond <- lm(lprice ~ lcarat, data = diamonds2)

grid <- diamonds2 %>%
  data_grid(carat = seq_range(carat, 20)) %>%
  mutate(lcarat = log2(carat)) %>%
  add_predictions(mod_diamond, "lprice") %>%
  mutate(price = 2 ^ lprice)

ggplot(diamonds2, aes(carat, price)) +
  geom_hex(bins = 50) +
  geom_line(data = grid, color = "red", size = 1)

diamonds2 <- diamonds2 %>%
  add_residuals(mod_diamond, "lresid")

ggplot(diamonds2, aes(lcarat, lresid)) +
  geom_hex(bins = 50)

ggplot(diamonds2, aes(cut, lresid)) + geom_boxplot()
ggplot(diamonds2, aes(color, lresid)) + geom_boxplot()
ggplot(diamonds2, aes(clarity, lresid)) + geom_boxplot()

mod_diamond2 <- lm(lprice ~ lcarat + color + cut + clarity,
                   data = diamonds2)

grid <- diamonds2 %>%
  data_grid(cut, .model = mod_diamond2) %>%
  add_predictions(mod_diamond2)
grid

ggplot(grid, aes(cut, pred)) +
  geom_point()

diamonds2 <- diamonds2 %>%
  add_residuals(mod_diamond2, "lresid2")
ggplot(diamonds2, aes(lcarat, lresid2)) +
  geom_hex(bins = 50)

diamonds2 %>%
  filter(abs(lresid2) > 1) %>%
  add_predictions(mod_diamond2) %>%
  mutate(pred = round(2 ^ pred)) %>%
  select(price, pred, carat:table, x:z) %>%
  arrange(price)

# Exercises
ggplot(diamonds2, aes(lcarat, lprice)) +
  geom_hex(bins = 50)

# 3
diamonds2 %>%
  filter(abs(lresid2) > 1.5 | abs(lresid2) < .0001) %>%
  add_predictions(mod_diamond2) %>%
  mutate(pred = round(2 ^ pred)) %>%
  select(price, pred, carat:table, x:z) %>%
  arrange(price)

######### What affects the number of Daily Flights? ##########
daily <- flights %>%
  mutate(date = make_date(year, month, day)) %>%
  group_by(date) %>%
  summarize(n = n())
daily

ggplot(daily, aes(date, n)) +
  geom_line()

daily <- daily %>%
  mutate(wday = wday(date, label = TRUE))

ggplot(daily, aes(wday, n)) +
  geom_boxplot()
ggplot(daily, aes(reorder(wday, n, fun = median), n)) +
  geom_boxplot()

mod <- lm(n ~ wday, data = daily)
mod

grid <- daily %>%
  data_grid(wday) %>%
  add_predictions(mod, "n")

ggplot(daily, aes(wday, n)) +
  geom_boxplot() +
  geom_point(data = grid, color = "red", size = 3)

# compute and add residuals
daily <- daily %>%
  add_residuals(mod)
daily %>%
  ggplot(aes(date, resid)) +
  geom_ref_line(h = 0) +
  geom_line()

ggplot(daily, aes(date, resid, color = wday)) +
  geom_ref_line(h = 0) +
  geom_line()

daily %>%
  filter(resid < -100)

daily %>%
  ggplot(aes(date, resid)) +
  geom_ref_line(h = 0) +
  geom_line(color = "grey50") +
  geom_smooth(se = FALSE, span = 0.20)

# SEASONAL SATURDAY EFFECTS
daily %>%
  filter(wday == "Sat") %>%
  ggplot(aes(date, n)) +
  geom_point() +
  geom_line() +
  scale_x_date(NULL,
               date_breaks = "1 month",
               date_labels = "%b")

term <- function(date) {
  cut(date,
      breaks = ymd(20130101, 20130605, 20130825, 20140101),
      labels = c("spring", "summer", "fall"))
}

daily <- daily %>%
  mutate(term = term(date))
daily

daily %>%
  filter(wday == "Sat") %>%
  ggplot(aes(date, n, color = term)) +
  geom_point(alpha = 1/3) +
  geom_line() +
  scale_x_date(NULL,
               date_breaks = "1 month",
               date_labels = "%b")

daily %>%
  ggplot(aes(wday, n, color = term)) +
  geom_boxplot()

mod1 <- lm(n ~ wday, data = daily)
mod2 <- lm(n ~ wday * term, data = daily)
daily %>%
  gather_residuals(without_term = mod1, with_term = mod2) %>%
  ggplot(aes(date, resid, color = model)) +
  geom_line(alpha = 3/4)

grid <- daily %>%
  data_grid(wday, term) %>%
  add_predictions(mod2, "n")
ggplot(daily, aes(wday, n)) + 
  geom_boxplot() +
  geom_point(data = grid, color = "red") +
  facet_wrap(~ term)

# MASS:rlm() is robust to the effect of outliers
mod3 <- MASS::rlm(n ~ wday * term, data = daily)

daily %>%
  add_residuals(mod3, "resid") %>%
  ggplot(aes(date, resid)) + 
  geom_hline(yintercept = 0, size = 2, color = "white") +
  geom_line()

# Exercises
# 2
daily %>%
  top_n(3, resid)
daily %>%
  arrange(desc(resid)) %>%
  head(3)

# 3
library(stringr)
daily %>% print(n = 365)
daily_spl <- 
  daily %>% 
  mutate(wday_split = ifelse(wday == "Sat", 
                             str_c("Sat-", term), 
                             as.character(wday(date, label = TRUE))))
mod4 <- MASS::rlm(n ~ wday_split, data = daily_spl)
daily_spl %>%
  add_residuals(mod4, "resid") %>%
  ggplot(aes(date, resid)) + 
  geom_hline(yintercept = 0, size = 2, color = "white") +
  geom_line()

# 4
pub_hol <- daily %>% 
  filter(resid < -100) %>%
  mutate(hol = "hol")
daily_holiday <- daily_spl %>%
  left_join(pub_hol) %>%
  mutate(hol = ifelse(is.na(hol), "non_hol", hol)) %>%
  mutate(wday_comb = str_c(wday_split, hol, sep = "_"))

mod5 <- MASS::rlm(n ~ wday_comb, data = daily_holiday)
daily_holiday %>%
  add_residuals(mod5, "resid") %>%
  ggplot(aes(date, resid)) + 
  geom_hline(yintercept = 0, size = 2, color = "white") +
  geom_line() 

# 5
daily_month <- daily %>%
  mutate(month = month(date, label = TRUE))
mod6 <- MASS::rlm(n ~ wday * month, data = daily_month)
daily_month %>%
  add_residuals(mod6, "resid") %>%
  ggplot(aes(date, resid)) +
  geom_hline(yintercept = 0, size = 2, color = "white") +
  geom_line()

# 6
ns_mod <- MASS::rlm(n ~ wday + splines::ns(date, 5), data = daily)
daily_month %>%
  add_residuals(ns_mod, "resid") %>%
  ggplot(aes(date, resid)) +
  geom_hline(yintercept = 0, size = 2, color = "white") +
  geom_line()

grid <- daily %>%
  data_grid(date, wday) %>%
  add_predictions(ns_mod, "n") %>%
  filter(wday == wday(date, label = TRUE))
ggplot(daily, aes(date, n)) +
  geom_line() +
  geom_line(data = grid, color = "red")

# 7
daily
make_datetime_100 <- function(time) { 
  make_datetime(2013, 1, 1, time %/% 100, time %% 100) 
}
breaks <- seq(
  from=as.POSIXct("2013-1-1 0:00", tz="UTC"),
  to=as.POSIXct("2013-1-1 24:00", tz="UTC"),
  by="hour"
)  

sunday <- flights %>%
  mutate(date = make_date(year, month, day),
         wday = wday(date, label = TRUE),
         time = make_datetime_100(sched_dep_time),
         cut = cut(time, breaks = breaks)) %>%
  select(date, wday, time, distance, cut)

sunday %>%
  group_by(cut, wday) %>%
  summarize(avg_dist = mean(distance),
            n = n()) %>%
  ggplot(aes(cut, avg_dist, group = wday, color = wday)) +
    geom_line()

