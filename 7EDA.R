#7 Exploratory Data Analysis
library(tidyverse)

#7.1 Introduction
#EDA is an iterative cycle. You:
#Generate questions about your data.
#Search for answers by visualising, transforming, and modelling your data.
#Use what you learn to refine your questions and/or generate new questions.

#7.2 Questions
#Your goal during EDA is to develop an understanding of your data. The easiest way to do this is to use questions as tools to guide your investigation. When you ask a question, the question focuses your attention on a specific part of your dataset and helps you decide which graphs, models, or transformations to make.

#There is no rule about which questions you should ask to guide your research. However, two types of questions will always be useful for making discoveries within your data.
#What type of variation occurs within my variables?
#What type of covariation occurs between my variables?

#let's define some terms:
#A Variable is a quantity, quality, or property that you can measure.
#A Value is the state of a variable when you measure it. The value of a variable may change from measurement to measurement.
#An Observation is a set of measurements made under similar conditions (you usually make all of the measurements in an observation at the same time and on the same object). An observation will contain several values, each associated with a different variable. I'll sometimes refer to an observation as a data point.
#Tabular data is a set of values, each associated with a variable and an observation.

#7.3 Variation
#Variation is the tendency of the values of a variable to change from measurement to measurement. Each of your measurements will include a small amount of error that varies from measurement to measurement. Every variable has its own pattern of variation, which can reveal interesting information. The best way to understand that pattern is to visualise the distribution of the variable's values.

#How you visualise the distribution of a variable will depend on whether the variable is categorical or continuous. A variable is categorical if it can only take one of a small set of values. To examine the distribution of a categorical variable, use a bar chart:
ggplot(data = diamonds) +
  geom_bar(mapping = aes(x=cut))
#the above code manually.
diamonds %>% 
  count(cut)

#A variable is continuous if it can take any of an infinite set of ordered values. To examine the distribution of a continuous variable, use a histogram:
ggplot(diamonds)+
  geom_histogram(mapping = aes(carat), binwidth = 0.5)
#the above code manually.
diamonds %>%
  count(cut_width(carat,0.5))

# You should always explore a variety of binwidths when working with histograms, as different binwidths can reveal different patterns.
smaller <- diamonds %>%
  filter(carat<3)
ggplot(smaller, mapping = aes(carat))+
  geom_histogram(binwidth = 0.1)

#If you wish to overlay multiple histograms in the same plot, I recommend using geom_freqpoly() instead of geom_histogram(). geom_freqpoly() performs the same calculation as geom_histogram(), but instead of displaying the counts with bars, uses lines instead.
ggplot(data = smaller,mapping = aes(x=carat, colour = cut))+
  geom_freqpoly(binwidth=0.1)

#To turn information into useful questions, look for anything unexpected:
#Which values are the most common? Why?
#Which values are rare? Why? Does that match your expectations?
#Can you see any unusual patterns? What might explain them?

#Outliers are observations that are unusual; data points that don't seem to fit the pattern. Sometimes outliers are data entry errors; other times outliers suggest important new science. When you have a lot of data, outliers are sometimes difficult to see in a histogram.
ggplot(diamonds) + 
  geom_histogram(mapping = aes(x=y),binwidth = 0.5)
#To make it easy to see the unusual values, we need to zoom to small values of the y-axis with coord_cartesian():
ggplot(diamonds) + 
  geom_histogram(mapping = aes(x=y),binwidth = 0.5)+
  coord_cartesian(ylim= c(0,50))
#ylim when you just want to zoom into the y-axis.

unusual <- diamonds %>%
  filter(y < 3 | y > 20) %>%
  select(price,x, y, z) %>%
  arrange(y)
unusual

#It's good practice to repeat your analysis with and without the outliers. If they have minimal effect on the results, and you can't figure out why they're there, it's reasonable to replace them with missing values, and move on. However, if they have a substantial effect on your results, you shouldn't drop them without justification. You'll need to figure out what caused them (e.g. a data entry error) and disclose that you removed them in your write-up.

#7.4 Missing values
#If you've encountered unusual values in your dataset, and simply want to move on to the rest of your analysis, you have two options.
#Drop the entire row with the strange values (not recommend) 
#Instead, I recommend replacing the unusual values with missing values.
diamonds2 <- diamonds %>%
  mutate(y=ifelse(y < 3 | y > 20, NA, y))

