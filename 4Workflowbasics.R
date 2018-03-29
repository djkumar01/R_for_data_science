#4. Workflow: basics

#You will make lots of assignments and <- is a pain to type. Don't be lazy and use =: it will work, but it will cause confusion later. Instead, use RStudio's keyboard shortcut: Alt + - (the minus sign).

seq(1,10)

#Quotation marks and parentheses must always come in a pair. RStudio does its best to help you, but it's still possible to mess up and end up with a mismatch. If this happens, R will show you the continuation character "+":

(y <- seq(1, 10, length.out = 5))
#This common action can be shortened by surrounding the assignment with parentheses, which causes assignment and "print to screen" to happen.


