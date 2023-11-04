#Shut off the warnings
options(warn = -1)
#install and load libraries
suppressWarnings({
  # Install and load libraries
  install.packages("Rtools", quietly = TRUE)
  install.packages("data.table", quietly = TRUE)
  install.packages("dplyr", quietly = TRUE)
  install.packages("ggplot2", quietly = TRUE)
  install.packages("gridExtra", quietly = TRUE)
  install.packages("broom", quietly = TRUE)
  install.packages("BSDA", quietly = TRUE)
  install.packages("naniar", quietly = TRUE)
})

library(data.table)
library(stats)
library(dplyr)
library(ggplot2)
library(gridExtra)
library(broom)
library(ggplot2)
library(BSDA)
library(naniar)

#open csv as DataFrame with the correct filepath
df<- read.csv("C:/Users/raven/Desktop/[05] Portfolio Projects/Sofia Air Quality/2017-07_bme280sof.csv", header=TRUE)
str(df)

#Convert  the timestamp column from character to time

df$timestamp <- as.POSIXct(df$timestamp)

#observe structure of DataFrame
str(df)

#remove ID column
df_2017_07_Air <-df[, 2:9]

#Double Check
str(df_2017_07_Air)
head(df_2017_07_Air[1])

#Check for duplicate values
sum(duplicated(df_2017_07_Air))
#4026 duplicates in dataframe
# remove them with unique and check
df_2017_07_Air <- unique(df_2017_07_Air)
sum(duplicated(df_2017_07_Air))

#Count missing values in each column
colSums(is.na(df_2017_07_Air))

#Visualize missing values with a shadow matrix
vis_miss(as_shadow(df_2017_07_Air), warn_large_data = FALSE)

#Step 3. detect Outliers
colnames(df_2017_07_Air)
str(df_2017_07_Air)


#Visualize location histogram
ggplot(df_2017_07_Air, aes(x = location)) + geom_histogram() +theme_minimal()

#Visualize timestamp histogram
ggplot(df_2017_07_Air, aes(x = timestamp)) + geom_histogram() +theme_minimal()

#Visualize physical properties
#histograms
Phist <- ggplot(df_2017_07_Air, aes(x = pressure)) + geom_histogram() +theme_minimal()
Thist <-ggplot(df_2017_07_Air, aes(x = temperature)) + geom_histogram() +theme_minimal()
Hhist <- ggplot(df_2017_07_Air, aes(x = humidity)) + geom_histogram() +theme_minimal()
grid.arrange(Phist, Thist, Hhist, ncol = 3)

#boxplots
Pbox <- ggplot(df_2017_07_Air, aes(x = pressure)) + geom_boxplot() +theme_minimal() 
Tbox <- ggplot(df_2017_07_Air, aes(x = temperature)) + geom_boxplot() +theme_minimal()
Hbox <- ggplot(df_2017_07_Air, aes(x = humidity)) + geom_boxplot() +theme_minimal()
grid.arrange(Pbox, Tbox, Hbox, nrow = 3, ncol = 1)

#Treatment Plan
#Remove pressure and temperature outliers using the 1.5 iqr rule
Plower <- quantile(df_2017_07_Air$pressure, 0.25) - IQR(df_2017_07_Air$pressure)
Pupper <- quantile(df_2017_07_Air$pressure, 0.75) + IQR(df_2017_07_Air$pressure)
df_2017_07_Air <- filter(df_2017_07_Air, df_2017_07_Air$pressure > Plower)
df_2017_07_Air <- filter(df_2017_07_Air, df_2017_07_Air$pressure < Pupper)


Tlower <- quantile(df_2017_07_Air$temperature, 0.25) - IQR(df_2017_07_Air$temperature)
Tupper <- quantile(df_2017_07_Air$temperature, 0.75) + IQR(df_2017_07_Air$temperature)
df_2017_07_Air <- filter(df_2017_07_Air, df_2017_07_Air$temperature > Tlower) 
df_2017_07_Air <-filter(df_2017_07_Air, df_2017_07_Air$temperature < Tupper)


#Visualize boxplots, no more negative and zero values on P and T
Pbox <- ggplot(df_2017_07_Air, aes(x = pressure)) + geom_boxplot() +theme_minimal() 
Tbox <- ggplot(df_2017_07_Air, aes(x = temperature)) + geom_boxplot() +theme_minimal()
Hbox <- ggplot(df_2017_07_Air, aes(x = humidity)) + geom_boxplot() +theme_minimal()
grid.arrange(Pbox, Tbox, Hbox, nrow = 3, ncol = 1)

#convert humidity zero values to NA values and impute with sample humidity mean
df_2017_07_Air$humidity <- ifelse(df_2017_07_Air$humidity == 0, mean(df_2017_07_Air$humidity), df_2017_07_Air$humidity)

#check for missing values
colSums(is.na(df_2017_07_Air))

#check for 0 values
sum(df_2017_07_Air$humidity == 0)

#Apply the IQR Rule
Hlower <- quantile(df_2017_07_Air$humidity, 0.25) - IQR(df_2017_07_Air$humidity)
Hupper <- quantile(df_2017_07_Air$humidity, 0.75) + IQR(df_2017_07_Air$humidity)
df_2017_07_Air <- filter(df_2017_07_Air, df_2017_07_Air$humidity > Hlower)
df_2017_07_Air <- filter(df_2017_07_Air, df_2017_07_Air$humidity < Hupper)

#Final visualization of boxplots, no more negative and zero values on P and T
Pbox <- ggplot(df_2017_07_Air, aes(x = pressure)) + geom_boxplot() +theme_minimal() 
Tbox <- ggplot(df_2017_07_Air, aes(x = temperature)) + geom_boxplot() +theme_minimal()
Hbox <- ggplot(df_2017_07_Air, aes(x = humidity)) + geom_boxplot() +theme_minimal()
grid.arrange(Pbox, Tbox, Hbox, nrow = 3, ncol = 1)

#Final visualization of histograms, sharp peak at humidity mean due to imputation
Phist <- ggplot(df_2017_07_Air, aes(x = pressure)) + geom_histogram() +theme_minimal()
Thist <-ggplot(df_2017_07_Air, aes(x = temperature)) + geom_histogram() +theme_minimal()
Hhist <- ggplot(df_2017_07_Air, aes(x = humidity)) + geom_histogram() +theme_minimal()
grid.arrange(Phist, Thist, Hhist, ncol = 3)
