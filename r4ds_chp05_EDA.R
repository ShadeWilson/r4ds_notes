# Notes from R FOR DATA SCIENCE,
# an O'Reilly guide by Hadley Wickham and Garrett Grolemund
# Availible online at http://r4ds.had.co.nz/
# PART ONE: EXPLORE
# Chapter 5: Exploratory Data Analysis

# SHORTCUTS:
# restart R: Cmd/Ctrl-Shift-F10
# rerun current script: Cmd/Ctrl-Shift-S

# 1) Generate questions about your data
# 2) search for answers by visualizing, transforming, and modeling your data
# 3) Use what you learn to refine your questions, and/or generate new questions

library(tidyverse)

# Its all about asking the right, quality questions:
# which is achieved through asking lots and lots of questions

# Two types of questions will always be useful:
# 1) what type of variation occurs within my variables?
# 2) What type of covariation occurs between my variables?

################### VARIATION ########################
# Visualizing distributions
# categorical: variable can only take on one small set of values
ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut))
# can compute the height of the displayed bars using dpylr::count
diamonds %>%
  count(cut)

# continuous: variable can take any of an infinite set of ordered values
ggplot(data = diamonds) +
  geom_histogram(mapping = aes(x = carat), binwidth = 0.5)
# can compute by hand using dplyr::count() and ggplot2::cut_width()
diamonds %>%
  count(cut_width(carat, 0.5))

# always explore binwidths as different binwidths can show different patterns
smaller <- diamonds %>%
  filter(carat < 3)
ggplot(data = smaller, mapping = aes(x = carat)) +
  geom_histogram(binwidth = 0.1)

# geom_freqpoly is good for overlaying multiple histograms in a single plot
# uses lines instead of bars
ggplot(data = smaller, mapping = aes(x = carat, color = cut)) +
  geom_freqpoly(binwidth = 0.1)

# Look for anything unexpected:
# Which values are the most common? WHy?
# Which values are rare? WHy? Does that match your expectations?
# Can you see any unusual patterns? What might that explain?

ggplot(data = smaller, mapping = aes(x = carat)) +
  geom_histogram(binwidth = 0.01)

ggplot(data = faithful, mapping = aes(x = eruptions)) +
  geom_histogram(binwidth = 0.25)

##################### Outliers ######################
ggplot(diamonds) +
  geom_histogram(mapping = aes(x = y), binwidth = 0.5)
# ZOOM IN TO SMALL VALUES WITH COORD_CARESIAN
ggplot(diamonds) +
  geom_histogram(mapping = aes(x = y), binwidth = 0.5) +
  coord_cartesian(ylim = c(0, 50)) # messing with y limit here
ususual <- diamonds %>%
  filter(y < 3 | y > 20) %>%
  arrange(y)
ususual # y variable measures one of the three dimentions of the diamonds in mm

# It's good proactice to repeat analysis with and without the outliers. If they
# don't affect results much and you don't know why they're there yuo can remove them
# But you shouldn't drop them without justification if they have a substantial effect
# Disclose the reason (eg data entry error) in write-up

######################## Missing values ##########################
# If you've encountered unusual values and want to move on, you have two options
# 1) drop the entire row with strange values
diamonds2 <- diamonds %>%
  filter(between(y, 3, 20))
# not recommended bc just because one meaurement is invaild doesn't mean the rest are
# Plus, if you have low quality data, by the time you've applied this approach
# you might not have any data left

# 2) replace the unusual values with missing values using mutate() anf ifelse()
diamonds2 <- diamonds %>%
  mutate(y = ifelse(y < 3 | y > 20, NA, y))
# ifelse() has three arguemnts: 1st is a logical vector, 2nd is value of result when TRUE,
# 3rd is value when FALSE

# ggplot warns if missing values are removed
ggplot(data = diamonds2, mapping = aes(x = x, y = y)) +
  geom_point()
# supress this warning with na.rm = TRUE
ggplot(data = diamonds2, mapping = aes(x = x, y = y)) +
  geom_point(na.rm = TRUE)

