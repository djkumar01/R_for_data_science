#14 Strings
library(tidyverse)
library(stringr)

#14.2 String basics
#You can create strings with either single quotes or double quotes. Unlike other languages, there is no difference in behaviour.

string1 <- "This is a string"
string2 <- 'If I want to include a "quote" inside a string, I use single quotes'

#To include a literal single or double quote in a string you can use \ to "escape" it:
single_quote <- '\''
double_quote <- "\""
# if you want to include a literal backslash, you'll need to double it up: "\\".

#Beware that the printed representation of a string is not the same as string itself, because the printed representation shows the escapes. To see the raw contents of the string, use writeLines():
x <- c("\"", "\\")
x
writeLines(x)
?"'" #to get a complete list of special characters.

str_length(c("a", "R for data science", NA))
#String length

str_c("x", "y")
str_c("x", "y", "z")
#to combine two or more strings.
#Use the sep argument to control how they're separated:
str_c("x", "y", sep = "- ")
#in case c() is used then,
str_c(c("x", "y", "z"), collapse = ", ")

# missing values are contagious. If you want them to print as "NA", use str_replace_na():
x <- c("abc", NA)
str_c("|-", x, "-|")
str_c("|-", str_replace_na(x), "-|")

#str_c("prefix-", c("a", "b", "c"), "-suffix")

name <- "Hadley"
time_of_day <- "morning"
birthday <- FALSE

str_c("Good ", time_of_day, " ", name, if (birthday) " and HAPPY BIRTHDAY", ".")

#You can extract parts of a string using str_sub(). As well as the string, str_sub() takes start and end arguments which give the (inclusive) position of the substring:
x <- c("Apple", "Banana", "Pear")
str_sub(x, 1, 3)
#Note that str_sub() won't fail if the string is too short: it will just return as much as possible:
str_sub("a", 1, 5)

#You can also use the assignment form of str_sub() to modify strings:
str_sub(x, 1, 1) <- str_to_lower(str_sub(x, 1, 1))
x

# The base R order() and sort() functions sort strings using the current locale. If you want robust behaviour across different computers, you may want to use str_sort() and str_order() which take an additional locale argument:
x <- c("a", "e", "b")
str_sort(x, locale = "en")
str_sort(x, locale = "haw") #Hawaiian

#Exercise
?paste
paste0(x, collapse = ", ") #equivalent to str_c()
paste(1:12)
#paste0() is more efficient.

?str_wrap
thanks_path <- file.path(R.home("doc"), "THANKS")
thanks <- str_c(readLines(thanks_path), collapse = "\n")
thanks <- word(thanks, 1, 3, fixed("\n\n"))
cat((thanks), "\n")
cat(str_wrap(thanks, width = 40), "\n")
cat(str_wrap(thanks, width = 60, indent = 2), "\n")
cat(str_wrap(thanks, width = 60, exdent = 2), "\n")
cat(str_wrap(thanks, width = 0, exdent = 2, indent = 2), "\n")

?str_trim #trim whitespace from start and end of string.
str_trim("  String with trailing and leading white space\t")

str_pad("hadley", 30, "left") #opposite of set_trim()

fun <- function(y) {
  l <- str_c(y, collapse = ", ") 
  str_sub(l, -1, 0) <- "and "
  return(l)
  }
fun(x)
#doing it without function
q <- str_c(x, collapse = ", ")
q
str_sub(q, -1, 0) <- "and "
q

#14.3 Matching patterns with regular expressions
#To learn regular expressions, we'll use str_view() and str_view_all(). These functions take a character vector and a regular expression, and show you how they match.

#14.3.1 Basic matches
x <- c("apple", "banana", "pear")
str_view(x, "an") #match exact strings

str_view(x, ".a.") # . matches any character (except a newline)
#"." matches any character, we need to use an "escape". Regexps use the backslash, \, to escape special behaviour. So to match an ., you need the regexp \.. Unfortunately this creates a problem. We use strings to represent regular expressions, and \ is also used as an escape symbol in strings. So to create the regular expression \. we need the string "\\.".

dot <- "\\."
writeLines(dot)
str_view(c("abc", "a.c", "bef"), "a\\.c")

# to match a literal \ you need to write "\\\\" - you need four backslashes to match one!
x <- "a\\b"
writeLines(x)
str_view(x, "\\\\")

#Exercise
w <- "\\..\\..\\.."
writeLines(w)
e <- "as\\afn\\we\\er\\werwradf"
str_view(e, "\\..\\..\\..")

#14.3.2 Anchors
#By default, regular expressions will match any part of a string. It's often useful to anchor the regular expression so that it matches from the start or end of the string. You can use:
#^ to match the start of the string.
#$ to match the end of the string.
x <- c("apple", "banana", "pear")
str_view(x, "^a")
str_view(x, "a$")

