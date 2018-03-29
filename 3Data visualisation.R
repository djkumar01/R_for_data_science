#3 Data visualisation
#3.1 Introduction

library(tidyverse)
#If we need to be explicit about where a function (or dataset) comes from, we'll use the special form
#package::function().

#3.2.2 Creating a ggplot
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy))
#ggplot() creates a coordinate system that you can add layers to. The first argument of ggplot() is
#the dataset to use in the graph. So ggplot(data = mpg) creates an empty graph. You complete your
#graph by adding one or more layers to ggplot(). The function geom_point() adds a layer of points to
#your plot, which creates a scatterplot. 

#Each geom function in ggplot2 takes a mapping argument. This defines how variables in your dataset
#are mapped to visual properties. The mapping argument is always paired with aes(), and the x and y
#arguments of aes() specify which variables to map to the x and y axes. ggplot2 looks for the mapped
#variable in the data argument, in this case, mpg.

#3.2.3 A graphing template
#This is just a template

#ggplot(data = <DATA>) + 
#  <GEOM_FUNCTION>(mapping = aes(<MAPPINGS>))

#3.2.4 Exercises
dim(mpg)

ggplot(data = mpg)

?mpg

ggplot(data=mpg)+
  geom_point(mapping = aes(x=cyl, y=hwy))

ggplot(data = mpg)+
  geom_point(mapping = aes(x=drv, y=class))
#plot is not useful because both are categorical variables.

#3.3 Aesthetic mappings
#An aesthetic is a visual property of the objects in your plot. Aesthetics include things like the
#size, the shape, or the color of your points. You can display a point (like the one below) in
#different ways by changing the levels of its aesthetic properties.

#You can convey information about your data by mapping the aesthetics in your plot to the variables in
#your dataset. For example, you can map the colors of your points to the class variable to reveal the
#class of each car.

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, color = class,))

#To map an aesthetic to a variable, associate the name of the aesthetic to the name of the variable
#inside aes(). ggplot2 will automatically assign a unique level of the aesthetic (here a unique color)
#to each unique value of the variable, a process known as scaling. ggplot2 will also add a legend that
#explains which levels correspond to which values.

#In the above example, we mapped class to the color aesthetic, but we could have mapped class to the
#size aesthetic in the same way. In this case, the exact size of each point would reveal its class
#affiliation. We get a warning here, because mapping an unordered variable (class) to an ordered
#aesthetic (size) is not a good idea.

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, size = class))

#Or we could have mapped class to the alpha aesthetic, which controls the transparency of the points,
#or the shape of the points.
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, alpha = class))

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, shape = class))
#In the above code one variable did't get a shape as ggplot only use six shapes at a time.  By 
#default, additional groups will go unplotted when you use the shape aesthetic.

#You can also set the aesthetic properties of your geom manually. For example, we can make all of the
#points in our plot blue:
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy), color='blue')

#stoke aes changes the size of all the points on the graph.

#One common problem when creating ggplot2 graphics is to put the + in the wrong place: it has to come
#at the end of the line, not the start.

#3.5 Facets
#particularly useful for categorical variables, is to split your plot into facets, subplots that each
#display one subset of the data.

#To facet your plot by a single variable, use facet_wrap(). The first argument of facet_wrap() should
#be a formula, which you create with ~ followed by a variable name (here "formula" is the name of a
#data structure in R, not a synonym for "equation"). The variable that you pass to facet_wrap() should
#be discrete.

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) + 
  facet_wrap(~ class, nrow = 2)

#If you prefer to not facet in the rows or columns dimension, use a . instead of a variable name, e.g.
#+ facet_grid(. ~ cyl).

#To facet your plot on the combination of two variables, add facet_grid() to your plot call. The first
#argument of facet_grid() is also a formula. This time the formula should contain two variable names
#separated by a ~.
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) + 
  facet_grid(drv ~ cyl)

#3.6 Geometric objects
#A geom is the geometrical object that a plot uses to represent data. People often describe plots by
#the type of geom that the plot uses. For example, bar charts use bar geoms, line charts use line
#geoms, boxplots use boxplot geoms, and so on. Scatterplots break the trend; they use the point geom.
ggplot(data = mpg) + 
  geom_smooth(mapping = aes(x = displ, y = hwy))