# Comparing scheduled departure times between canceled and noncanceled flights
# nycflights13::flights
nycflights13::flights %>%
  mutate(
    cancelled = is.na(dep_time),
    sched_hour = sched_dep_time %/% 100,
    sched_min = sched_dep_time %% 100,
    sched_dep_time = sched_hour + sched_min / 60
  ) %>%
  ggplot(mapping = aes(sched_dep_time)) +
    geom_freqpoly(mapping = aes(color = cancelled),
                  binwidth = 1/4
    )

###################### Covariation ######################
# default geom_freqpoly() is not that useful for comparison between categorical variables
# bc height is tied to count
# Lets explore how price of diamonds varies with quality
ggplot(data = diamonds, mapping = aes(x = price)) +
  geom_freqpoly(mapping = aes(color = cut), binwidth = 500)
# hard to see distribtion bc overall counts differ so much:
ggplot(diamonds) +
  geom_bar(mapping = aes(x = cut))
# to make comparison easier we need to swap what is displayed on the y axis
# instead of displaying count we'll display density (count standardized to area)
ggplot(data = diamonds, 
       mapping = aes(x = price, y = ..density..)) +
  geom_freqpoly(mapping = aes(color = cut), binwidth = 500)

# another alternative to display the distribution of a cont variable is the boxplot
ggplot(data = diamonds, mapping = aes(x = cut, y = price)) +
  geom_boxplot()
# seems that better quality diamonds are cheaper on average

# can reorder categorical varaibles with reorder()
ggplot(data = mpg, mapping = aes(x = class, y = hwy)) +
  geom_boxplot()
# to make the trend easier to see we can reorder class based on the median hwy value
ggplot(data = mpg) +
  geom_boxplot(
    mapping = aes(
      x = reorder(class, hwy, FUN = median),
      y = hwy
    )
  )
# if you have long variables names, geom_boxplot() works better if you flip it 90˚ w/ coord_flip()
ggplot(data = mpg) +
  geom_boxplot(
    mapping = aes(
      x = reorder(class, hwy, FUN = median),
      y = hwy
    )
  ) +
  coord_flip()

# Exercises
# 1
nycflights13::flights %>%
  mutate(
    cancelled = is.na(dep_time),
    sched_hour = sched_dep_time %/% 100,
    sched_min = sched_dep_time %% 100,
    sched_dep_time = sched_hour + sched_min / 60
  ) %>%
  ggplot(mapping = aes(x = sched_dep_time, y = ..density..)) +
  geom_freqpoly(mapping = aes(color = cancelled),
                binwidth = 1/4
  )
# 2
ggplot(data = diamonds, mapping = aes(x = color, y = price)) +
  geom_boxplot()
ggplot(data = diamonds, mapping = aes(x = carat, y = price, color = color)) +
  geom_point()
# diamond SIZE seems to have a big impact on diamond PRICE, more so than carat
diamonds2 %>%
  mutate(size = x * y * z) %>% # calc'd as if a cube
  ggplot(mapping = aes(x = size, y = price)) +
    geom_point()

# ideal cut diamonds tend to be smaller, so of course they are by average cheaper!
diamonds2 %>%
  mutate(size = x * y * z) %>%
  ggplot(mapping = aes(x = reorder(cut, size, FUN = median), y = size)) +
    geom_boxplot(na.rm = TRUE) +
    coord_flip()

#################### Two catgorical variables #####################
# need to count the number of observations for each combination
# built in geom_count() does this
ggplot(data = diamonds) +
  geom_count(mapping = aes(x = cut, y = color))

# another approach is to compute the count with dplyr then visualize with geom_tile() and fill
diamonds %>%
  count(color, cut) %>%
  ggplot(mapping = aes(x = color, y = cut)) +
    geom_tile(mapping = aes(fill = n))
# if categorical variables are unordered, you might want to ue the seriation package
# to simultaneously reorder rows and columns to reveal more clearly patterns
# For larger plots, d3heatmap or heatmaply packages create interactive plots

