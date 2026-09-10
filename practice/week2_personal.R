library(tidyverse)


x <- 3 * 4

primes <- c(2, 3, 5, 7, 11, 13)


this_is_really_a_long_name <- 2.5



ggplot(dTA = mpg) +
  geom_point(maping = aes(x = displ, y = hwy)) +
  geom_smooth(method = "lm")


my_bar_plot <- ggplot(mpg, aes(x = class)) +
  geom_bar()
my_scatter_plot <- ggplot(mpg, aes(x = cty, y = hwy)) +
  geom_point()
ggsave(filename = "mpg-plot.png", plot = my_bar_plot)
