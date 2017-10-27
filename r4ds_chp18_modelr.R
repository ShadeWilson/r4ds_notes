# Notes from R FOR DATA SCIENCE,
# an O'Reilly guide by Hadley Wickham and Garrett Grolemund
# Availible online at http://r4ds.had.co.nz/
# PART FOUR: Model
# Chapter 18: Model Basics with modelr

library(tidyverse)
library(modelr)
options(na.action = na.warn)

############ A Simple Model ############ 
sim1
ggplot(sim1, aes(x, y)) +
  geom_point()
# looks linear
models <- tibble(a1 = runif(250, -20, 40),
                 a2 = runif(250, -5, 5))
ggplot(sim1, aes(x, y)) +
  geom_abline(aes(intercept = a1, slope = a2),
              data = models, alpha = 1/4) +
  geom_point()

model1 <- function(a, data) {
  a[1] + data$x * a[2]
}
model1(c(7, 1.5), sim1)

measure_distance <- function(mod, data) {
  diff <- data$y - model1(mod, data)
  sqrt(mean(diff ^ 2))
}
measure_distance(c(7, 1.5), sim1)

sim1_dist <- function(a1, a2) {
  measure_distance(c(a1, a2), sim1)
}
models <- models %>%
  mutate(dist = purrr::map2_dbl(a1, a2, sim1_dist))
models

# overlay 10 best models
ggplot(sim1, aes(x, y)) +
  geom_point(size = 2, color = "grey30") +
  geom_abline(aes(intercept = a1, slope = a2, color = -dist),
              data = filter(models, rank(dist) <= 10))

# can think of these models as obs and visualize
ggplot(models, aes(a1, a2)) +
  geom_point(data = filter(models, rank(dist) <= 10),
             size = 4, color = "red") +
  geom_point(aes(color = -dist))

# instead of being random, could be more systematic with an evenly spaced grid of points
grid <- expand.grid(a1 = seq(-5, 20, length = 25),
                    a2 = seq(1, 3, length = 25)) %>%
  mutate(dist = purrr::map2_dbl(a1, a2, sim1_dist))
grid %>%
  ggplot(aes(a1, a2)) + 
  geom_point(data = filter(grid, rank(dist) <= 10),
             size = 4, color = "red") +
  geom_point(aes(color = -dist))

ggplot(sim1, aes(x, y)) +
  geom_point(size = 2, color = "grey30") +
  geom_abline(aes(intercept = a1, slope = a2, color = -dist),
              data = filter(grid, rank(dist) <= 10))

# could iterate the grid smaller and smaller but theres a better way: 
# Newton-Raphson search. Pick starting point, look around for steepest slope
# then ski down that slope a little way then repeat again and again until you cant go any
# lower. do with optim()
best <- optim(c(0,0), measure_distance, data = sim1)
best$par

ggplot(sim1, aes(x, y)) +
  geom_point(size = 2, color = "grey30") +
  geom_abline(intercept = best$par[1], slope = best$par[2])

# lm() for linear models
sim1_mod <- lm(y ~ x, data = sim1)
coef(sim1_mod)

# Exercises
sim1a <- tibble(x = rep(1:10, each = 3),
                y = x * 1.5 + 6 + rt(length(x), df = 2))
sim1a_mod <- lm(y ~ x, data = sim1a)

ggplot(sim1a, aes(x, y)) +
  geom_point() +
  geom_abline(intercept = coef(sim1a_mod)[1], slope = coef(sim1a_mod)[2])

# 2
measure_distance <- function(mod, data) {
  diff <- data$y - make_prediction(mod, data)
  mean(abs(diff))
}

############### Visualizing Models ############### 
# modelr::data_grid() to make evenly spaced grid
grid <- sim1 %>%
  data_grid(x)
grid

# add predictions with add_predictions()
grid <-  grid %>%
  add_predictions(sim1_mod)
grid

ggplot(sim1, aes(x, y)) +
  geom_point(aes(y = y)) +
  geom_line(aes(y = pred),
            data = grid,
            color = "red",
            size = 1)

# add residuals with add_residuals()
sim1 <- sim1 %>%
  add_residuals(sim1_mod)
sim1

ggplot(sim1, aes(resid)) +
  geom_freqpoly(binwidth = 0.5)
# avg of resis will always be 0

# resid plot looks like random noise, which is good!
ggplot(sim1, aes(x, resid)) +
  geom_ref_line(h = 0) +
  geom_point()

# Exercises
# 1
sim1_loess <- loess(y ~ x, data = sim1)
grid_loess <- sim1 %>%
  data_grid(x) %>%
  add_predictions(sim1_loess)
grid_loess

# same as with lm()
ggplot(sim1, aes(x)) +
  geom_point(aes(y = y)) +
  geom_line(aes(y = pred),
            data = grid, 
            color = "blue",
            size = 1)