# Exercises
# 2
flights %>%
  count(dest, month) %>%
  ggplot(mapping = aes(x = month, y = reorder(dest, n, FUN = median))) +
    geom_tile(mapping = aes(fill = n))

################## Two coninuous variables #######################
# scatterplot with geom_point is great for this
ggplot(data = diamonds) +
  geom_point(mapping = aes(x = carat, y = price))
# scatterplots re less useful as size of dataset grows due to overplotting
# can fix this problem using alpha
ggplot(data = diamonds) +
  geom_point(mapping = aes(x = carat, y = price),
             alpha = 1 / 100)
# but using transparency can be challenging for very large datasets
# another solution is to use bin: geom_bin2d(), geom_hex() to bin in 2 dimentions
# geom_bin2d() uses rectangular bins, geom_hex() uses hexogonal bins
# need to install hexbin package for geom_hex()
ggplot(data = smaller) +
  geom_bin2d(mapping = aes(x = carat, y = price))

# install.packages("hexbin")
ggplot(data = smaller) +
  geom_hex(mapping = aes(x = carat, y = price))

# another option is to bin one continuous variable so it acts like a categorical variable, 
# then use technique to visualize combo of categorical and continuous variable
# ex: bin carat, then for each group, display a boxplot
ggplot(data = smaller, mapping = aes(x = carat, y = price)) +
  geom_boxplot(mapping = aes(group = cut_width(carat, 0.1)))

#cut_width(x, width) divides x into bins of width width
# here though its difficult to tell that each boxplot summarizes a different number of points
# can fix this by making the width of the boxplot proportional to the number of points
# using varwidth = TRUE
ggplot(data = smaller, mapping = aes(x = carat, y = price)) +
  geom_boxplot(mapping = aes(group = cut_width(carat, 0.1)), varwidth = TRUE)

# another approach is to display approx the sme number of points in each bin
# thats the job of cut_number()
ggplot(data = smaller, mapping = aes(x = carat, y = price)) +
  geom_boxplot(mapping = aes(group = cut_number(carat, 20))) # 2nd arg here is number of bins

# Exercises
# 2
ggplot(data = smaller, mapping = aes(x = price, y = carat)) +
  geom_boxplot(mapping = aes(group = cut_width(price, 1000)), varwidth = T)
# 3
diamonds2 %>%
  mutate(size = x*y*z) %>%
  ggplot(mapping = aes(x = size, y = price)) +
    geom_boxplot(mapping = aes(group = cut_width(size, 25)), 
                 na.rm = TRUE,
                 varwidth = TRUE)
diamonds2 %>%
  mutate(size = x*y*z) %>%
  ggplot(mapping = aes(x = size, y = price)) +
  geom_boxplot(mapping = aes(group = cut_number(size, 25)), 
               na.rm = TRUE,
               varwidth = TRUE)
# 4
ggplot(data = diamonds, mapping = aes(x = cut, y = price)) +
  geom_boxplot(mapping = aes(group = cut_number(carat, 20)))

################# Patterns and models #####################
ggplot(data = faithful) +
  geom_point(mapping = aes(x = eruptions, y = waiting))

library(modelr)

# the following code fits a model that predicts price from carat then computes the residuals,
# the difference between the predicted value and the actual
# residuals give us a view of the price of a diamond once the effect of carat has been removed
mod <- lm(log(price) ~ log(carat), data = diamonds)

diamonds2 <- diamonds %>%
  add_residuals(mod) %>%
  mutate(resid = exp(resid))
ggplot(data = diamonds2) +
  geom_point(mapping = aes(x = carat, y = resid))

# once you've removed the strong relationship between carat and price, yyou can see hwat you expect
# in the relationship between cut and price: better quality diamonds are more expensive
ggplot(data = diamonds2) +
  geom_boxplot(mapping = aes(x = cut, y = resid))

# Can write more concise code:
ggplot(data = faithful, mapping = aes(x = eruptions)) +
  geom_freqpoly(binwidth = 0.25)
# vs.
ggplot(faithful, aes(eruptions)) +
  geom_freqpoly(binwidth = 0.25)
