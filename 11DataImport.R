#11.1 Introduction
library(tidyverse)

#11.2 Getting started
#read_csv() reads comma delimited files, read_csv2() reads semicolon separated files (common in countries where , is used as the decimal place), read_tsv() reads tab delimited files, and read_delim() reads in files with any delimiter.
#read_fwf() reads fixed width files. You can specify fields either by their widths with fwf_widths() or their position with fwf_positions(). read_table() reads a common variation of fixed width files where columns are separated by white space.
#read_log() reads Apache style log files.

#read_csv() uses the first line of the data for the column names, which is a very common convention. There are two cases where you might want to tweak this behaviour:
#1. Sometimes there are a few lines of metadata at the top of the file. You can use skip = n to skip the first n lines.
#2. The data might not have column names. You can use col_names = FALSE to tell read_csv() not to treat the first row as headings. Alternatively you can pass col_names a character vector which will be used as the column names:
read_csv('1,2,3 \n4,5,6', col_names = c('x','y','z'))

#Another option that commonly needs tweaking is na: this specifies the value (or values) that are used to represent missing values in your file:
read_csv("a,b,c\n1,2,.", na = ".")

#you might wonder why we’re not using read.csv(). There are a few good reasons to favour readr functions over the base equivalents:
#They are typically much faster (~10x) than their base equivalents. 
#They produce tibbles, they don’t convert character vectors to factors, use row names, or munge the column names.
#They are more reproducible. Base R functions inherit some behaviour from your operating system and environment variables, so import code that works on your computer might not work on someone else’s.

#11.3 Parsing a vector
#parse_*() functions take a character vector and return a more specialised vector like a logical, integer, or date:
str(parse_logical(c('TRUE','FALSE','NA')))
str(parse_integer(c('1','2','3')))
str(parse_date(c('2010-01-01','1979-10-14')))

#the parse_*() functions are uniform: the first argument is a character vector to parse, and the na argument specifies which strings should be treated as missing:
parse_integer(c('1','231','.','456'),na = '.')
#If parsing fails, you’ll get a warning:
x <- parse_integer(c("123", "345", "abc", "123.45"))

#If there are many parsing failures, you’ll need to use problems() to get the complete set. This returns a tibble, which you can then manipulate with dplyr.

#11.3.1 Numbers
#It seems like it should be straightforward to parse a number, but three problems make it tricky:
#People write numbers differently in different parts of the world. For example, some countries use . in between the integer and fractional parts of a real number, while others use ,.
parse_double('1,23',locale = locale(decimal_mark = ','))
#Numbers are often surrounded by other characters that provide some context, like “$1000” or “10%”.
parse_number('$100')
parse_number('20%')
parse_number('It cost $123.45')
#Numbers often contain “grouping” characters to make them easier to read, like “1,000,000”, and these grouping characters vary around the world.
#used in America
parse_number('$123,456,789')
#used in many parts of Europe
parse_number('123.456.789', locale = locale(grouping_mark = '.'))
#used in Switzerland
parse_number("123'456'789", locale = locale(grouping_mark = "'"))

#11.3.2 Strings
#underlying representation of a string using charToRaw():
charToRaw("Dhiraj")
# The mapping from hexadecimal number to character is called the encoding, and in this case the encoding is called ASCII(American Standard Code for Information Interchange)
# UTF-8 can encode just about every character used by humans today, as well as many extra symbols (like emoji!).
x1 <- "El Ni\xf1o was particularly bad this year"
x2 <- "\x82\xb1\x82\xf1\x82\xc9\x82\xbf\x82\xcd"
parse_character(x1, locale = locale(encoding = 'Latin1'))
parse_character(x2, locale = locale(encoding = 'Shift-JIS'))
#if system doesn't understand UTF-8 then you can use the above code.

#How do you find the correct encoding? If you’re lucky, it’ll be included somewhere in the data documentation. Unfortunately, that’s rarely the case, so readr provides guess_encoding() to help you figure it out.
guess_encoding(charToRaw(x1))
guess_encoding(charToRaw(x2))
#The first argument to guess_encoding() can either be a path to a file, or a raw vector.

#11.3.4 Dates, date-times, and times
#parse_datetime() expects an ISO8601 date-time. ISO8601 is an international standard in which the components of a date are organised from biggest to smallest: year, month, day, hour, minute, second.
parse_datetime('2010-10-01T2010')
parse_datetime("20101010")
parse_date("2010/10/10")
parse_time("20:10:10")

parse_date("01/02/15", "%d/%m/%y")
parse_date("1 janvier 2015", "%d %B %Y", locale = locale("fr"))
#read book to know more.