# Notes from R FOR DATA SCIENCE,
# an O'Reilly guide by Hadley Wickham and Garrett Grolemund
# Availible online at http://r4ds.had.co.nz/
# PART ONE: EXPLORE
# Chapter 1: Data Visualization with ggplot2

# install neccessary packages usnig the line below and then load libraries
# install.packages("tidyverse")
library(tidyverse)

mpg
str(mpg)

ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy))

############ AESTHETIC MAPPING ############
# mapping an aesthetic to a variable (color)
ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy, color = class))

# mapping to a size (althouhgh since class is an unordered variable its not the best idea)
ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy, size = class))

# using alpha to affect transparency
ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy, alpha = class))

# using shape gives different categories different dot shapes
# NOTE: defaults to only 6 different shapes, additional variables will be unplotted
ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy, shape = class))

# Can set aesthetics manually: color has to be outside aes() function
# color: name of color as char string
# size of point in mm
# shape of point as number (ex 0 15, 22 are all squares)
ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy), color = "blue")

#mapping a cominuous variable:
# note: these continuous variables aren't truely continuous
ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy, color = displ <cty))

# stroke aesthetic?
ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy, stroke = cyl))

# Non variable name aes
ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy, color = displ < 5))

########## FACETS ##########
# using facet_wrap(). must be discrete variable(s)
ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_wrap(~ class, nrow = 2)

# facet plot on combo of 2 variables
ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_grid(drv ~ cyl)

# facet_grid(drv ~ .) vs. facet_grid(. ~ drv):
# graphs are divided into rows vs. columns
ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_grid(drv ~ .)

############## GEOMETRIC OBJECTS #############
ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy))
# vs
ggplot(data = mpg) +
  geom_smooth(mapping = aes(x = displ, y = hwy))
# not every aes works in every geom
# add multiple geom functions to plot to disply multiple in same plot
ggplot(data = mpg) +
  geom_smooth(mapping = aes(x = displ, y = hwy, linetype = drv, color = drv)) +
  geom_point(mapping = aes(x = displ, y = hwy, color = drv))


ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy)) +
  geom_smooth(mapping = aes(x = displ, y = hwy))
# can do same plot as above using global mappings
# this can help avoid errors if both plots are to disply same data
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) +
  geom_point() +
  geom_smooth()

# can use global mappings but change one plot usng local mappings for that layer ONLY:
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) +
  geom_point(mapping = aes(color = class)) +
  geom_smooth()

#using local variables to midfy global mappings
ggplot(data = mpg, mapping = aes(x = displ, y = hwy, color = class)) +
  geom_point() +
  geom_smooth(data = filter(mpg, class == "subcompact"), se = FALSE)

ggplot(data = mpg, mapping = aes(x = displ, y = hwy, color = drv)) +
  geom_point() +
  geom_smooth(se = FALSE) # makes it so just the smoothed line appears, without indication of variance

# REcreating R plots (pg 21, q 6)
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) +
  geom_smooth(se = FALSE) +
  geom_point()

ggplot(data = mpg, mapping = aes(x = displ, y = hwy, group = drv)) +
  geom_smooth(se = FALSE) +
  geom_point()

ggplot(data = mpg, mapping = aes(x = displ, y = hwy, color = drv)) +
  geom_smooth(se = FALSE) +
  geom_point()

ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) +
  geom_smooth(se = FALSE) +
  geom_point(aes(color = drv))

ggplot(data = mpg, mapping = aes(x = displ, y = hwy, group = drv)) +
  geom_smooth(aes(linetype = drv), se = FALSE) +
  geom_point(aes(color = drv))

ggplot(data = mpg, mapping = aes(x = displ, y = hwy, color = drv)) +
  geom_point()

#################### STATISTICAL TRANSFORMATIONS ##################
diamonds
str(diamonds)

ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut))

# bar plots use an algorithm called stat to calc the count. Generally,
# stats and geoms can be used interchangeably. Ex the plot above can be reproduced as follows.
# This works bc every geom has a default stat and vice versa
ggplot(data = diamonds) +
  stat_count(mapping = aes(x = cut))

### Reasons you might need to use a stat explicitly: ##

# 1: to override the default stat
# Example would be changing the stat of geom_bar() from the default count to identity
# when the height of the bars is already present in the data. Here we're not interested in
# a frequency
demo <- tribble(
  ~a,      ~b,
  "bar_1", 20,
  "bar_2", 30,
  "bar_3", 40)

ggplot(data = demo) +
  geom_bar(mapping = aes(x = a, y = b), stat = "identity")
# If stat statment is not included, the following error occurs:
# Error: stat_count() must not be used with a y aesthetic.

