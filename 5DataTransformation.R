#5. Data Transformation
library(tidyverse)
library(nycflights13)

flights
#To see the whole dataset, you can run View(flights) which will open the dataset in the RStudio viewer
View(flights)

#5.1.3 dplyr basics
#In this chapter you are going to learn the five key dplyr functions that allow you to solve the vast
#majority of your data manipulation challenges:
#Pick observations by their values (filter()).
#Reorder the rows (arrange()).
#Pick variables by their names (select()).
#Create new variables with functions of existing variables (mutate()).
#Collapse many values down to a single summary (summarise()).
#These can all be used in conjunction with group_by() which changes the scope of each function from
#operating on the entire dataset to operating on it group-by-group. 

#5.2 Filter rows with filter()
#filter() allows you to subset observations based on their values. The first argument is the name of
#the data frame. The second and subsequent arguments are the expressions that filter the data frame.
filter(flights,month==1, day==1)
# dplyr functions never modify their inputs, so if you want to save the result, you'll need to use the
#assignment operator, <-:
jan1 <- filter(flights,month==1,day==1)

#There's another common problem you might encounter when using ==: floating point numbers. These 
#results might surprise you!
sqrt(2)^2 == 2
1/49 * 49==1

#Computers use finite precision arithmetic so remember that every number you see is an approximation.
#Instead of relying on ==, use near():
near(sqrt(2)^2,2)
near(1/49 * 49,1)

filter(flights,month==11|month==12)
#or
filter(flights,month %in% c(11,12))
# %in% is like an intersect.

#Sometimes you can simplify complicated subsetting by remembering De Morgan's law: !(x & y) is the
#same as !x | !y, and !(x | y) is the same as !x & !y. 
#For example, if you wanted to find flights that weren't delayed (on arrival or departure) by more 
#than two hours, you could use either of the following two filters:
filter(flights,arr_delay<=120,dep_delay<=120)
#or
filter(flights,!(arr_delay>120 | dep_delay>120))
#filter() excludes NA values.

?between
#This is a shortcut for x >= left & x <= right; between(x,left,right)

filter(flights,is.na(dep_time))

#5.3 Arrange rows with arrange()
#arrange() works similarly to filter() except that instead of selecting rows, it changes their order.
#It takes a data frame and a set of column names (or more complicated expressions) to order by. If you
#provide more than one column name, each additional column will be used to break ties in the values of
#preceding columns:
arrange(flights,year,month,day)

#Use desc() to re-order by a column in descending order:
arrange(flights,desc(arr_delay))
#Missing values are always sorted at the end.

arrange(flights,desc(is.na(dep_time)))
#if you want to display NA values first.

#5.4 Select columns with select()
#It's not uncommon to get datasets with hundreds or even thousands of variables. In this case, the 
#first challenge is often narrowing in on the variables you're actually interested in. select() allows
#you to rapidly zoom in on a useful subset using operations based on the names of the variables.
select(flights,year, month,day)

# Select all columns between year and day (inclusive)
select(flights,year:day)

# Select all columns except those from year to day (inclusive)
select(flights, -(year:day))

#There are a number of helper functions you can use within select():
#starts_with("abc"): matches names that begin with "abc".
#ends_with("xyz"): matches names that end with "xyz".
#contains("ijk"): matches names that contain "ijk".
#matches("(.)\\1"): selects variables that match a regular expression. This one matches any variables
#that contain repeated characters.
#num_range("x", 1:3) matches x1, x2 and x3

#select() can be used to rename variables, but it's rarely useful because it drops all of the 
#variables not explicitly mentioned. Instead, use rename(), which is a variant of select() that keeps
#all the variables that aren't explicitly mentioned:
rename(flights,tail_num=tailnum)

#everything() is useful if you have a handful of variables you'd like to move to the start of the data
#frame.
select(flights, time_hour,air_time,everything())

select(flights, time_hour,air_time,time_hour)
#if we call a variable multiple times in select() then it doesn't repeat the variable.

?one_of #is used to select specific number of character vectors. See example to understand.

select(flights, contains("TIME"))
#select is case insensitive. 

