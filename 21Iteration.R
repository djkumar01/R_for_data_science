#21 Iteration
library(tidyverse)

#21.2 For loops
df <- tibble(
  a = rnorm(10),
  b = rnorm(10),
  c = rnorm(10),
  d = rnorm(10)
)

output <- vector("double", ncol(df))
for(i in seq_along(df)){
  output[[i]] <- median(df[[i]])
}
output

#21.3 For loop variations
#There are four variations on the basic theme of the for loop:
#Modifying an existing object, instead of creating a new object.
#Looping over names or values, instead of indices.
#Handling outputs of unknown length.
#Handling sequences of unknown length.

#21.3.4 Unknown sequence length
#Sometimes you don't even know how long the input sequence should run for. This is common when doing simulations. For example, you might want to loop until you get three heads in a row. You can't do that sort of iteration with the for loop. Instead, you can use a while loop.
#A while loop is also more general than a for loop, because you can rewrite any for loop as a while loop, but you can't rewrite every while loop as a for loop.

#Passing function as an argument in a function
col_summary <- function(df, fun) {
  out <- vector("double", length(df))
  for(i in seq_along(df)){
    out[i] <- fun(df[[i]])
  }
  out
}
col_summary(df, median)

#The goal of using purrr functions instead of for loops is to allow you break common list manipulation challenges into independent pieces:
#1. How can you solve the problem for a single element of the list? Once you've solved that problem, purrr takes care of generalising your solution to every element in the list.
#2. If you're solving a complex problem, how can you break it down into bite-sized pieces that allow you to advance one small step towards a solution? With purrr, you get lots of small pieces that you can compose together with the pipe.

#21.5 The map functions
#The pattern of looping over a vector, doing something to each element and saving the results is so common that the purrr package provides a family of functions to do it for you. There is one function for each type of output:
#map() makes a list.
#map_lgl() makes a logical vector.
#map_int() makes an integer vector.
#map_dbl() makes a double vector.
#map_chr() makes a character vector.
#Each function takes a vector as input, applies a function to each piece, and then returns a new vector that's the same length (and has the same names) as the input.

#We can use these functions to perform the same computations as the last for loop.
map_dbl(df, mean)
map_dbl(df, median)
map_dbl(df, sd)
#The map functions also preserve names.

#map_*() uses additional argments of function argument.
map_dbl(df, mean, trim = 0.5)

#21.5.1 Shortcuts
#Imagine you want to fit a linear model to each group in a dataset. The following toy example splits the up the mtcars dataset in to three pieces (one for each value of cylinder) and fits the same linear model to each piece:
models <- mtcars %>%
  split(.$cyl) %>%
  map(function(df) lm(mpg~ wt, data = df))

#The syntax for creating an anonymous function in R is quite verbose so purrr provides a convenient shortcut: a one-sided formula.
models <- mtcars %>%
  split(.$cyl) %>%
  map(~lm(mpg ~ wt, data = .))
#Here I've used . as a pronoun: it refers to the current list element

#When you're looking at many models, you might want to extract a summary statistic like the R2. To do that we need to first run summary() and then extract the component called r.squared. We could do that using the shorthand for anonymous functions:
models %>%
  map(summary) %>%
  map_dbl(~.$r.squared)

#But extracting named components is a common operation, so purrr provides an even shorter shortcut: you can use a string.
models %>%
  map(summary) %>%
  map_dbl("r.squared")

#You can also use an integer to select elements by position
x <- list(list(1, 2, 3), list(4, 5, 6), list(7, 8, 9))
x %>% map_dbl(2)

#21.6 Dealing with failure
#When you use the map functions to repeat many operations, the chances are much higher that one of those operations will fail. When this happens, you'll get an error message, and no output. This is annoying: why does one failure prevent you from accessing all the other successes? How do you ensure that one bad apple doesn't ruin the whole barrel?
#In this section you'll learn how to deal this situation with a new function: safely(). safely() is an adverb: it takes a function (a verb) and returns a modified version. In this case, the modified function will never throw an error. Instead, it always returns a list with two elements:
#1. result is the original result. If there was an error, this will be NULL.
#2. error is an error object. If the operation was successful, this will be NULL.

safe_log <- safely(log)
str(safe_log(10))
str(safe_log("a"))
#When the function succeeds, the result element contains the result and the error element is NULL. When the function fails, the result element is NULL and the error element contains an error object.

#safely() is designed to work with map:
x <- list(1, 10, "a")
y <- x %>% map(safely(log))
str(y)

#This would be easier to work with if we had two lists: one of all the errors and one of all the output. That's easy to get with purrr::transpose():
y <- y %>% transpose()
str(y)

is_ok <- y$error %>% map_lgl(is_null)
x[!is_ok]