#Every geom function in ggplot2 takes a mapping argument. However, not every aesthetic works with
#every geom. You could set the shape of a point, but you couldn't set the "shape" of a line. On the
#other hand, you could set the linetype of a line. geom_smooth() will draw a different line, with a
#different linetype, for each unique value of the variable that you map to linetype.
ggplot(data = mpg) + 
  geom_smooth(mapping = aes(x = displ, y = hwy, linetype = drv))

#Many geoms, like geom_smooth(), use a single geometric object to display multiple rows of data. For
#these geoms, you can set the group aesthetic to a categorical variable to draw multiple objects.
#ggplot2 will draw a separate object for each unique value of the grouping variable. In practice,
#ggplot2 will automatically group the data for these geoms whenever you map an aesthetic to a discrete
#variable (as in the linetype example). It is convenient to rely on this feature because the group
#aesthetic by itself does not add a legend or distinguishing features to the geoms.
ggplot(data = mpg) +
  geom_smooth(mapping = aes(x = displ, y = hwy))

ggplot(data = mpg) +
  geom_smooth(mapping = aes(x = displ, y = hwy, group = drv))

ggplot(data = mpg) +
  geom_smooth(mapping = aes(x = displ, y = hwy, color = drv),show.legend = F)

#To display multiple geoms in the same plot, add multiple geom functions to ggplot():
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) +
  geom_smooth(mapping = aes(x = displ, y = hwy))
#This, however, introduces some duplication in our code. Imagine if you wanted to change the y-axis to
#display cty instead of hwy. You'd need to change the variable in two places, and you might forget to
#update one. You can avoid this type of repetition by passing a set of mappings to ggplot(). ggplot2
#will treat these mappings as global mappings that apply to each geom in the graph. In other words,
#this code will produce the same plot as the previous code:
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point() + 
  geom_smooth()

#If you place mappings in a geom function, ggplot2 will treat them as local mappings for the layer. It
#will use these mappings to extend or overwrite the global mappings for that layer only. This makes it
#possible to display different aesthetics in different layers.
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point(mapping = aes(color = class),show.legend = F) + 
  geom_smooth()

#You can use the same idea to specify different data for each layer. Here, our smooth line displays
#just a subset of the mpg dataset, the subcompact cars. The local data argument in geom_smooth()
#overrides the global data argument in ggplot() for that layer only.
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point(mapping = aes(color = class)) + 
  geom_smooth(data = filter(mpg, class == "subcompact"), se = F)
#se is confidence interval.

ggplot(data = mpg)+
  geom_point(mapping = aes(x=displ, y=hwy),color='black',stroke=2)+
  geom_smooth(mapping = aes(x=displ, y=hwy,linetype=drv),se=F,size=2)

#3.7 Statistical transformations
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut))

#Many graphs, like scatterplots, plot the raw values of your dataset. Other graphs, like bar charts,
#calculate new values to plot:bar charts, histograms, and frequency polygons bin your data and then
#plot bin counts, the number of points that fall in each bin. smoothers fit a model to your data and
#then plot predictions from the model. boxplots compute a robust summary of the distribution and then
#display a specially formatted box.

#The algorithm used to calculate new values for a graph is called a stat, short for statistical
#transformation.
#You can learn which stat a geom uses by inspecting the default value for the stat argument. For
#example, ?geom_bar shows that the default value for stat is "count", which means that geom_bar() uses
#stat_count().

#You can generally use geoms and stats interchangeably. For example, you can recreate the previous
#plot using stat_count() instead of geom_bar():

ggplot(data = diamonds) + 
  stat_count(mapping = aes(x = cut))

#You might want to override the default stat. In the code below, I change the stat of geom_bar() from
#count (the default) to identity. This lets me map the height of the bars to the raw values of a y 
#variable.
demo <- tribble(
  ~cut,         ~freq,
  "Fair",       1610,
  "Good",       4906,
  "Very Good",  12082,
  "Premium",    13791,
  "Ideal",      21551
)

ggplot(data = demo) +
  geom_bar(mapping = aes(x = cut,y=freq),stat = 'identity')
#There are two types of bar charts: geom_bar makes the height of the bar proportional to the number of
#cases in each group (or if the weight aethetic is supplied, the sum of the weights). If you want the 
#heights of the bars to represent values in the data, use geom_col instead. geom_bar uses stat_count 
#by default: it counts the number of cases at each x position. geom_col uses stat_identity: it leaves
#the data as is.