# 2: to override the default mapping from transformed variables to aesthetics
# Ex: you might want to display a bar chart proportion (frequency) rather than count
ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut, y = ..prop.., group = 1))

# 3: to draw greater attention to the statistical transformation in your code
# Ex: to use stat_summary() to summarize y values for each unique x value
ggplot(data = diamonds) +
  stat_summary(
    mapping = aes(x = cut, y = depth),
    fun.ymin = min,
    fun.ymax = max,
    fun.y = median
  )

# THeres over 20 stats in ggplot2
# see: https://www.rstudio.com/wp-content/uploads/2015/03/ggplot2-cheatsheet.pdf
# also: https://www.rstudio.com/resources/cheatsheets/

# my attempt at q1 on page 26. doesn't really work
# ggplot(data = diamonds) +
#   geom_pointrange(mapping = aes(x = cut, y = depth,
#                   ymin = 40,
#                   ymax = 80)) 


####################### POSITION AJUSTMENTS ###################
# can color a bar chart using color or fill
ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut, color = cut))

ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut, fill = cut))

# stacked bar graph
ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut, fill = clarity))

# If you don't want a stacked bar chart, you can use one of three other options: 
# identity, dodge, or fill

# 1 - position = IDENTITY: will place each object exactly where it falls in the context of the graph
# not super useful for bars because it overlaps them
# bc of overlap, need to ajust alpha or set fill = NA

# using alpha
ggplot(data = diamonds, mapping = aes(x = cut, fill = clarity)) +
  geom_bar(alpha = 1/5, position = "identity")

# blank plot bc ??? not worrying about it
ggplot(data = diamonds, mapping = aes(x = cut, fill = clarity)) +
  geom_bar(fill = NA, position = "identity")

# 2 - position = "fill": works like stacking, but makes each set of stacked bars the same height
# easier to compare proportions across groups

ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut, fill = clarity), position = "fill")

# 3 - position = "dodge": places overlapping objects directly beside one another to compare
# individual values

ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut, fill = clarity), position = "dodge")

# another adjustment thats good for scatterplots (but not for boxplots) to avoid 
# overplotting (where points overlap, making it difficult to see where the mass of the data is)
# set position adjustment to "jitter"
# adds small amount of randomness to spread points out

ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) +
  geom_point(position = "jitter")

# shorthand for geom_point(position = "jitter") is geom_jitter()
# Same plot as above

ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) +
  geom_jitter()

# Exercises, pg 31.
ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) +
  geom_point()
# VS
ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) +
  geom_jitter() # better way to display!

# geom_count() performs a similar role as geom_jitter in that it unobscures overplotting
# However, while geom_jitter does this through randomized variation, geom_count
# adds size to the points
ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) +
  geom_count()

ggplot(data = mpg, mapping = aes(class, hwy)) +
  geom_boxplot()

################### COORDINATE SYSTEMS ###################
# the default coordinate system in ggplot2 is the cartesian coordinate system (x, y)
# Others:

# coord_flip() switches x and y axes. Useful for horizontal boxplots or for long labels
# ex:
ggplot(data = mpg, mapping = aes(x = class, y = hwy)) +
  geom_boxplot()
ggplot(data = mpg, mapping = aes(x = class, y = hwy)) +
  geom_boxplot() +
  coord_flip()

# coord_quickmap() sets the aspect ratio correctly for maps. Important if you're plotting spatial data
# coord_quickmap() is a quick approximation while coord_map is more exact but more computationally
# intensive
nz <- map_data("nz")
ggplot(nz, aes(long, lat, group = group)) +
  geom_polygon(fill = "white", color = "black") +
  coord_quickmap()

# coord_polar() uses polar coordinates
bar <-  ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut, fill = cut),
           show.legend = FALSE,
           width = 1) +
  theme(aspect.ratio = 1) +
  labs(x = NULL, y = NULL)

bar
bar + coord_flip()
bar + coord_polar()

# Exercises
# stacked bar chart
ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut, fill = clarity))
# pie chart
ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut, fill = clarity), position = "fill") +
  coord_polar()

?labs

ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) +
  geom_point() +
  geom_abline() + #float sqroot :) <3 `alice to barb`
  coord_fixed() # fixes the x-y ratio to 1 to 1 I think

# graph TEMPLATE
# ggplot(data = <DATA>) +
#     <GEOM_FUNCTION>(mapping = aes(<MAPPINGS>),
#                     stat = <STAT>,
#                     position = <POSITION>) +
#     <COORDINATE FUNCTION> +
#     <FACET_FUNCTION>
