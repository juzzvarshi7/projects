# data manipulation
# process of finding insights by fitering, aggregating and summarizing the raw data
# dplyr package


# to view number of rows
#nrow(file_name)

# to view number of columns
#ncol(file_name)

# to read an excel
# import real excel package
# library(readxl)
# file_name <- read_excel("path name)

# install package
#install.packages('package_name')

# load dplyr package
#library(dplyr)

# to read a csv file
#file_name <- read.csv(path_csv)
# use / instead of // or \

# to view or open a csv file after reading
# View(file_name)

#pipe operator -- %>%
# and operator -- &

# to select specific columns and assign it into new file
# file_name %>% select(column_number1, columns_number2) -> new_file_name

# to select a range of columns
# file_name %>% select(start:stop) -> new_file_name

# can also select columnds using the names of the columns
# file_name %>% select('columnname1', 'columnname2')

# to select columns starting with some letter
# file_name %>% select(starts_with("The_letter")) -> new_file_name

# to select columns ending with some letter
# file_name %>% select(ends_with("The_letter")) -> new_file_name

# filter
# file_name %>% filter(Column_name == 'name_of_filter') -> new_file_name
# file_name %>% filter(Column_name>Value) -> new_file_name
# file_name %>% filter(Column_name == 'name_of_filter' & Column_name>Value) -> new_file_name

# combining select and filter
# file_name %>% select('columnname1', 'columnname2') %>% (Column_name == 'name_of_filter') -> new_file_name


# DATA VISUALZATION WITH GGPLOT2
# col=cut gives different colours
# histogram
# ggplot(data=file_name, aes(x=column_name) + geom_histogram())
# ggplot(data=file_name, aes(x=column_name)) + geom_histogram(fill="green", col='orange')

# bar plot
# ggplot(data=file_name, aes(x=column_name)) + geom_bar(fill="palegreen4")
# ggplot(data=file_name, aes(x=column_name, fill=column_name)) + geom_bar()

# scatter plot
# ggplot(data = file_name, aes(x=column_name, y=column_name_2, col=cut)) + geom_point()

# box-plot
# above to below three lines
# first line = 75 percentile
# second line = median
# third line = 25 percentile
# ggplot(data= file_name, aes(x=column1name, y=column2name)) + geom_boxplot()
# ggplot(data= file_name, aes(x=column1name, y=column2name, fill=column1name)) + geom_boxplot()
# ggplot(data= file_name, aes(x=column1name, y=column2name, fill=column_name)) + geom_boxplot()

# faceting (dividing)
# ~ - tilde operator - specify the relationship between variables
# in context of ggplot2 in aes(), this symbol denotes how variables should be mapped to visual properties
# faceting - dividing a plot into multiple panels based on the values of one or more categorical variables
# facet_wrap() - for single categorical variable
# facet_grid() - for two categorical variable - one for row and one for column
# ggplot(data= file_name, aes(x=column1name, y=column2name, fill=column_name)) + geom_boxplot() + facet_grid(column_name3)
# element_rect() - used for plot background or panel