ggplot(diamonds2,mapping = aes(x, y))+
  geom_point(na.rm = T)

nycflights13::flights %>%
  mutate(cancelled = is.na(dep_time),
         sched_hour = sched_dep_time %/% 100,
         sched_min = sched_dep_time %/% 100,
         sched_dep_time = sched_hour + sched_min/60) %>%
  ggplot(mapping = aes(sched_dep_time))+
  geom_freqpoly(mapping = aes(colour = cancelled), binwidth = 1/4)

#7.5 Covariation
#If variation describes the behavior within a variable, covariation describes the behavior between variables. Covariation is the tendency for the values of two or more variables to vary together in a related way. The best way to spot covariation is to visualise the relationship between two or more variables

#7.5.1 A categorical and continuous variable
#geom_freqpoly are not very useful.
ggplot(diamonds, mapping = aes(price, ..density..))+
  geom_freqpoly(mapping = aes(color = cut), binwidth = 500)
#density:  the count standardised so that the area under each frequency polygon is one.

#boxplot
ggplot(diamonds, mapping = aes(cut, price))+
  geom_boxplot()

ggplot(mpg, mapping = aes(class, hwy))+
  geom_boxplot()
#To make the trend easier to see, we can reorder class based on the median value of hwy:
ggplot(mpg)+
  geom_boxplot(mapping = aes(reorder(class, hwy, FUN = median), y = hwy))

#read about geom_lv()

ggplot(diamonds, mapping = aes(cut, price))+
  geom_violin()

#7.5.2 Two categorical variables
#To visualise the covariation between categorical variables, you'll need to count the number of observations for each combination. One way to do that is to rely on the built-in geom_count():
ggplot(diamonds)+
  geom_count(mapping = aes(cut, color))
#above code using dplyr
diamonds %>%
  count(color,cut)

diamonds %>%
  count(color, cut) %>%
  ggplot(mapping = aes(color, cut))+
  geom_tile(mapping = aes(fill=n))

#seriation, d3heatmap, and heatmaply packages

#7.5.3 Two continuous variables
ggplot(data = diamonds) +
  geom_point(mapping = aes(x = carat, y = price))

ggplot(data = diamonds) + 
  geom_point(mapping = aes(x = carat, y = price), alpha = 1 / 100)
#Scatterplots become less useful as the size of your dataset grows, because points begin to overplot, and pile up into areas of uniform black

ggplot(smaller)+
  geom_bin2d(mapping = aes(carat, price))

library(hexbin)
ggplot(smaller)+
  geom_hex(mapping = aes(carat, price))

#Another option is to bin one continuous variable so it acts like a categorical variable. Then you can use one of the techniques for visualising the combination of a categorical and a continuous variable that you learned about.
ggplot(data = smaller, mapping = aes(x = carat, y = price)) + 
  geom_boxplot(mapping = aes(group = cut_width(carat, 0.1)))

#7.6 Patterns and models
#Patterns in your data provide clues about relationships. If a systematic relationship exists between two variables it will appear as a pattern in the data. If you spot a pattern, ask yourself:
#Could this pattern be due to coincidence (i.e. random chance)?
#How can you describe the relationship implied by the pattern?
#How strong is the relationship implied by the pattern?
#What other variables might affect the relationship?
#Does the relationship change if you look at individual subgroups of the data?

#Patterns provide one of the most useful tools for data scientists because they reveal covariation. If you think of variation as a phenomenon that creates uncertainty, covariation is a phenomenon that reduces it. If two variables covary, you can use the values of one variable to make better predictions about the values of the second. If the covariation is due to a causal relationship (a special case), then you can use the value of one variable to control the value of the second.
#Models are a tool for extracting patterns out of data.

library(modelr)
mod <- lm(log(price) ~ log(carat), data = diamonds2)
diamonds2 <- diamonds %>%
  add_residuals(mod) %>%
  mutate(resid = exp(resid))
ggplot(diamonds2)+
  geom_point(mapping = aes(carat, resid))

ggplot(diamonds2)+
  geom_boxplot(mapping = aes(cut, resid))
