library(tidyverse)

ggplot(diamonds, aes(carat, price)) +
  geom_bin2d()
ggsave("diamonds.pdf")

write_csv(diamonds, "diamonds.csv")

# If you rigorously save figures to files with R code and never with the mouse or clipboard
# you will be able to reproduce old work with ease!