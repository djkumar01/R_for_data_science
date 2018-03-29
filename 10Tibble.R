#10 Tibbles

library(tidyverse)
library(tibble)

#10.2 Creating tibbles
#Most other R packages use regular data frames, so you might want to coerce a data frame
#to a tibble. You can do that with as_tibble()
as_tibble(iris)

#You can create a new tibble from individual vectors with tibble()
tibble(
  x = 1:5,
  y = 1,
  z = x^2 + y
)

# Tibble never changes the type of the inputs (e.g. it never converts strings to factors
#!), it never changes the names of variables, and it never creates row names.
#It's possible for a tibble to have column names that are not valid R variable names,
#aka non-syntactic names like ':)', etc.
tb <- tibble(
  ':)' = 'smile',
  ' ' = 'space',
  '2000' = 'number'
)
tb

#Another way to create a tibble is with tribble(), short for transposed tibble. tribble() is customised for data entry in code: column headings are defined by formulas (i.e. they start with ~), and entries are separated by commas.
tribble(
  ~x, ~y, ~z,
  'a', 2, 3.6,
  'b', 1, 8.5
)

#10.3 Tibbles vs. data.frame
#There are two main differences in the usage of a tibble vs. a classic data.frame:
#Printing and Subsetting.
#Printing:
#Tibbles have a refined print method that shows only the first 10 rows, and all the 
#columns that fit on screen. This makes it much easier to work with large data. 
#In addition to its name, each column reports its type, like str().
tibble(
  a = lubridate::now() + runif(1e3) * 86400,
  b = lubridate::today() + runif(1e3) * 30,
  c = 1:1e3,
  d = runif(1e3),
  e = sample(letters, 1e3, replace = TRUE)
)

#Tibbles are designed so that you don't accidentally overwhelm your console when 
#you print large data frames.
#you can explicitly print() the data frame and control the number of rows (n) and
#the width of the display. width = Inf will display all columns.
nycflights13::flights %>%
  print(n= 10, width = Inf)

#You can also control the default print behaviour by setting options:
#options(tibble.print_max = n, tibble.print_min = m): if more than m rows, print only n rows. Use options(dplyr.print_min = Inf) to always show all rows.
#Use options(tibble.width = Inf) to always print all columns, regardless of the width of the screen.

#A final option is to use RStudio’s built-in data viewer to get a scrollable view of the complete dataset.
nycflights13::flights %>%
  View()

#Subsetting:
# If you want to pull out a single variable, you need some new tools, $ and [[. [[ can extract by name or position; $ only extracts by name but is a little less typing.
df <- tibble(
  x = runif(5),
  y = rnorm(5)
)
df$x
df[['x']]
df[[1]]

#To use these in a pipe, you’ll need to use the special placeholder .:
df %>% .$x
df %>% .[['x']]

?enframe #converts named atomic vectors or lists to two-column data frames. For unnamed vectors, the natural sequence is used as name column.
