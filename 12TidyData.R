#12 Tidy data
library(tidyverse)

table1
table2
table3
table4a
table4b

#There are three interrelated rules which make a dataset tidy:
#1. Each variable must have its own column.
#2. Each observation must have its own row.
#3. Each value must have its own cell.

#12.3 Spreading and gathering
#The first step is always to figure out what the variables and observations are. Sometimes this is easy. The second step is to resolve one of two common problems:
#One variable might be spread across multiple columns.
#One observation might be scattered across multiple rows.

#12.3.1 Gathering
#A common problem is a dataset where some of the column names are not names of variables, but values of a variable. Take table4a: the column names 1999 and 2000 represent values of the year variable, and each row represents two observations, not one.
table4a
#To tidy a dataset like this, we need to gather those columns into a new pair of variables. To describe that operation we need three parameters:
#The set of columns that represent values, not variables. In this example, those are the columns 1999 and 2000.
#The name of the variable whose values form the column names. I call that the key, and here it is year.
#The name of the variable whose values are spread over the cells. I call that value, and here it’s the number of cases.

tidy4a <- table4a %>%
  gather('1999', '2000', key = "year", value = "cases")
tidy4b <- table4b %>%
  gather('1999', '2000', key = "year", value = "population")
left_join(tidy4a, tidy4b)

#12.3.2 Spreading
#Spreading is the opposite of gathering. You use it when an observation is scattered across multiple rows. For example, take table2: an observation is a country in a year, but each observation is spread across two rows.
table2
#To tidy this up, we first analyse the representation in similar way to gather(). This time, however, we only need two parameters:
#The column that contains variable names, the key column. Here, it’s type.
#The column that contains values forms multiple variables, the value column. Here it’s count.
spread(table2, key = type, value = count)

#gather() makes wide tables narrower and longer; spread() makes long tables shorter and wider.

#12.4 Separating and uniting
table3
#12.4.1 Separate
#separate() pulls apart one column into multiple columns, by splitting wherever a separator character appears.
table3 %>%
  separate(rate, into = c("cases", "population"))
#By default, separate() will split values wherever it sees a non-alphanumeric character (i.e. a character that isn’t a number or letter).
#If you wish to use a specific character to separate a column, you can pass the character to the sep argument of separate().
table3 %>%
  separate(rate, into = c("cases","population"), sep = "/")
#Look carefully at the column types: you’ll notice that case and population are character columns. This is the default behaviour in separate(): it leaves the type of the column as is.
#We can ask separate() to try and convert to better types using convert = TRUE:
table3 %>%
  separate(rate, into = c("cases","population"), convert = T)

#You can also pass a vector of integers to sep.
table5 <- table3 %>%
  separate(year, into = c("century", "year"), sep = 2)
#Positive values start at 1 on the far-left of the strings; negative value start at -1 on the far-right of the strings.

#12.4.2 Unite
#unite() is the inverse of separate(): it combines multiple columns into a single column.
table5 %>%
  unite(new, century, year)
#In this case we also need to use the sep argument. The default will place an underscore (_) between the values from different columns.
table5 %>%
  unite(new, century, year, sep = "")

#12.5 Missing values
#a value can be missing in one of two possible ways:
#Explicitly, i.e. flagged with NA.
#Implicitly, i.e. simply not present in the data.

stocks <- tibble(
  year   = c(2015, 2015, 2015, 2015, 2016, 2016, 2016),
  qtr    = c(   1,    2,    3,    4,    2,    3,    4),
  return = c(1.88, 0.59, 0.35,   NA, 0.92, 0.17, 2.66)
)
#the first quarter of 2016 is missing implicitly.
stocks %>%
  spread(year, return)

#important tool for making missing values explicit in tidy data is complete():
stocks %>%
  complete(year, qtr)

#Sometimes when a data source has primarily been used for data entry, missing values indicate that the previous value should be carried forward:
treatment <- tribble(
  ~ person,           ~ treatment, ~response,
  "Derrick Whitmore", 1,           7,
  NA,                 2,           10,
  NA,                 3,           9,
  "Katherine Burke",  1,           4
)
#You can fill in these missing values with fill(). It takes a set of columns where you want missing values to be replaced by the most recent non-missing value (sometimes called last observation carried forward).
treatment %>%
  fill(person)