ggplot(sim1) +
  geom_point(aes(x, y)) +
  geom_smooth(aes(x, y), 
              color = "red",
              se = FALSE)

################ Formulas and Model Families ################ 
df <- tribble(
  ~y, ~x1, ~x2,
  4, 2, 5, 
  5, 1, 6)
model_matrix(df, y ~ x1)
# can explicitly remove intercept column with -1
model_matrix(df, y ~ x1 - 1)

model_matrix(df, y ~ x1 + x2)

# CATEGORICAL VARIABLES
df <- tribble(
  ~sex, ~response,
  "male", 1,
  "female", 2,
  "male", 1
)
model_matrix(df, response ~ sex)

ggplot(sim2) +
  geom_point(aes(x, y))
mod2 <- lm(y ~ x, data = sim2)
grid <- sim2 %>%
  data_grid(x) %>%
  add_predictions(mod2)
grid

ggplot(sim2, aes(x)) +
  geom_point(aes(y = y)) +
  geom_point(data = grid,
             aes(y = pred),
             color = "red",
             size = 4)

# INTERACTIONS (CONTINUOUS AND CATEGORICAL)
ggplot(sim3, aes(x1, y)) +
  geom_point(aes(color = x2))

mod1 <- lm(y ~ x1 + x2, data = sim3)
mod2 <- lm(y ~ x1 * x2, data = sim3)

# using +: model estimates each effect independent of all the others
# using * can fit the interactions

grid <- sim3 %>%
  data_grid(x1, x2) %>%
  gather_predictions(mod1, mod2)
grid

ggplot(sim3, aes(x1, y, color = x2)) +
  geom_point() +
  geom_line(data = grid, aes(y = pred)) +
  facet_wrap( ~ model)

sim3 <- sim3 %>%
  gather_residuals(mod1, mod2)

ggplot(sim3, aes(x1, resid, color = x2)) +
  geom_point() +
  geom_ref_line(h = 0, size = 1) +
  facet_grid(model ~ x2)

# INTERACTIONS (TWO CONTINUOUS)
mod1 <- lm(y ~ x1 + x2, data = sim4)
mod2 <- lm(y ~ x1 * x2, data = sim4)

grid <- sim4 %>%
  data_grid(x1 = seq_range(x1, 5),
            x2 = seq_range(x2, 5)) %>%
  gather_predictions(mod1, mod2)
grid

ggplot(grid, aes(x1, x2)) +
  geom_tile(aes(fill = pred)) +
  facet_wrap(~ model)
# instead of viewing from the top, we can look from the side
ggplot(grid, aes(x1, pred, color = x2, group = x2)) +
  geom_line() +
  facet_wrap( ~ model)
ggplot(grid, aes(x2, pred, color = x1, group = x1)) +
  geom_line() +
  facet_wrap( ~ model)

# TRANSFORMATIONS
# if doing transofrms where +/*/^/ or - are used, wrap in I()
df <- tribble(
  ~y, ~x,
  1, 1,
  2, 2,
  3, 3
)
model_matrix(df, y ~ x^2 + x)
model_matrix(df, y ~ I(x^2) + x)

# taylors theorum fro approximating non linear smooth functions
model_matrix(df, y ~ poly(x, 2))
# splines::ns() is a safer version of poly()
library(splines)
model_matrix(df, y ~ ns(x, 2))

sim5 <- tibble(
  x = seq(0, 3.5 * pi, length = 50),
  y = 4 * sin(x) + rnorm(length(x))
)
ggplot(sim5, aes(x, y)) +
  geom_point()

# fit 5 models to the data
mod1 <- lm(y ~ ns(x, 1), data = sim5)
mod2 <- lm(y ~ ns(x, 2), data = sim5)
mod3 <- lm(y ~ ns(x, 3), data = sim5)
mod4 <- lm(y ~ ns(x, 4), data = sim5)
mod5 <- lm(y ~ ns(x, 5), data = sim5)

grid <- sim5 %>%
  data_grid(x = seq_range(x, n = 50, expand = 0.1)) %>%
  gather_predictions(mod1, mod2, mod3, mod4, mod5, .pred = "y")

ggplot(sim5, aes(x, y)) +
  geom_point() +
  geom_line(data = grid, color = "red") +
  facet_wrap(~ model)

# Exercises
# 2
mod1 <- lm(y ~ x1 + x2, data = sim4)
mod2 <- lm(y ~ x1 * x2, data = sim4)
model_matrix(sim4, y ~ x1 + x2)
model_matrix(sim4, y ~ x1 * x2)

# 3
mod1 <- lm(y ~ x1 + x2, data = sim3)
mod2 <- lm(y ~ x1 * x2, data = sim3)
sim3
mod1