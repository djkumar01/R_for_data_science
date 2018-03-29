#Many Model
library(modelr)
library(tidyverse)

#25.2 gapminder
library(gapminder)
gapminder

gapminder %>%
  ggplot(aes(year, lifeExp, group = country)) + 
  geom_line(alpha = 1/3)

nz <- filter(gapminder, country == "New Zealand")
nz %>%
  ggplot(aes(year, lifeExp)) + 
  geom_line() + 
  ggtitle('Full data')

nz_mod <- lm(lifeExp~year, data = nz)
nz %>%
  add_predictions(nz_mod) %>% #add predictions to the main data set
  ggplot(aes(year, pred)) + 
  geom_line() + 
  ggtitle("Linear trend + ")

nz %>%
  add_residuals(nz_mod) %>% #add residuals to the main data set.
  ggplot(aes(year, resid)) + 
  geom_hline(yintercept = 0, color = 'white', size = 3) + 
  geom_line() +
  ggtitle("remaining pattern")

#How can we easily fit the model to every country?
#25.2.1 Nested data
by_country <- gapminder %>%
  group_by(country, continent) %>%
  nest()
by_country
#This creates an data frame that has one row per group (per country), and a rather unusual column: data. data is a list of data frames (or tibbles, to be precise).
#if you pluck out a single element from the data column you'll see that it contains all the data for that country
by_country$data[[1]]
#Note the difference between a standard grouped data frame and a nested data frame: in a grouped data frame, each row is an observation; in a nested data frame, each row is a group. 

#25.2.2
#Now that we have our nested data frame, we're in a good position to fit some models. We have a model-fitting function:
country_model <- function(df) {
  lm(lifeExp ~ year, data = df)
}

#And we want to apply it to every data frame. The data frames are in a list, so we can use purrr::map() to apply country_model to each element:
models <- map(by_country$data, country_model)

#However, rather than leaving the list of models as a free-floating object, I think it's better to store it as a column in the by_country data frame. Storing related objects in columns is a key part of the value of data frames, and why I think list-columns are such a good idea. In the course of working with these countries, we are going to have lots of lists where we have one element per country. So why not store them all together in one data frame?
#In other words, instead of creating a new object in the global environment, we're going to create a new variable in the by_country data frame. That's a job for dplyr::mutate():
by_country <- by_country %>%
  mutate(model = map(data, country_model))
by_country

#This has a big advantage: because all the related objects are stored together, you don't need to manually keep them in sync when you filter or arrange. The semantics of the data frame takes care of that for you:
by_country %>%
  filter(continent == "Europe")

by_country %>%
  arrange(continent, country)

#25.2.3 Unnesting
#Now we have 142 data frames and 142 models. To compute the residuals, we need to call add_residuals() with each model-data pair:
by_country <- by_country %>%
  mutate(
    resids = map2(data, model, add_residuals)
  )
by_country

resids <- unnest(by_country, resids)
resids

#Now we have regular data frame, we can plot the residuals:
resids %>%
  ggplot(aes(year, resid)) +
  geom_line(aes(group = country), alpha = 1/3) +
  geom_smooth(se = F)

#Facetting by continent is particularly revealing:
resids %>%
  ggplot(aes(year, resid, group = country)) + 
  geom_line(alpha = 1/3) +
  facet_wrap(~continent)

#25.2.4 Model quality
#we'll use broom::glance() to extract some model quality metrics. If we apply it to a model, we get a data frame with a single row:
broom::glance(nz_mod)
#We can use mutate() and unnest() to create a data frame with a row for each country:
by_country %>%
  mutate(glance = map(model, broom::glance)) %>%
  unnest(glance)
#This isn't quite the output we want, because it still includes all the list columns. This is default behaviour when unnest() works on single row data frames. To suppress these columns we use .drop = TRUE:
glance <- by_country %>%
  mutate(glance = map(model, broom::glance)) %>%
  unnest(glance, .drop = T)
glance

#With this data frame in hand, we can start to look for models that don't fit well:
glance %>%
  arrange(r.squared)

#The worst models all appear to be in Africa. Let's double check that with a plot. Here we have a relatively small number of observations and a discrete variable, so geom_jitter() is effective:
glance %>%
  ggplot(aes(continent, r.squared)) +
  geom_jitter(width = 0.5)

#We could pull out the countries with particularly bad  R2  and plot the data:
bad_fit <- filter(glance, r.squared < 0.25)
gapminder %>%
  semi_join(bad_fit, by = "country") %>%
  ggplot(aes(year, lifeExp, colour = country)) + 
  geom_line()

#25.3 List-columns
#List-columns are implicit in the definition of the data frame: a data frame is a named list of equal length vectors. A list is a vector, so it's always been legitimate to use a list as a column of a data frame.
#However, base R doesn't make it easy to create list-columns, and data.frame() treats a list as a list of columns:.
data.frame(x = list(1:3, 3:5))
#You can prevent data.frame() from doing this with I(), but the result doesn't print particularly well:
data.frame(
  x = I(list(1:3, 3:5)),
  y = c("1, 2", "3, 4, 5")
)

#Tibble alleviates this problem by being lazier (tibble() doesn't modify its inputs) and by providing a better print method:
tibble(
  x = list(1:3, 3:5),
  y = c("1, 2", "3, 4, 5")
)

#25.4 Creating list-columns
#Typically, you won't create list-columns with tibble(). Instead, you'll create them from regular columns, using one of three methods:
#1. With tidyr::nest() to convert a grouped data frame into a nested data frame where you have list-column of data frames.
#2. With mutate() and vectorised functions that return a list.
#3. With summarise() and summary functions that return multiple results.
#Alternatively, you might create them from a named list, using tibble::enframe().

#Read further in the book. Currently i dont find it useful.