#5.5 Add new variables with mutate()
#Besides selecting sets of existing columns, it's often useful to add new columns that are functions
#of existing columns. That's the job of mutate(). mutate() always adds new columns at the end of your
#dataset.
flights_sml <- select(flights,
                      year:day,
                      ends_with('delay'),
                      distance,
                      air_time)
mutate(flights_sml,
       gain=arr_delay-dep_delay,
       speed=distance/air_time*60)

mutate(flights_sml,
       gain = arr_delay - dep_delay,
       hours = air_time / 60,
       gain_per_hour = gain / hours)

#If you only want to keep the new variables, use transmute():
transmute(flights,
          gain=arr_delay-dep_delay,
          hours=air_time/60,
          gain_per_hour=gain/hours)


#If you only want to keep the new variables, use transmute():
transmute(flights,
            gain = arr_delay - dep_delay,
            hours = air_time / 60,
            gain_per_hour = gain / hours)

#5.5.1 Useful creation functions
#There are many functions for creating new variables that you can use with mutate(). The key property
#is that the function must be vectorised: it must take a vector of values as input, return a vector 
#with the same number of values as output.
#%/% (integer division) and %% (remainder)
transmute(flights,
          dep_time,
          hour=dep_time %/%100,
          minute=dep_time %%100)

#Offsets: lead() and lag() allow you to refer to leading or lagging values. This allows you to 
#compute running differences (e.g. x - lag(x)) or find when values change (x != lag(x)). They are most
#useful in conjunction with group_by()
(x <- 1:10)
lag(x)
lead(x)

#R provides functions for running sums, products, mins and maxes: cumsum(), cumprod(), cummin(), 
#cummax(); and dplyr provides cummean() for cumulative means
cumsum(x)
cummax(x)
cummin(x)
cummean(x)

#Rankings:  It does the most usual type of ranking (e.g. 1st, 2nd, 2nd, 4th). The default gives 
#smallest values the small ranks; use desc(x) to give the largest values the smallest ranks.
y <- c(1,2,2,NA,3,4)
min_rank(y)
min_rank(desc(y))

#If min_rank() doesn't do what you need, look at the variants row_number(), dense_rank(), 
#percent_rank(), cume_dist(), ntile().

#5.6 Grouped summaries with summarise()
#The last key verb is summarise(). It collapses a data frame to a single row:
summarise(flights,delay=mean(dep_delay,na.rm=T))

#summarise() is not terribly useful unless we pair it with group_by(). This changes the unit of 
#analysis from the complete dataset to individual groups. Then, when you use the dplyr verbs on a 
#grouped data frame they'll be automatically applied "by group". For example, if we applied exactly 
#the same code to a data frame grouped by date, we get the average delay per date:
by_day <- group_by(flights,year,month,day)
summarise(by_day,delay=mean(dep_delay,na.rm=T))

by_dest <- group_by(flights,dest)
delay <- summarise(by_dest,
                   count=n(),
                   dist=round(mean(distance, na.rm=T),2),
                   delay=mean(arr_delay,na.rm=T))
delay

delay <- filter(delay,count>20,dest!='HNL')
delay

ggplot(delay,mapping = aes(dist,delay))+
  geom_point(aes(size=count),alpha=1/3)+
  geom_smooth(se=F)
#another way of writing the above codes, using pipe %>%.
delays <- flights%>%
  group_by(dest) %>%
  summarise(count=n(),
            dist=mean(distance,na.rm=T),
            delay=mean(arr_delay,na.rm=T))%>%
  filter(count>20,dest!='HNL')
delays

not_cancelled <- flights %>%
  filter(!is.na(dep_delay),!is.na(arr_delay))
not_cancelled %>%
  group_by(year,month,day) %>%
  summarise(mean=mean(dep_delay))

#Whenever you do any aggregation, it's always a good idea to include either a count (n()), or a count
#of non-missing values (sum(!is.na(x))). That way you can check that you're not drawing conclusions 
#based on very small amounts of data.
delays <- not_cancelled %>%
  group_by(tailnum) %>%
  summarise(delay=mean(arr_delay))
