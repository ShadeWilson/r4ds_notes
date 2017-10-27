# Notes from R FOR DATA SCIENCE,
# an O'Reilly guide by Hadley Wickham and Garrett Grolemund
# Availible online at http://r4ds.had.co.nz/
# PART TWO: Wrangle
# Chapter 13: Dates and Times with lubridate
library(tidyverse)
library(lubridate)

library(nycflights13)

################### Creating Date/Times ###################
# three types: date, time, date-time (POSIXct)
# if need to store just times, use hms package

# to get current data or date-time use today() or now()
today()
now()

# otherwsie can create via a string, individual date-time components, and existing dttm object

# FROM STRINGS
# can use parsers (chp 8)
# lubridate can work out format once you specify the order
ymd("2017-01-31") # arrange m, d, y of function name according to order in data
mdy("january 31st, 2017")
dmy("31-Jan-2017") 
# these functions also take unquoted data
ymd(20170131)
ymd(170131)

# ymd() and friends create dates. TO create date-time, add and underscore and 1+ of h, m, s
ymd_hms("2017-01-31 20:11:59")
mdy_hm("01/31/2017 08:01")

# can also force creation of dttm from a date by supplying a time zone
ymd(20170131, tz = "UTC")

# FROM INDIVIDUAL COMPONENTS
flights %>%
  select(year, month, day, hour, minute)
# to make a dttm from this, use make_date() for dates, make_datetime() for date-times
flights %>%
  select(year, month, day, hour, minute) %>%
  mutate( departure = make_datetime(year, month, day, hour, minute))

make_datetime_100 <- function(year, month, day, time) { 
  make_datetime(year, month, day, time %/% 100, time %% 100) 
}

flights_dt <- flights %>%
  filter(!is.na(dep_time), !is.na(arr_time)) %>%
  mutate(dep_time = make_datetime_100(year, month, day, dep_time),
         arr_time = make_datetime_100(year, month, day, arr_time),
         sched_dep_time = make_datetime_100(year, month, day, sched_dep_time),
         sched_arr_time = make_datetime_100(year, month, day, sched_arr_time)
  ) %>%
  select(origin, dest, ends_with("delay"), ends_with("time"))

flights_dt

# dep times across a year
flights_dt %>%
  ggplot(aes(dep_time)) +
    geom_freqpoly(binwidth = 86400) # 86400 seconds in a day
# dep times on a single day
flights_dt %>%
  filter(dep_time < ymd(20130102)) %>%
  ggplot(aes(dep_time)) +
    geom_freqpoly(binwidth = 600) # 600 s = 10 mins

# FROM OTHER TYPES
# may want to switch between date-time and date: as_datetime(), as_date()
as_datetime(today())
as_date(now())

# dealing with offsets from 1970-01-01
# if offset in seconds use as_datetime(), if in dats us as_date()
as_datetime(60*60*10)
as_date(365*10+2)

####################### Date-Time Components #######################

# GETTING COMPONENTS
# can pull out indiv parts with year() month() mday() yday() wday() hour() minute() second()
# mday(): day of the month
# yday() day of the year
# wday() day of the week
datetime <- ymd_hms("2016-07-08 12:34:56")

year(datetime)
month(datetime)
mday(datetime) # date within the month
yday(datetime) # date within the year
wday(datetime) # date within the week

# for month() and wday() can set label = TRUE to return the abbrev. name of month/day
# abbrev = FALSE to get full name
month(datetime, label = TRUE)
wday(datetime, label = TRUE, abbr = FALSE)

# can use wday() to see that more lfights depart during the week
flights_dt %>%
  mutate(wday = wday(dep_time, label = TRUE)) %>%
  ggplot(aes(x = wday)) +
    geom_bar()
# pattern of less delay when plans depart on 20-30 and 50-60
flights_dt %>%
  mutate(minute = minute(dep_time)) %>%
  group_by(minute) %>%
  summarize(avg_delay = mean(arr_delay, na.rm = TRUE),
            n = n()) %>%
  ggplot(aes(minute, avg_delay)) +
    geom_line()
# but no pattern seen with scheduled depart times, aka theres not a lot more flights leaving
# at 20-30 mins and 50-60 mins to bring down the std dev
sched_dep <- flights_dt %>%
  mutate(minute = minute(sched_dep_time)) %>%
  group_by(minute) %>%
  summarize(avg_delay = mean(arr_delay, na.rm = TRUE),
            n = n()
  )
ggplot(sched_dep, aes(minute, avg_delay)) +
  geom_line()

# humans like to leave at "nice" times
ggplot(sched_dep, aes(minute, n)) +
  geom_line()