#Purrr provides two other useful adverbs:
#Like safely(), possibly() always succeeds. It's simpler than safely(), because you give it a default value to return when there is an error.
x <- list(1, 10, "a")
x %>% map_dbl(possibly(log, NA_real_))

#quietly() performs a similar role to safely(), but instead of capturing errors, it captures printed output, messages, and warnings:
x <- list(1, -1)
x %>%
  map(quietly(log)) %>% str()

#21.7 Mapping over multiple arguments
#So far we've mapped along a single input. But often you have multiple related inputs that you need iterate along in parallel. That's the job of the map2() and pmap() functions.
mu <- list(5, 10, -3)
mu %>% map(rnorm, n = 5) %>% str()
sigma <- list(1,5, 10)
#iterating two vectors in parallel:
map2(mu, sigma, rnorm, n = 5) %>% str()

#use pmap for more than three arguments
n <- list(1, 3, 5)
args1 <- list(n, mu, sigma)
args1 %>% pmap(rnorm) %>% str()

#If you don't name the elements of list, pmap() will use positional matching when calling the function. That's a little fragile, and makes the code harder to read, so it's better to name the arguments:
args2 <- list(mean = mu, sd = sigma, n = n)
args2 %>% 
  pmap(rnorm) %>% 
  str()

#Since the arguments are all the same length, it makes sense to store them in a data frame:
params <- tribble(~mean, ~sd, ~n,
                  5,     1,  1,
                  10,     5,  3,
                  -3,    10,  5)
params %>% pmap(rnorm)

#21.7.1 Invoking different functions
#functions as parameter
f <- c("runif", "rnorm", "rpois")
param <- list(
  list(min = -1, max = 1), 
  list(sd = 5), 
  list(lambda = 10)
)
invoke_map(f, param, n = 5) %>% str()

#And again, you can use tribble() to make creating these matching pairs a little easier:
sim <- tribble(
    ~f,      ~params,
    "runif", list(min = -1, max = 1),
    "rnorm", list(sd = 5),
    "rpois", list(lambda = 10)
  )
sim %>% 
  mutate(sim = invoke_map(f, params, n = 10))

#21.8 Walk
#Walk is an alternative to map that you use when you want to call a function for its side effects, rather than for its return value. You typically do this because you want to render output to the screen or save files to disk - the important thing is the action, not the return value.
x <- list(1, "a", 3)
x %>% 
  walk(print)

#walk() is generally not that useful compared to walk2() or pwalk(). For example, if you had a list of plots and a vector of file names, you could use pwalk() to save each file to the corresponding location on disk:
library(ggplot2)
plots <- mtcars %>%
  split(.$cyl) %>%
  map(~ggplot(., aes(mpg, wt)) + geom_point())
path <- stringr::str_c(names(plots), ".pdf")
pwalk(list(path, plots), ggsave, path = tempdir())

#21.9 Other patterns of for loops
#21.9.1 Predicate functions
#A number of functions work with predicate functions that return either a single TRUE or FALSE.
#keep() and discard() keep elements of the input where the predicate is TRUE or FALSE respectively:
iris %>% 
  keep(is.factor) %>% 
  str()
iris %>% discard(is.factor) %>%
  str()

#some() and every() determine if the predicate is true for any or for all of the elements.
x <- list(1:5, letters, list(10))
x %>% 
  some(is_character)
x %>% every(is_vector)

#detect() finds the first element where the predicate is true; detect_index() returns its position.
x <- sample(10)
x
x %>% detect(~. > 5)
x %>% detect_index(~. > 5)

#head_while() and tail_while() take elements from the start or end of a vector while a predicate is true:
x %>% head_while(~ . > 5)
x %>% tail_while(~. > 5)

#21.9.2 Reduce and accumulate
#Sometimes you have a complex list that you want to reduce to a simple list by repeatedly applying a function that reduces a pair to a singleton. This is useful if you want to apply a two-table dplyr verb to multiple tables. For example, you might have a list of data frames, and you want to reduce to a single data frame by joining the elements together:
dfs <- list(
  age = tibble(name = "John", age = 30),
  sex = tibble(name = c("John", "Mary"), sex = c("M", "F")),
  trt = tibble(name = "Mary", treatment = "A")
)
dfs %>% reduce(full_join)

#Or maybe you have a list of vectors, and want to find the intersection:
vs <- list(
  c(1, 3, 5, 6, 10),
  c(1, 2, 3, 7, 8, 10),
  c(1, 2, 3, 4, 8, 9, 10)
)
vs %>% reduce(intersect)

#The reduce function takes a "binary" function (i.e. a function with two primary inputs), and applies it repeatedly to a list until there is only a single element left.
#Accumulate is similar but it keeps all the interim results. You could use it to implement a cumulative sum:
x <- sample(10)
x
x %>% accumulate('+')
#not showing the correct output