#To force a regular expression to only match a complete string, anchor it with both ^ and $:
x <- c("apple pie", "apple", "apple cake")
str_view(x, "^apple$")
#try str_view(x, "apple") to see the difference.

#Exercise
d <- "$^$"
str_view(d, "\\$\\^\\$")

m <-  str_view_all(words, "^ab")
m
n <- str_view_all(words, "x$")
n
class(words)
?str_view

#14.3.3 Character classes and alternatives
#There are a number of special patterns that match more than one character. 
#\d: matches any digit.
#\s: matches any whitespace (e.g. space, tab, newline).
#[abc]: matches a, b, or c.
#[^abc]: matches anything except a, b, or c.

#You can use alternation to pick between one or more alternative patterns. For example, abc|d..f will match either '"abc"', or "deaf".
str_view(c("grey", "gray"), "gr(a|e)y")

#14.3.4 Repetition
#The next step up in power involves controlling how many times a pattern matches:
#?: 0 or 1
#+: 1 or more
#*: 0 or more
x <- "1888 is the longest year in Roman numerals: MDCCCLXXXVIII"
str_view(x, "CC?")
str_view(x, "CC+")
str_view(x, "C[LX]+")

#so you can write: colou?r to match either American or British spellings.

#You can also specify the number of matches precisely:
#{n}: exactly n
#{n,}: n or more
#{,m}: at most m
#{n,m}: between n and m
str_view(x, "C{2}")
str_view(x, "C{2,}")
str_view(x, "C{2,3}")

#By default these matches are "greedy": they will match the longest string possible. You can make them "lazy", matching the shortest string possible by putting a ? after them.
str_view(x, "C{2,3}?")
str_view(x, 'C[LX]+?')

#14.3.5 Grouping and backreferences
#Earlier, you learned about parentheses as a way to disambiguate complex expressions. They also define "groups" that you can refer to with backreferences, like \1, \2 etc. For example, the following regular expression finds all fruits that have a repeated pair of letters.
str_view(fruit, "(..)\\1", match = T)
#"anan"

#Exercise
str_view(fruit,"(.)\1\1", match = T)
str_view(fruit,"(.)(.)\\2\\1", match = T)
#"eppe"
str_view(fruit,"(..)\1", match = T)
str_view(fruit,"(.).\\1\\1", match = T)
str_view(fruit,"(.)(.)(.).*\\3\\2\\1", match = T)
#??????

#14.4 Tools
#14.4.1 Detect matches
#To determine if a character vector matches a pattern, use str_detect(). It returns a logical vector the same length as the input:
x <- c("apple", "banana", "pear")
str_detect(x, "e")
#Remember that when you use a logical vector in a numeric context, FALSE becomes 0 and TRUE becomes 1. That makes sum() and mean() useful if you want to answer questions about matches across a larger vector:
sum(str_detect(words, "^t"))
#words start with t
mean(str_detect(words, "[aeiou]$"))
#proportion of words end with a vowel.

# here are two ways to find all words that don't contain any vowels:
no_vowels_1 <- !str_detect(words, "[aeiou]")
#and
no_vowels_2 <- str_detect(words, "^[^aeiou]+$")

#A common use of str_detect() is to select the elements that match a pattern. You can do this with logical subsetting, or the convenient str_subset() wrapper:
words[str_detect(words, "x$")]
str_subset(words, "x$")

#Typically, however, your strings will be one column of a data frame, and you'll want to use filter instead:
df <- tibble(
  word= words,
  i= seq_along(word)
)
df %>% filter(str_detect(words, "x$"))

#str_count():it tells you how many matches there are in a string:
x <- c("apple", "banana", "pear")
str_count(x, "a")

# On average, how many vowels per word?
mean(str_count(words, "[aeiou]"))

df %>%
  mutate( vowels = str_count(word, "[aeiou]"),
          consonants = str_count(word,"[^aeiou]" ))

#Note that matches never overlap. For example, in "abababa", how many times will the pattern "aba" match? Regular expressions say two, not three:
str_count("abababa", "aba")
str_view_all("abababa", "aba")

#14.4.3 Extract matches
#To extract the actual text of a match, use str_extract(). 
length(sentences)
head(sentences)
colours <- c("red", "orange", "yellow", "green", "blue", "purple")
colour_match <- str_c(colours, collapse = "|")
colour_match
(has_colour <- str_subset(sentences, colour_match))
(matches <- str_extract(has_colour, colour_match))
head(matches)
#Note that str_extract() only extracts the first match.
more <- sentences[str_view(sentences, colours)>1]
str_view_all(more, colour_match)
str_extract(more, colour_match)
str_extract_all(more, colour_match)
#see the differnece between the outputs of the three codes.

str_extract_all(more, colour_match, simplify = T)
#If you use simplify = TRUE, str_extract_all() will return a matrix with short matches expanded to the same length as the longest:
x <- c("a", "a b", "a b c")
str_extract_all(x, "[a-z]", simplify = TRUE)

