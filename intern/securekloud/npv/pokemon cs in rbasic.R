library(dplyr)
library(ggplot2)
pokemon <- read.csv("D:\\CS\\npv\\pokemon.csv")
View(pokemon)
# checking number of rows and columns
nrow(pokemon)
ncol(pokemon)
# $ is used for extracting a componenet from an object
# tabulation of categorical columns
table(pokemon$is_legendary)
table(pokemon$generation)
table(pokemon$type1)

# Remove rows with missing values
pokemon <- pokemon[complete.cases(pokemon[, c("HP", "Speed")]), ]
grass_pokemon <- grass_pokemon[
  complete.cases(grass_pokemon[, c("Speed", "Sp..Atk", "Sp..Def")]),
]
fire_pokemon <- fire_pokemon[
  complete.cases(fire_pokemon[, c("Speed", "Sp..Atk", "Sp..Def")]),
]

# Convert columns to numeric
pokemon$HP <- as.numeric(pokemon$HP)
pokemon$Speed <- as.numeric(pokemon$Speed)
grass_pokemon$Speed <- as.numeric(grass_pokemon$Speed)
grass_pokemon$Sp..Atk <- as.numeric(grass_pokemon$Sp..Atk)
grass_pokemon$Sp..Def <- as.numeric(grass_pokemon$Sp..Def)
fire_pokemon$Speed <- as.numeric(fire_pokemon$Speed)
fire_pokemon$Sp..Atk <- as.numeric(fire_pokemon$Sp..Atk)
fire_pokemon$Sp..Def <- as.numeric(fire_pokemon$Sp..Def)


#min-max HP
min(pokemon$HP)
max(pokemon$HP)
min(pokemon$Speed)
max(pokemon$Speed)
# in outputs of the above 4 codes, we got the output as [n] m
# here n is the number of keys which got the value m
# checking missing values
is.na(pokemon$abilities)
# in output if there is any true value then there is a null or na value
sum(is.na(pokemon$abilities))
# renaming columns
colnames(pokemon)[colnames(pokemon) == "type1"] <- "primary_type"
colnames(pokemon)[colnames(pokemon) == "type2"] <- "secondary_type"
colnames(pokemon)[colnames(pokemon) == "name"] <- "pokemon_name"
# to see colnames in pokemon
colnames(pokemon)
# to see if any na values in specific column
# colnames(pokemon) yoyo==brooo 'column_name'
# DATA MANIPULATION
# grass pokemon
grass_pokemon <- pokemon %>% filter(pokemon$primary_type == "grass")
min(grass_pokemon$Speed)
max(grass_pokemon$Speed)
mean(grass_pokemon$Sp..Atk)
mean(grass_pokemon$Sp..Def)
# visualizing stats of grass pokemon
library(ggplot2)
# histogram plot
# HP
ggplot(data = grass_pokemon, aes(x = HP)) + geom_histogram()
ggplot(data = grass_pokemon, aes(x = HP)) + geom_histogram(fill = "palegreen4")
#Height
ggplot(data = grass_pokemon, aes(x = Height)) +
  geom_histogram(fill = "orange")
# weight
ggplot(data = pokemon, aes(x = Weight)) + geom_histogram(fill = "coral")
# legendary vs non-legendary
ggplot(data = grass_pokemon, aes(x = is_legendary)) +
  geom_bar(fill = "palegreen3")
# fire pokemon
fire_pokemon <- pokemon %>% filter(primary_type == "fire")
min(fire_pokemon$Speed)
max(fire_pokemon$Speed)
mean(fire_pokemon$Sp..Atk)
mean(fire_pokemon$Sp..Def)
# visualizing stats of fire pokemon
# generation
ggplot(data = fire_pokemon,
       aes(x = generation, fill = as.factor(generation))) +
  geom_bar()
# secondary_type
ggplot(data = fire_pokemon,
       aes(x = secondary_type, fill = secondary_type)) +
  geom_bar()
#sp_atack vs Sp..Def
ggplot(data = fire_pokemon, aes(x = Sp..Atk, y = Sp..Def)) + geom_point()
ggplot(data = fire_pokemon,
       aes(x = Sp..Atk, y = Sp..Def, col = as.factor(attack))) +
  geom_point()
# weight vs Height
ggplot(data = fire_pokemon, aes(x = Height, y = Weight)) + geom_point()