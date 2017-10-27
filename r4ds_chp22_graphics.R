# Notes from R FOR DATA SCIENCE,
# an O'Reilly guide by Hadley Wickham and Garrett Grolemund
# Availible online at http://r4ds.had.co.nz/
# PART FIVE: Communicate
# CHapter 22: Graphics for Communication with ggplot2

library(tidyverse)
library(modelr)

############### Label ############### 
# add labels with labs()
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = class)) +
  geom_smooth(se = FALSE) +
  labs(title = paste("Fuel efficiency generally decreases with 
                     engine size")
  )

# Avoid titles that just descibe what the plot is, rather that summarize main findings

# if you need to add more text, theres other useful labels:
# subtitle adds additional detail in a smaller font beneath the title
# caption adds text at the bottom right of the plot, often used to descibe source of data
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = class)) +
  geom_smooth(se = FALSE) +
  labs(title = paste("Fuel efficiency generally decreases with",
                     "engine size"),
       subtitle = paste("Two seaters (sports cars) are an exception",
                        "because of their light weight"),
       caption = "Data from the fueleconomy.gov"
       )

# Can use labs() to replace axis and legend titles. Usually a good idea to replace
# short var names wiht more deatiled descriptions and use units
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = class)) +
  geom_smooth(se = FALSE) +
  labs(x = "Engine displacement (L)",
       y = "Highway fuel economy (mpg)",
       color = "Car type")

# possible to use mathematical equations instead of text strings
# just switch out "" for quote() and read about the availible options in
?plotmath
df <- tibble(x = runif(10),
             y = runif(10))
ggplot(df, aes(x, y)) +
  geom_point() +
  labs(x = quote(sum(x[i] ^ 2, i == 1, n)),
       y = quote(alpha + beta + frac(delta, theta)))

# Exercises
# 1
str(mpg)
ggplot(mpg, aes(displ, hwy, color = drv)) +
  geom_point() +
  labs(title = "Four-wheel drivesvhave the worst fuel efficiency",
       subtitle = "Front-wheel drives are much more efficient",
       x = "Engine Size (L)",
       y = "Highway Fuel Economy (mpg)",
       color = "Drive",
       caption = "Bored yet?")

# 2
mod1 <- lm(hwy ~ displ * class, data = mpg)

mpg %>% 
  add_predictions(mod1) %>% 
  ggplot(aes(x = displ)) +
    geom_point(aes(y = hwy, color = class)) +
    geom_line(aes(y = pred, group = class, color = class)) +
    facet_wrap(~class) +
    labs(title = "Modeling MPG Based on Engine Size and Car Class",
         x = "Engine Size (L)",
         y = "Highway Fuel Economy (mpg)",
         color = "Car Class")

mod2 <- lm(hwy ~ displ, data = mpg)

mpg %>% 
  add_predictions(mod2) %>% 
  ggplot(aes(x = displ)) +
  geom_point(aes(y = hwy, color = class)) +
  geom_line(aes(y = pred))

# 3
ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut, fill = color), position = "fill") +
  labs(title = "Diamond Color is Not Associated with Quality of Cut",
       x = "Quality of Cut",
       y = "Proportion",
       color = "af") # overwritten with this type of graph I guess

############ Annotations ############ 
# often useful to label individual obs or groups of obs
# geom_text() is similar to geom_point() but has an additional aesthetic: label
# two possible sources of labels:
# 1) might have tibble that provides labels:
best_in_class <- mpg %>% group_by(class) %>% 
  filter(rank(desc(hwy), ties.method = "first") == 1) %>% 

# print(n = nrow(.)) when piping to print all crows of a tibble

ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = class)) +
  geom_text(aes(label = model), data = best_in_class)

# can make things easier to read with geom_label()
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = class)) +
  geom_label(aes(label = model),
             data = best_in_class,
             nudge_y = 2, 
             alpha = 0.5)

# to avoid labels overlapping can use ggrepel package
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = class)) +
  geom_point(size = 3, shape = 1, data = best_in_class) +
  ggrepel::geom_label_repel(aes(label = model),
                            data = best_in_class)

# can sometimes highligth individual data points to replace the legend with labels directly on
# plot: theme(legend.position = "none") turns legend off

class_avg <- mpg %>% 
  group_by(class) %>% 
  summarize(displ = median(displ),
            hwy = median(hwy))
ggplot(mpg, aes(displ, hwy, color = class)) +
  ggrepel::geom_label_repel(aes(label = class),
                            data = class_avg,
                            size = 6,
                            label.size = 0,
                            segment.color = NA) +
  geom_point() +
  theme(legend.position = "none")

