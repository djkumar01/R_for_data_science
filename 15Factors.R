#15 Factors

#15.1 Introduction
library(tidyverse)
library(forcats)

#15.2 Creating factors
x1 <- c("Dec", "Apr", "Jan", "Mar")
#Using a string to record this variable has two problems:
#There are only twelve possible months, and there's nothing saving you from typos:
x2 <- c("Dec", "Apr", "Jam", "Mar")
#It doesn't sort in a useful way:
sort(x1)

#You can fix both of these problems with a factor. To create a factor you must start by creating a list of the valid levels:
month_levels <- c(
  "Jan", "Feb", "Mar", "Apr", "May", "Jun", 
  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
)

#Now you can create a factor:
y1 <- factor(x1, levels = month_levels)
y1
sort(y1)

#And any values not in the set will be silently converted to NA:
y2 <- factor(x2, levels = month_levels)
y2

#If you omit the levels, they'll be taken from the data in alphabetical order:
factor(x1)

#Sometimes you'd prefer that the order of the levels match the order of the first appearance in the data. You can do that when creating the factor by setting levels to unique(x), or after the fact, with fct_inorder():
f1 <- factor(x1, levels = unique(x1))
f1
f2 <- x1 %>% factor() %>% fct_inorder()
f2

#If you ever need to access the set of valid levels directly, you can do so with levels():
levels(f2)

#15.3 General Social Survey
gss_cat

#When factors are stored in a tibble, you can't see their levels so easily. One way to see them is with count():
gss_cat %>% count(race)
#Or with a bar chart:
ggplot(gss_cat, aes(race))+
  geom_bar()

#By default, ggplot2 will drop levels that don't have any values. You can force them to display with:
ggplot(gss_cat, aes(race))+
  geom_bar()+
  scale_x_discrete(drop = F)

#15.4 Modifying factor order
#It's often useful to change the order of the factor levels in a visualisation.

relig_summary <- gss_cat %>%
  group_by(relig) %>%
  summarise(
    age = mean(age, na.rm = T),
    tvhours = mean(tvhours, na.rm = T),
    n = n()
  )
relig_summary
ggplot(relig_summary, aes(tvhours, relig)) +
  geom_point()
#It is difficult to interpret this plot because there's no overall pattern. We can improve it by reordering the levels of relig using fct_reorder().
#fct_reorder() takes three arguments:
#f, the factor whose levels you want to modify.
#x, a numeric vector that you want to use to reorder the levels.
#Optionally, fun, a function that's used if there are multiple values of x for each value of f. The default value is median.
ggplot(relig_summary, aes(tvhours, fct_reorder(relig, tvhours))) +
  geom_point()

rincome_summary <- gss_cat %>%
  group_by(rincome) %>%
  summarise(
    age = mean(age, na.rm = T),
    tvhours = mean(tvhours, na.rm = T),
    n = n()
  )
ggplot(rincome_summary, aes(age, fct_reorder(rincome, age)))+ 
  geom_point()
#Here, arbitrarily reordering the levels isn't a good idea! That's because rincome already has a principled order that we shouldn't mess with. Reserve fct_reorder() for factors whose levels are arbitrarily ordered.

#However, it does make sense to pull "Not applicable" to the front with the other special levels. You can use fct_relevel(). It takes a factor, f, and then any number of levels that you want to move to the front of the line.
ggplot(rincome_summary, aes(age, fct_relevel(rincome, "Not applicable"))) + 
  geom_point()

#Another type of reordering is useful when you are colouring the lines on a plot. fct_reorder2() reorders the factor by the y values associated with the largest x values. This makes the plot easier to read because the line colours line up with the legend.
by_age <- gss_cat %>%
  filter(!is.na(age)) %>%
  group_by(age, marital) %>%
  count() %>%
  mutate(prop = n/sum(n))

ggplot(by_age, aes(age, prop, colour = marital))+ 
  geom_line(na.rm = T)

ggplot(by_age, aes(age, prop, colour= fct_reorder2(marital, age, prop)))+
  geom_line()+
  labs(colour = "marital")
#not getting the output.

#for bar plots, you can use fct_infreq() to order levels in increasing frequency: this is the simplest type of reordering because it doesn't need any extra variables. You may want to combine with fct_rev().
gss_cat %>%
  mutate(marital = marital %>% fct_infreq() %>% fct_rev()) %>%
  ggplot(aes(marital))+
  geom_bar()

#15.5 Modifying factor levels
#More powerful than changing the orders of the levels is changing their values. This allows you to clarify labels for publication, and collapse levels for high-level displays. The most general and powerful tool is fct_recode(). It allows you to recode, or change, the value of each level.
gss_cat %>% count(partyid)

#The levels are terse and inconsistent. Let's tweak them to be longer and use a parallel construction.
gss_cat %>%
  mutate(partyid = fct_recode(partyid,
                              "Republican, strong"    = "Strong republican",
                              "Republican, weak"      = "Not str republican",
                              "Independent, near rep" = "Ind,near rep",
                              "Independent, near dem" = "Ind,near dem",
                              "Democrat, weak"        = "Not str democrat",
                              "Democrat, strong"      = "Strong democrat"
  )) %>%
  count(partyid)

#fct_recode() will leave levels that aren't explicitly mentioned as is, and will warn you if you accidentally refer to a level that doesn't exist.

#To combine groups, you can assign multiple old levels to the same new level:
gss_cat %>%
  mutate(partyid = fct_recode(partyid,
                              "Republican, strong"    = "Strong republican",
                              "Republican, weak"      = "Not str republican",
                              "Independent, near rep" = "Ind,near rep",
                              "Independent, near dem" = "Ind,near dem",
                              "Democrat, weak"        = "Not str democrat",
                              "Democrat, strong"      = "Strong democrat",
                              "Other"                 = "No answer",
                              "Other"                 = "Don't know",
                              "Other"                 = "Other party"
  )) %>%
  count(partyid)

#If you want to collapse a lot of levels, fct_collapse() is a useful variant of fct_recode(). For each new variable, you can provide a vector of old levels:
gss_cat %>%
  mutate(partyid = fct_collapse(partyid,
                                other = c("No answer", "Don't know", "Other party"),
                                rep = c("Strong republican", "Not str republican"),
                                ind = c("Ind,near rep", "Independent", "Ind,near dem"),
                                dem = c("Not str democrat", "Strong democrat")
  )) %>%
  count(partyid)

#Sometimes you just want to lump together all the small groups to make a plot or table simpler. That's the job of fct_lump():
gss_cat %>%
  mutate(relig = fct_lump(relig)) %>%
  count(relig)
#we can use the n parameter to specify how many groups (excluding other) we want to keep:
gss_cat %>%
  mutate(relig = fct_lump(relig, n =10 )) %>%
  count(relig, sort = T) %>%
  print(n = Inf)