#display a bar chart of proportion
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, y = ..prop..,group=1))
#group=1 made it find the proportion, without it it was showing useless output.

?geom_bar
#stat_summary(), which summarises the y values for each unique x value
ggplot(data = diamonds) + 
  stat_summary(
    mapping = aes(x = cut, y = depth),
    fun.ymin = min,
    fun.ymax = max,
    fun.y = median
  )
?stat_summary
#the default geom in stat_summary is geom_pointrange()

ggplot(data=diamonds)+
geom_pointrange(mapping = aes(x=cut,y=depth, ymin=min(diamonds$depth),ymax=max(diamonds$depth)))

#3.8 Position adjustments
# You can colour a bar chart using either the colour aesthetic, or, more usefully, fill:
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, colour = cut))
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = cut))

#Note what happens if you map the fill aesthetic to another variable, like clarity: the bars are 
#automatically stacked. Each colored rectangle represents a combination of cut and clarity.
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = clarity))

#The stacking is performed automatically by the position adjustment specified by the position 
#argument. If you don't want a stacked bar chart, you can use one of three other options: "identity",
#"dodge" or "fill".

#position = "identity" will place each object exactly where it falls in the context of the graph. This
#is not very useful for bars, because it overlaps them. To see that overlapping we either need to make
#the bars slightly transparent by setting alpha to a small value, or completely transparent by setting
#fill = NA.
ggplot(data = diamonds, mapping = aes(x = cut, fill = clarity)) + 
  geom_bar(alpha = 1/5, position = "identity")
ggplot(data = diamonds, mapping = aes(x = cut, colour = clarity)) + 
  geom_bar(fill = NA, position = "identity")

#position = "fill" works like stacking, but makes each set of stacked bars the same height. This makes
#it easier to compare proportions across groups.
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = clarity), position = "fill")

#position = "dodge" places overlapping objects directly beside one another. This makes it easier to 
#compare individual values.
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = clarity), position = "dodge")

#There's one other type of adjustment that's not useful for bar charts, but it can be very useful for
#scatterplots. Recall our first scatterplot. Did you notice that the plot displays only 126 points, 
#even though there are 234 observations in the dataset? The values of hwy and displ are rounded so the
#points appear on a grid and many points overlap each other. This problem is known as overplotting. 
#This arrangement makes it hard to see where the mass of the data is.You can avoid this gridding by 
#setting the position adjustment to "jitter". position = "jitter" adds a small amount of random noise
#to each point. This spreads the points out because no two points are likely to receive the same 
#amount of random noise.
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy), position = "jitter")


ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) + 
  geom_point()+
  geom_jitter()
#or can use position='jitter' inside geom_point()

#3.9 Coordinate systems
#coord_flip() switches the x and y axes. This is useful (for example), if you want horizontal 
#boxplots. It's also useful for long labels: it's hard to get them to fit without overlapping on the
#x-axis.
ggplot(data = mpg, mapping = aes(x = class, y = hwy)) + 
  geom_boxplot()

ggplot(data = mpg, mapping = aes(x = class, y = hwy)) + 
  geom_boxplot() +
  coord_flip()

#coord_quickmap() sets the aspect ratio correctly for maps. This is very important if you're plotting
#spatial data with ggplot2
nz <- map_data("nz")

ggplot(nz, aes(long, lat, group = group)) +
  geom_polygon(fill = "white", colour = "black")

ggplot(nz, aes(long, lat, group = group)) +
  geom_polygon(fill = "white", colour = "black") +
  coord_quickmap()

#coord_polar() uses polar coordinates. Polar coordinates reveal an interesting connection between a 
#bar chart and a Coxcomb chart.
bar <- ggplot(data = diamonds) + 
  geom_bar(
    mapping = aes(x = cut, fill = cut), 
    show.legend = FALSE,
    width = 1
  ) + 
  theme(aspect.ratio = 1) +
  labs(x = NULL, y = NULL)

bar + coord_flip()
bar + coord_polar()

?coord_fixed
ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) +
  geom_point() + 
  geom_abline() + 
  coord_fixed() #keeps the x and y proportion same.

#The grammar of graphics is based on the insight that you can uniquely describe any plot as a 
#combination of a dataset, a geom, a set of mappings, a stat, a position adjustment, a coordinate 
#system, and a faceting scheme.