# might just want to add a single label to the plot, but still need to create a df
# want label in corner of plot, can create df with summarize to compute max x and y
label <- mpg %>% 
  summarize(displ = max(displ),
            hwy = max(hwy),
            label = paste("Increasing engine size is \nrelated to",
                          "decreasing fuel economy"))
ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  geom_text(aes(label = label),
            data = label,
            vjust = "top",
            hjust = "right")

# if you want text exactl on the borders of plot, can use -Inf and Inf
label <- tibble(displ = Inf, hwy = Inf,
                label = paste("blah blah"))
ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  geom_text(aes(label = label),
            data = label,
            vjust = "top",
            hjust = "right")


# can also use str_wrap() to cut off at a certain num of charaters instead of using \n
"blah blah blah blah blah bah" %>% stringr::str_wrap(width = 20) %>% 
  writeLines()

# OTHER USEFUL ggplot2 ANNOTATION FUNCTIONS
# geom_hline() and geom_vline() add reference lines. Can make them think( size = 2) and white
#   color = white
# geom_rect() draws a rectangle around points of interest
# geom_segment() with arrow arg to draw attention to a point with an arrow

# Exercises
ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  geom_text(aes(label = label),
            data = label,
            vjust = "top",
            hjust = "right") +
  geom_text(aes(-displ, -hwy, label = label),
            data = label,
            vjust = "bottom",
            hjust = "left") +
  geom_text(aes(-displ, hwy, label = label),
            data = label,
            vjust = "top",
            hjust = "left") +
  geom_text(aes(displ, -hwy, label = label),
            data = label,
            vjust = "bottom",
            hjust = "right")

################### Scales ################### 
# normally scales are automatic
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = class))

# ggplot2 automatically adds default scales behind the scenes
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = class)) +
  scale_x_continuous() +
  scale_y_continuous() +
  scale_color_discrete()

# Override to: tweak some parameters of default scale change axis breaks, or key labels)
# to replace scale totally and use different algorithm

# AXIS TICKS AND LEGEND KEYS
# two primary args: breaks, labels
# breaks controls position of ticks or values associated with the keys
# labels controls text label associatied with each tick/key

# most common use of breaks is to override default choice:
ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  scale_y_continuous(breaks = seq(15, 40, by = 5))

# can apply labels in the same way (char vector the same lengths as breaks), can also set to NULL
# to supress labels altogether
ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  scale_x_continuous(labels = NULL) +
  scale_y_continuous(labels = NULL)

# can also use breaks and labels to control the appearance of legends

# another use of breaks is when you have relatively few data points and want to highlight exactly
# where the obs occur
presidential %>% 
  mutate(id = 33 + row_number()) %>% 
  ggplot(aes(start, id)) +
    geom_point() +
    geom_segment(aes(xend = end, yend = id)) +
    scale_x_date(NULL, breaks = presidential$start, date_labels = "'%y")

# date_labels take format specifcation in the same form as parse_datetime()
# date_breaks takes a string like "2 days" or "1 month"

# LEGEND LAYOUT
# to control overall position of legend, need to use theme() setting (control nondata parts of plot)
# legend.position controls where legend is drawn:
base <- ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = class))

base + theme(legend.position = "left")
base + theme(legend.position = "top")
base + theme(legend.position = "bottom")
base + theme(legend.position = "right")
base + theme(legend.position = "none")

# to control display of indiv legends, use guides() along with guide_legend() or guide_colorbar()
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = class)) +
  geom_smooth(se = FALSE) +
  theme(legend.position = "bottom") +
  guides(color = guide_legend(nrow = 1,
                               override.aes = list(size = 4)))

# REPLACING A SCALE
ggplot(diamonds, aes(carat, price)) +
  geom_bin2d()
ggplot(diamonds, aes(log10(carat), log10(price))) +
  geom_bin2d()

# instead of doing transformation in the aesthetic mapping, can do it in scale
ggplot(diamonds, aes(carat, price)) +
  geom_bin2d() +
  scale_x_log10(breaks = c(0, 0.25, 0.5, 1L, 1.5, 2L, 3L, 4L)) +
  scale_y_log10()

#can customize color scales
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = drv))

ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = drv)) +
  scale_color_brewer(palette = "Set1")

# can add redundant shape mapping to ensure interpretable black and white
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = drv, shape = drv)) +
  scale_color_brewer(palette = "Set1")

# ColorBrewers scales are online, RColorBrewer

# when you have a predefineed mapping b/w values and colors, use scale_color_manual()
presidential %>% 
  mutate(id = 33 + row_number()) %>% 
  ggplot(aes(start, id, color = party)) +
    geom_point() +
  geom_segment(aes(xend = end, yend = id)) +
  scale_color_manual(values = c(Republican = "red", Democratic = "blue"))

