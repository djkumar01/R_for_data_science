#20. Vectors

library(tidyverse)

#20.2 Vector basics
#There are two types of vectors:
#Atomic vectors, of which there are six types: logical, integer, double, character, complex, and raw. Integer and double vectors are collectively known as numeric vectors.
#Lists, which are sometimes called recursive vectors because lists can contain other lists.
#The difference between atomic vectors and lists is that atomic vectors are homogeneous, while lists can be heterogeneous. 
#There's one other related object: NULL. NULL is often used to represent the absence of a vector (as opposed to NA which is used to represent the absence of a value in a vector). NULL typically behaves like a vector of length 0.

#Every vector has two key properties:
#1. Its type, which you can determine with typeof().
typeof(letters)
typeof(1:10)
#2. Its length, which you can determine with length().
x <- list("a", 'b', 1:10)
length(x)

#Vectors can also contain arbitrary additional metadata in the form of attributes. These attributes are used to create augmented vectors which build on additional behaviour. There are three important types of augmented vector:
#Factors are built on top of integer vectors.
#Dates and date-times are built on top of numeric vectors.
#Data frames and tibbles are built on top of lists.

#20.3 Important types of atomic vector
#20.3.1 Logical
#Logical vectors are the simplest type of atomic vector because they can take only three possible values: FALSE, TRUE, and NA. Logical vectors are usually constructed with comparison operators.
1:10 %% 3 == 0

#20.3.2
#integers and double vectors.  In R, numbers are doubles by default. To make an integer, place an L after the number:
typeof(1)
typeof(1L)

#The distinction between integers and doubles:
#1.Doubles are approximations. Doubles represent floating point numbers that can not always be precisely represented with a fixed amount of memory. This means that you should consider all doubles to be approximations. For example, what is square of the square root of two?
x <- sqrt(2)^2
x
x-2
#Instead of comparing floating point numbers using ==, you should use dplyr::near() which allows for some numerical tolerance.
#2. Integers have one special value: NA, while doubles have four: NA, NaN, Inf and -Inf. All three special values NaN, Inf and -Inf can arise during division:
c(1, 0, 1)/0
#Avoid using == to check for these other special values. Instead use the helper functions is.finite(), is.infinite(), and is.nan()

#20.3.3 Character
#Character vectors are the most complex type of atomic vector, because each element of a character vector is a string, and a string can contain an arbitrary amount of data.
#important feature of the underlying string implementation: R uses a global string pool. This means that each unique string is only stored in memory once, and every use of the string points to that representation. This reduces the amount of memory needed by duplicated strings.
x <- "This is a reasonably long string."
pryr::object_size(x) #136B
y <- rep(x, 1000)
pryr::object_size(y) #8.13kB
#y doesn't take up 1,000x as much memory as x, because each element of y is just a pointer to that same string. A pointer is 8 bytes, so 1000 pointers to a 136 B string is 8 * 1000 + 136 = 8.13 kB.

#20.3.4 Missing values
#Note that each type of atomic vector has its own missing value:

NA            # logical
NA_integer_   # integer
NA_real_      # double
NA_character_ # character

dplyr::near #to see the source code, drop the ().

#20.4 Using atomic vectors
#20.4.1 Coercion
#There are two ways to convert, or coerce, one type of vector to another:
#1. Explicit coercion happens when you call a function like as.logical(), as.integer(), as.double(), or as.character().
#2. Implicit coercion happens when you use a vector in a specific context that expects a certain type of vector. For example, when you use a logical vector with a numeric summary function, or when you use a double vector where an integer vector is expected.
#Here we will talk about implicit coercion
x <- sample(20, 100, replace = T)
y <- x > 10 #list of true and false
sum(y)
mean(y)

#20.4.2 Test functions
#use is_* functions provided by purrr function and not the functions in base R.

#20.4.3 Scalars and recycling rules
#R implicitly coerces the length of vectors. This is called vector recycling, because the shorter vector is repeated, or recycled, to the same length as the longer vector.
#This is useful when you are mixing vectors and "scalars". I put scalars in quotes because R doesn't actually have scalars: instead, a single number is a vector of length 1. Because there are no scalars, most built-in functions are vectorised, meaning that they will operate on a vector of numbers. That's why, for example, this code works:
sample(10) +100
runif(10) > 0.5

#What happens if you add two vectors of different lengths?
1:10 + 1:2
#Here, R will expand the shortest vector to the same length as the longest, so called recycling. This is silent except when the length of the longer is not an integer multiple of the length of the shorter:
1:10 + 1:3

#The vectorised functions in tidyverse will throw errors when you recycle anything other than a scalar. If you do want to recycle, you'll need to do it yourself with rep():
tibble(x = 1:4, y = 1:2) #error
tibble(x = 1:4, y = rep(1:2, 2))

