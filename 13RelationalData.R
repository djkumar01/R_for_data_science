#13 Relational Data

#13.1 Introduction
# Collectively, multiple tables of data are called relational data because it is the relations, not just the individual datasets, that are important.
#There are three families of verbs designed to work with relational data:
#Mutating joins, which add new variables to one data frame from matching observations in another.
#Filtering joins, which filter observations from one data frame based on whether or not they match an observation in the other table.
#Set operations, which treat observations as if they were set elements.

#dplyr is specialised to do data analysis

library(tidyverse)
library(nycflights13)

#nycflights13 contains 4 tibble that are related to the flights table.
airlines
airports
planes
weather

#13.3 Keys
#The variables used to connect each pair of tables are called keys. A key is a variable (or set of variables) that uniquely identifies an observation. In simple cases, a single variable is sufficient to identify an observation.
#There are two types of keys:
#A primary key uniquely identifies an observation in its own table.
#A foreign key uniquely identifies an observation in another table.

#Once you've identified the primary keys in your tables, it's good practice to verify that they do indeed uniquely identify each observation.
planes %>%
  count(tailnum) %>%
  filter(n > 1)
weather %>%
  count(year, month, day, hour, origin) %>% #all are primary key
  filter(n > 1)

#Sometimes a table doesn't have an explicit primary key: each row is an observation, but no combination of variables reliably identifies it.
#If a table lacks a primary key, it's sometimes useful to add one with mutate() and row_number(). That makes it easier to match observations if you've done some filtering and want to check back in with the original data. This is called a surrogate key.

#A primary key and the corresponding foreign key in another table form a relation. 

#13.4 Mutating joins
#A mutating join allows you to combine variables from two tables. It first matches observations by their keys, then copies across variables from one table to the other.

#making a narrower dataset:
flights2 <- flights %>%
  select(year:day, hour, origin, dest, tailnum, carrier)

#Imagine you want to add the full airline name to the flights2 data. You can combine the airlines and flights2 data frames with left_join():
flights %>%
  select(-origin, -dest) %>%
  left_join(airlines, by = "carrier")
#above code using mutate()
flights2 %>%
  select(-origin, -dest) %>%
  mutate(name = airlines$name[match(carrier, airlines$carrier)])

#13.4.1 Understanding joins
x <- tribble(
  ~key, ~val_x,
  1, "x1",
  2, "x2",
  3, "x3"
)
y <- tribble(
  ~key, ~val_y,
  1, "y1",
  2, "y2",
  4, "y3"
)

#13.4.2 Inner join
#An inner join matches pairs of observations whenever their keys are equal.
#We use by to tell dplyr which variable is the key:
x %>% 
  inner_join(y, by = "key")
#The most important property of an inner join is that unmatched rows are not included in the result. This means that generally inner joins are usually not appropriate for use in analysis because it's too easy to lose observations.

#13.4.3 Outer joins
#An outer join keeps observations that appear in at least one of the tables. There are three types of outer joins:
#A left join keeps all observations in x.
#A right join keeps all observations in y.
#A full join keeps all observations in x and y.
x %>%
  left_join(y, by = "key") #this should be your default join
x %>%
  right_join(y, by = "key")
x %>%
  full_join(y, by = "key")

#13.4.4 Duplicate keys
#So far all the diagrams have assumed that the keys are unique. But that's not always the case. This section explains what happens when the keys are not unique. There are two possibilities:
#1. One table has duplicate keys. This is useful when you want to add in additional information as there is typically a one-to-many relationship.
x <- tribble(
  ~key, ~val_x,
  1, "x1",
  2, "x2",
  2, "x3",
  1, "x4"
)
y <- tribble(
  ~key, ~val_y,
  1, "y1",
  2, "y2"
)
left_join(x, y, by = "key")
#2. Both tables have duplicate keys. This is usually an error because in neither table do the keys uniquely identify an observation. When you join duplicated keys, you get all possible combinations, the Cartesian product:
x <- tribble(
  ~key, ~val_x,
  1, "x1",
  2, "x2",
  2, "x3",
  3, "x4"
)
y <- tribble(
  ~key, ~val_y,
  1, "y1",
  2, "y2",
  2, "y3",
  3, "y4"
)
left_join(x, y, by = "key")

#13.4.5 Defining the key columns
#The default, by = NULL, uses all variables that appear in both tables, the so called natural join. For example, the flights and weather tables match on their common variables: year, month, day, hour and origin.
flights2 %>%
  left_join(weather)

#A named character vector: by = c("a" = "b"). This will match variable a in table x to variable b in table y. The variables from x will be used in the output.
flights2 %>%
  left_join(airports, c("dest" = "faa"))
flights2 %>%
  left_join(airports, c("origin" = "faa"))

#13.5 Filtering joins
#Filtering joins match observations in the same way as mutating joins, but affect the observations, not the variables. There are two types:
#semi_join(x, y) keeps all observations in x that have a match in y.
#anti_join(x, y) drops all observations in x that have a match in y.

top_dest <- flights %>%
  count(dest, sort = T) %>%
  head(10)
top_dest
# semi-join connects the two tables like a mutating join, but instead of adding new columns, only keeps the rows in x that have a match in y:
flights %>%
  semi_join(top_dest)

#The inverse of a semi-join is an anti-join. An anti-join keeps the rows that don't have a match:
#Anti-joins are useful for diagnosing join mismatches.
flights %>%
  anti_join(planes, by = "tailnum") %>%
  count(tailnum, sort = T)

#13.7 Set operations
#These expect the x and y inputs to have the same variables, and treat the observations like sets:
#intersect(x, y): return only observations in both x and y.
#union(x, y): return unique observations in x and y.
#setdiff(x, y): return observations in x, but not in y.

df1 <- tribble(
  ~x, ~y,
  1,  1,
  2,  1
)
df2 <- tribble(
  ~x, ~y,
  1,  1,
  1,  2
)

intersect(df1, df2)
union(df1, df2)
setdiff(df1, df2)
setdiff(df2, df1)