# ROUNDING
# can round date to nearby unit of time instead of pulling comps using floor_date(),
# round_date(), and ceiling_date()
# flights per week
flights_dt %>%
  count(week = floor_date(dep_time, "week")) %>%
  ggplot(aes(week, n)) +
    geom_line()

# SETTING COMPONENTS
# can use accessor function to set hte componenets of a date/time
(datetime <- ymd_hms("2016-07-08 12:34:56"))
year(datetime) <- 2020
(month(datetime) <- 01)
datetime
hour(datetime) <- hour(datetime) + 1
datetime
# instead of modifying in place, can create a new date-time with update()
# can set multiple variables at once
update(datetime, year = 2020, month = 2, mday = 2, hour = 2)
# if values are too big they roll over
ymd("20150201") %>%
  update(mday = 30)
ymd(20150201) %>%
  update(hour = 400)

# can use update() to show the distribution of flights across the course of the day for every day
# pushes all data to same day so can show one one day graph!
flights_dt %>%
  mutate(dep_hour = update(dep_time, yday = 1)) %>%
  ggplot(aes(dep_hour)) +
    geom_freqpoly(binwidth = 300)

# Exercises
# 1
flights_dt %>%
  group_by(month(dep_time)) %>%
  mutate(dep_hour = update(dep_time, yday = 1)
         ) %>%
  ggplot(aes(dep_hour, group = month(dep_time), color = month(dep_time))) +
  geom_freqpoly(binwidth = 300)
# 5
flights_dt %>%
  group_by(wday(dep_time)) %>%
  mutate(dep_wday = update(dep_time, month = 1, mday = wday(dep_time, label = TRUE)),
         avg_delay = mean(arr_delay, na.rm = TRUE)) %>%
  ggplot(aes(dep_wday, avg_delay)) +
    geom_bar(stat = "identity")
# better way
flights_dt %>%
  mutate(dep_wday = wday(dep_time, label = TRUE)) %>%
  group_by(dep_wday) %>%
  summarize(avg_delay = mean(arr_delay, na.rm = TRUE), 
         n = n()) %>%
  ggplot(aes(dep_wday, avg_delay)) +
    geom_bar(stat = "identity")
    

######################### Time Spans ######################### 
# durations represtent an exact number of seconds
# periods represent human units like weeks and months
# intervals represent a starting and ending point

# DURATIONS
# when you subtract two days, you get a difftime obj
h_age <- today() - ymd(19791014)
h_age
# difftime obj records a time span of seconds, minutes, hours, days, or weeks
# ambiguity is difficult so alt always uses seconds (duration)
as.duration(h_age)
# convenient constructors
dseconds(15)
dminutes(10)
dhours(c(12, 24))
ddays(0:5)
dweeks(3)
dyears(1)

# can add and mult durations
2 * dyears(1)
dyears(1) + dweeks(12) + dhours(15)
# can add and subtract durations tp and from days
tomorrow <- today() + ddays(1)
last_year <- today() - dyears(1)
# sometimes bc durations are an exact num of seconds you might get an unexpected result
one_pm <- ymd_hms("2016-03-12 13:00:00", tz = "America/New_York")
one_pm
one_pm + ddays(1) # diff bc daylihgt savings time!

# PERIODS
# time spans but dont have fixed lengths in seconds. Work with "human" times so more intuitive
one_pm 
one_pm + days(1)
# like durations, have a number of constructor functions
seconds(15)
minutes(10)
hours(c(12, 24))
days(7)
months(1:6)
weeks(3)
years(1)
# can add and mult periods
10 * (months(6) + days(1))
days(50) + hours(25) + minutes(2)
# can add to dates in more expected ways
# leap year
ymd("2016-01-01") + dyears(1)
ymd("2016-01-01") + years(1)

# Daylight savings
one_pm + ddays(1)
one_pm + days(1)

# some planes arrive before thye depart (overnight flights)
flights_dt %>%
  filter(arr_time < dep_time)
# can fix by adding days(1) to the arrival times of each overnight flight
flights_dt <- flights_dt %>%
  mutate(overnight = arr_time < dep_time, # either TRUE (1) or FALSE (0)
         arr_time = arr_time + days(overnight),
         sched_arr_time = sched_arr_time + days(overnight)
)
flights_dt %>%
  filter(overnight, arr_time < dep_time)

# INTERVALS
dyears(1) / ddays(1)
years(1) / days(1)
# intervals are more accurate. have a starting point and a duration
next_year <- today() + years(1)
(today() %--% next_year) / ddays(1)
# to find out how many periods fall into an interval need integer division
(today() %--% next_year) %/% days(1)

####################### Time Zones ####################### 
Sys.timezone()
# see complete list with OlsonNames()
length(OlsonNames())
head(OlsonNames())
# lubriadate always uses UTC unless otherwise specified