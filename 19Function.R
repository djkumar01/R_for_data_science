#19 Functions

#19.1 Introduction
#Functions allow you to automate common tasks in a more powerful and general way than copy-and-pasting. Writing a function has three big advantages over using copy-and-paste:
#You can give a function an evocative name that makes your code easier to understand.
#As requirements change, you only need to update code in one place, instead of many.
#You eliminate the chance of making incidental mistakes when you copy and paste (i.e. updating a variable name in one place, but not in another).


df <- tibble::tibble(
  a = rnorm(10),
  b = rnorm(10),
  c = rnorm(10),
  d = rnorm(10)
)
x <- df$a
x <- c(0,5,10)
rng <- range(x, na.rm = T)
(x - rng[1])/(rng[2] - rng[1])

#function to perform repeated task
rescale01 <- function(x) {
  rng <- range(x, na.rm = TRUE)
  (x - rng[1]) / (rng[2] - rng[1])
}
rescale01(c(0, 5, 10))
#There are three key steps to creating a new function:
#You need to pick a name for the function.
#You list the inputs, or arguments, to the function inside function.
#You place the code you have developed in body of the function, a { block that immediately follows function(...).
#Another advantage of functions is that if our requirements change, we only need to make the change in one place.

#19.4 Conditional execution
#An if statement allows you to conditionally execute code.
#You can use || (or) and && (and) to combine multiple logical expressions. These operators are "short-circuiting": as soon as || sees the first TRUE it returns TRUE without computing anything else. As soon as && sees the first FALSE it returns FALSE. You should never use | or & in an if statement: these are vectorised operations that apply to multiple values. If you do have a logical vector, you can use any() or all() to collapse it to a single value.

#19.5 Function arguments
#The arguments to a function typically fall into two broad sets: one set supplies the data to compute on, and the other supplies arguments that control the details of the computation. For example:
#In log(), the data is x, and the detail is the base of the logarithm.
#Generally, data arguments should come first. Detail arguments should go on the end, and usually should have default values. You specify a default value in the same way you call a function with a named argument:

# Compute confidence interval around mean using normal approximation
mean_ci <- function(x, conf = 0.95) {
  se <- sd(x) / sqrt(length(x))
  alpha <- 1 - conf
  mean(x) + se * qnorm(c(alpha / 2, 1 - alpha / 2))
}

x <- runif(100)
mean_ci(x)


#It's good practice to check important preconditions, and throw an error (with stop()), if they are not true:

#stopifnot(): it checks that each argument is TRUE, and produces a generic error message if not.
wt_mean <- function(x, w, na.rm = FALSE) {
  stopifnot(is.logical(na.rm), length(na.rm) == 1)
  stopifnot(length(x) == length(w))
  
  if (na.rm) {
    miss <- is.na(x) | is.na(w)
    x <- x[!miss]
    w <- w[!miss]
  }
  sum(w * x) / sum(w)
}
wt_mean(1:6, 6:1, na.rm = "foo")
#Note that when using stopifnot() you assert what should be true rather than checking for what might be wrong.

#... :this special argument captures any number of arguments that aren't otherwise matched.
#It's useful because you can then send those ... on to another function. This is a useful catch-all if your function primarily wraps another function.
commas <- function(...) stringr::str_c(..., collapse = ", ")
commas(letters[1:10])

#There are two basic types of pipeable functions: transformations and side-effects. With transformations, an object is passed to the function's first argument and a modified object is returned. With side-effects, the passed object is not transformed. Instead, the function performs an action on the object, like drawing a plot or saving a file. Side-effects functions should "invisibly" return the first argument, so that while they're not printed they can still be used in a pipeline.

#19.7 Environment
#The environment of a function controls how R finds the value associated with a name. For example, take this function:

f <- function(x) {
x + y
} 
#In many programming languages, this would be an error, because y is not defined inside the function. In R, this is valid code because R uses rules called lexical scoping to find the value associated with a name. Since y is not defined inside the function, R will look in the environment where the function was defined.