# for continuous color, can use scale_color_gradient() or scale_fill_gradient()
# for diverging scale, use scale_color_gradient2()
# scale_color_viridis() (from viridis package) is continuous analog of ColorBrewer
df <- tibble(x = rnorm(10000),
             y = rnorm(10000))
ggplot(df, aes(x, y)) +
  geom_hex() +
  coord_fixed()

ggplot(df, aes(x, y)) +
  geom_hex() +
  viridis::scale_fill_viridis() +
  coord_fixed()

# Exercises
# 1
ggplot(df, aes(x, y)) +
  geom_hex() +
  scale_fill_gradient(low = "white", high = "red") + # scale_color_ is for points/lines,
  coord_fixed()                                      # scale_fill_ is for shapes/bars

# 3
presidential2 <- presidential %>% 
  mutate(id = 33 + row_number(),
         name = stringr::str_c(name, " (", as.character(id), ")")) 

presidential2 %>% 
  ggplot(aes(start, id, color = party)) +
  geom_point() +
  geom_segment(aes(xend = end, yend = id)) +
  scale_color_manual(values = c(Republican = "red", Democratic = "blue")) +
  scale_y_continuous(breaks = seq(34, 44, by = 1), 
                     labels = presidential2$name) +
  scale_x_date(NULL, breaks = presidential2$start, date_labels = "'%y") +
  labs(y = "Presidential Number")

presidential2 %>% 
  ggplot(aes(start, id, color = party)) +
  geom_point() +
  geom_segment(aes(xend = end, yend = id)) +
  scale_color_manual(values = c(Republican = "red", Democratic = "blue")) +
  scale_y_continuous(breaks = seq(34, 44, by = 1), 
                     labels = presidential2$name) +
  scale_x_date(NULL, breaks = seq(1952, 2018, by = 4), date_labels = "'%y") +
  labs(y = "Presidential Number")

################### Zooming ################### 
# best to use coor_cartesian() to zoom in on a region
ggplot(mpg, mapping = aes(displ, hwy)) +
  geom_point(aes(color = class)) +
  geom_smooth(se = FALSE) +
  coord_cartesian(xlim = c(5, 7),
                  ylim = c(10, 30))
# vs
mpg %>% 
  filter(displ >= 5, displ <= 7, hwy >= 10, hwy <= 30) %>% 
  ggplot(aes(displ, hwy)) +
  geom_point(aes(color = class)) +
  geom_smooth(se = FALSE) # smooth line here is wrong

suv <- mpg %>% filter(class == "suv")
compact <- mpg %>% filter(class == "compact")

# sometimes better to extend range to compare two subsetted graphs
ggplot(suv, aes(displ, hwy, color = drv)) +
  geom_point()
ggplot(compact, aes(displ, hwy, color = drv)) +
  geom_point()

# share scles across multiple plots
x_scale <- scale_x_continuous(limits = range(mpg$displ))
y_scale <- scale_y_continuous(limits = range(mpg$hwy))
col_scale <- scale_color_discrete(limits = unique(mpg$drv))

ggplot(suv, aes(displ, hwy, color = drv)) +
  geom_point() +
  x_scale +
  y_scale +
  col_scale
ggplot(compact, aes(displ, hwy, color = drv)) +
  geom_point() +
  x_scale +
  y_scale +
  col_scale

# alt, but not always best if you want to spread plots over multiple pages of a report
mpg %>% filter(class %in% c("suv", "compact")) %>% 
  ggplot(aes(displ, hwy, color = drv)) +
  geom_point() +
  x_scale +
  y_scale +
  col_scale +
  facet_wrap(~class)

# THEMES
basic <- ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = class)) +
  geom_smooth(se = FALSE)

basic
basic + theme_bw()
basic + theme_light()
basic + theme_classic()
basic + theme_linedraw()
basic + theme_dark()
basic + theme_minimal()
basic + theme_gray()
basic + theme_void()

# additional themes in ggthemes

# SAVING PLOTS
# can use ggsave() and knitr

# ggsave() saves most recent plot to disk. If you dont specify the height and width, it'll
# take the dimensions of the current plotting device, but this isnt reproducible
ggplot(mpg, aes(displ, hwy, color = class)) + geom_point()
ggsave("my-plot.pdf")

# FIGURE SIZING
# five options to control figure sizing: fig.width, fig.height, fig.asp, out.width, and out.height

# most aesthetically pleasing for plots to have a consistent width
# fig.width = 6 and fig.asp = 0.618 (golden ratio)

# out.width = "70%", fig.align = "center"

# to plot multiple plots in a single row, set out.width = "50%" for 2 plots, 33% for 3, 25% for 4
# set fig.align = "center

# if fig.width is larger than the size of the figure rendered, the text will be too small.
# IF fig.width is smaller, the test will be too big