ggplot(delays,mapping = aes(delay))+
  geom_freqpoly(binwidth=10)
#to get more insight lets draw a scatterplot
delays <- not_cancelled %>%
  group_by(tailnum) %>%
  summarise(delay=mean(arr_delay,na.rm=T),n=n())
ggplot(delays,aes(n,delay))+
  geom_point(alpha=1/10)
#whenever you plot a mean (or other summary) vs. group size, you'll see that the variation decreases
#as the sample size increases.
#When looking at this sort of plot, it's often useful to filter out the groups with the smallest 
#numbers of observations, so you can see more of the pattern and less of the extreme variation in the
#smallest groups.

delays %>%
  filter(n>25) %>%
  ggplot(mapping=aes(n,delay))+
  geom_point(alpha=1/10)

batting <- as_tibble(Lahman::Batting)
batters <- batting %>%
  group_by(playerID) %>%
  summarise(ba=sum(H,na.rm=T)/sum(AB,na.rm=T),
            ab=sum(AB,na.rm=T))
batters %>%
  filter(ab>100) %>%
  ggplot(mapping=aes(ab,ba))+
  geom_point()+
  geom_smooth(se=F)

#Just using means, counts, and sum can get you a long way, but R provides many other useful summary
#functions:
#Measures of location: we've used mean(x), but median(x) is also useful.

#subsetting: will learn about it later.
not_cancelled %>%
  group_by(year,month,day) %>%
  summarise(avg_delay1=mean(arr_delay),
            avg_delay2=mean(arr_delay[arr_delay>0]))

#Measures of spread: sd(x), IQR(x), mad(x). The mean squared deviation, or standard deviation or sd 
#for short, is the standard measure of spread. The interquartile range IQR() and median absolute 
#deviation mad(x) are robust equivalents that may be more useful if you have outliers.
not_cancelled %>%
  group_by(dest) %>%
  summarise(distance_sd=sd(distance)) %>%
  arrange(desc(distance_sd))

#Measures of rank: min(x), quantile(x, 0.25), max(x). Quantiles are a generalisation of the median.
not_cancelled %>%
  group_by(year,month,day) %>%
  summarise(first=min(dep_time),
            last=max(dep_time))

#Counts: You've seen n(), which takes no arguments, and returns the size of the current group. To 
#count the number of non-missing values, use sum(!is.na(x)). To count the number of distinct (unique)
#values, use n_distinct(x).
not_cancelled %>%
  group_by(dest) %>%
  summarise(carriers=n_distinct(carrier)) %>%
  arrange(desc(carriers))
#Counts are so useful that dplyr provides a simple helper if all you want is a count:
not_cancelled %>%
  count(dest)

#You can optionally provide a weight variable. For example, you could use this to "count" (sum) the
#total number of miles a plane flew:
not_cancelled %>%
  count(tailnum, wt= distance)

#Counts and proportions of logical values: sum(x > 10), mean(y == 0).
not_cancelled %>%
  group_by(year,month,day) %>%
  summarise(n_early =sum(dep_time<500))
## What proportion of flights are delayed by more than an hour?
not_cancelled %>%
  group_by(year,month,day) %>%
  summarise(hour_perc=mean(arr_delay>60))

daily <- group_by(flights, year, month, day)
(per_day <- summarise(daily,flights=n()))

#If you need to remove grouping, and return to operations on ungrouped data, use ungroup().
daily %>%
  ungroup() %>%
  summarise(flights=n())

#5.7 Grouped mutates (and filters)
#Grouping is most useful in conjunction with summarise(), but you can also do convenient operations
#with mutate() and filter():
#Find the worst members of each group:
flights_sml %>%
  group_by(year, month, day) %>%
  filter(rank(desc(arr_delay))<2)

#Find all groups bigger than a threshold:
popular_dests <- flights %>%
  group_by(dest) %>%
  filter(n()>365)
popular_dests

#Standardise to compute per group metrics:
popular_dests %>%
  filter(arr_delay>0) %>%
  mutate(prop_delay = arr_delay/sum(arr_delay)) %>%
  select(year:day,dest, arr_delay, prop_delay)