#14.4.4 Grouped matches
noun <- "(a|the) ([^ ]+)"
has_noun <- sentences %>%
  str_subset(noun) %>%
  head(10)
has_noun %>%
  str_extract(noun)

#str_extract() gives us the complete match; str_match() gives each individual component. Instead of a character vector, it returns a matrix, with one column for the complete match followed by one column for each group
has_noun %>%
  str_match(noun)

#14.4.5 Replacing matches
#str_replace() and str_replace_all() allow you to replace matches with new strings. The simplest use is to replace a pattern with a fixed string:
x <- c("apple", "pear", "banana")
str_replace(x, "[aeiou]", "-")
str_replace_all(x, "[aeiou]", "-")

#With str_replace_all() you can perform multiple replacements by supplying a named vector:
x <- c("1 house", "2 cars", "3 people")
str_replace_all(x, c("1" = "one", "2" = "two", "3" = "three"))

#14.4.6 Splitting
#Use str_split() to split a string up into pieces. For example, we could split sentences into words:
sentences %>%
  head(5) %>%
  str_split(" ")
#Because each component might contain a different number of pieces, this returns a list. If you're working with a length-1 vector, the easiest thing is to just extract the first element of the list:
"a|b|c|d" %>% 
  str_split("\\|") %>% 
  .[[1]]

sentences %>%
  head(5) %>% 
  str_split(" ", simplify = TRUE) #it returns a list.

#You can also request a maximum number of pieces:
fields <- c("Name: Hadley", "Country: NZ", "Age: 35")
fields %>% str_split(": ", n = 2, simplify = TRUE)

#Instead of splitting up strings by patterns, you can also split up by character, line, sentence and word boundary()s:
x <- "This is a sentence.  This is another sentence."
str_view_all(x, boundary("word"))
str_split(x, " ")[[1]]
str_split(x, boundary("word"))[[1]]

#14.5 Other types of pattern
#When you use a pattern that's a string, it's automatically wrapped into a call to regex():
# The regular call:
str_view(fruit, "nana")
# Is shorthand for
str_view(fruit, regex("nana"))

#You can use the other arguments of regex() to control details of the match:
#ignore_case = TRUE allows characters to match either their uppercase or lowercase forms. This always uses the current locale.
bananas <- c("banana", "Banana", "BANANA")
str_view(bananas, "banana")
str_view(bananas, regex("banana", ignore_case = TRUE))

#multiline = TRUE allows ^ and $ to match the start and end of each line rather than the start and end of the complete string.
x <- "Line 1\nLine 2\nLine 3"
str_extract_all(x, "^Line")[[1]]
str_extract_all(x, regex("^Line", multiline = TRUE))[[1]]

#comments = TRUE allows you to use comments and white space to make complex regular expressions more understandable. Spaces are ignored, as is everything after #. To match a literal space, you'll need to escape it: "\\ ".
phone <- regex("
               \\(?     # optional opening parens
               (\\d{3}) # area code
               [)- ]?   # optional closing parens, dash, or space
               (\\d{3}) # another three numbers
               [ -]?    # optional space or dash
               (\\d{3}) # three more numbers
               ", comments = TRUE)

str_match("514-791-8141", phone)

#dotall = TRUE allows . to match everything, including \n.

#There are three other functions you can use instead of regex():
#fixed(): matches exactly the specified sequence of bytes. It ignores all special regular expressions and operates at a very low level. This allows you to avoid complex escaping and can be much faster than regular expressions.
microbenchmark::microbenchmark(
  fixed = str_detect(sentences, fixed("the")),
  regex = str_detect(sentences, "the"),
  times = 20
)
#Beware using fixed() with non-English data.  Instead, you can use coll()  to respect human character comparison rules: It is problematic because there are often multiple ways of representing the same character.
#coll(): compare strings using standard collation rules. This is useful for doing case insensitive matching. Note that coll() takes a locale parameter that controls which rules are used for comparing characters.
# That means you also need to be aware of the difference
# when doing case insensitive matches:
i <- c("I", "I", "i", "i")
i
str_subset(i, coll("i", ignore_case = TRUE))
str_subset(i, coll("i", ignore_case = TRUE, locale = "tr"))

stringi::stri_locale_info() #default locale.

#The downside of coll() is speed; because the rules for recognising which characters are the same are complicated, coll() is relatively slow compared to regex() and fixed().

#14.6 Other uses of regular expressions
#There are two useful function in base R that also use regular expressions:
#apropos() searches all objects available from the global environment. This is useful if you can't quite remember the name of the function.
apropos("replace")

#dir() lists all the files in a directory. The pattern argument takes a regular expression and only returns file names that match the pattern.
head(dir(pattern = "\\.Rmd$"))

#14.7 stringi
#read about it.