#20.4.4 Naming vectors
#All types of vectors can be named. You can name them during creation with c():
c(x = 1, y = 2, z = 4)
#Or after the fact with purrr::set_names():
set_names(1:3, c("a", "b", "c"))
#Named vectors are most useful for subsetting,

#20.4.5 Subsetting
#[ is the subsetting function, and is called like x[a]. There are four types of things that you can subset a vector with:
#1. A numeric vector containing only integers. The integers must either be all positive, all negative, or zero.
#Subsetting with positive integers keeps the elements at those positions:
x <- c("one", "two", "three", "four", "five")
x[c(3, 2, 5)]
#Negative values drop the elements at the specified positions:
x[c(-1, -3, -5)]

#2. Subsetting with a logical vector keeps all values corresponding to a TRUE value. This is most often useful in conjunction with the comparison functions.
x <- c(10, 3, NA, 5, 8, 1, -8)
# All non-missing values of x
x[!is.na(x)]
# All even (or missing!) values of x
x[x %% 2 == 0]

#3. If you have a named vector, you can subset it with a character vector:
x <- c(abc = 1, def = 2, xyz = 5)
x[c("xyz", "def")]

#4. The simplest type of subsetting is nothing, x[], which returns the complete x. This is not useful for subsetting vectors, but it is useful when subsetting matrices (and other high dimensional structures) because it lets you select all the rows or all the columns, by leaving that index blank.

#[[ only ever extracts a single element, and always drops names.

?which #give the TRUE indices of a logical object.

#20.5 Recursive vectors (lists)
#Lists are a step up in complexity from atomic vectors, because lists can contain other lists. This makes them suitable for representing hierarchical or tree-like structures.
x <- list(1, 2, 3)

#A very useful tool for working with lists is str() because it focusses on the structure, not the contents.
str(x)

#Unlike atomic vectors, list() can contain a mix of objects:
y <- list("a", 1L, 1.5, TRUE)
str(y)

#Lists can even contain other lists!

z <- list(list(1, 2), list(3, 4))
str(z)

#20.5.2 Subsetting
#There are three ways to subset a list:
a <- list(a = 1:3, b = "a string", c = pi, d = list(-1, -5))
#1. [ extracts a sub-list. The result will always be a list.
str(a[1:2])
str(a[4])

#2. [[ extracts a single component from a list. It removes a level of hierarchy from the list.
str(a[[1]])


x3 <- list(1, list(2, list(3)))
x3[[2]][[2]]
#[[ drills down into the list while [ returns a new, smaller list.

#3. $ is a shorthand for extracting named elements of a list. It works similarly to [[ except that you don't need to use quotes.
a$a

#20.6 Attributes
#Any vector can contain arbitrary additional metadata through its attributes. You can think of attributes as named list of vectors that can be attached to any object. You can get and set individual attribute values with attr() or see them all at once with attributes().
x <- 1:10
attr(x, "greeting")
attr(x, "greeting") <- "hi"
attr(x, "greeting") <- "bye"
attributes(x)

#20.7 Augmented vectors
#Atomic vectors and lists are the building blocks for other important vector types like factors and dates. I call these augmented vectors, because they are vectors with additional attributes

#20.7.1 Factors
#Factors are designed to represent categorical data that can take a fixed set of possible values. Factors are built on top of integers, and have a levels attribute:
x <- factor(c("ab", "cd", "ab"), levels = c("ab", "cd", "ef"))
typeof(x)
attributes(x)

#20.7.2 Dates and date-times
#Dates in R are numeric vectors that represent the number of days since 1 January 1970.
x <- as.Date("1971-01-01")
unclass(x)
?unclass #idn't understand anything
typeof(x)
attributes(x)

#Date-times are numeric vectors with class POSIXct that represent the number of seconds since 1 January 1970. (In case you were wondering, "POSIXct" stands for "Portable Operating System Interface", calendar time.)
x <- lubridate::ymd_hm("1970-01-01 01:00")
unclass(x)
typeof(x)
attributes(x)

#The tzone attribute is optional. It controls how the time is printed, not what absolute time it refers to.
attr(x, "tzone") <- "US/Pacific"
x

#20.7.3 Tibbles
#Tibbles are augmented lists: they have class "tbl_df" + "tbl" + "data.frame", and names (column) and row.names attributes:
#The difference between a tibble and a list is that all the elements of a data frame must be vectors with the same length. All functions that work with tibbles enforce this constraint.
#The main difference is the class. The class of tibble includes "data.frame" which means tibbles inherit the regular data frame behaviour by default.