## Filename: run_analysis.R
## Project: samsung
## Course: Coursera -Getting and Cleaning Data

## Week 3 Project
## Author: Randeep Grewal

## Note I have used column width 130 rather than 80 given my personal monitor / computer setup

library(dplyr)
## Step 0 - we need to download the data from the web and unzip
## Obviously this does not need to be done if the files already exist

fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
data_directory <- "UCI HAR Dataset"
if (!file.exists(data_directory)){
    temp <- tempfile()
    download.file(fileUrl, destfile = temp, method ="curl")
    unzip(temp)
    dateDownloaded <- date()
}

setwd("UCI HAR Dataset")
## being slightly pedantic here
## row names and values of activity are the same
activity_labels <- read.table("activity_labels.txt", row.names=1) 
features <- read.table("features.txt")

setwd("test")
subject_test <- read.table("subject_test.txt")
x_test <- read.table("X_test.txt" )
y_test <- read.table("y_test.txt", header=FALSE)

setwd("../train")
subject_train <- read.table("subject_train.txt")
x_train <- read.table("X_train.txt")
y_train <- read.csv("y_train.txt", header = FALSE)

## Step 1 - 'Merges the training and the test sets to create one data set'
## For the merging of data sets always do train first and then test
## merge the train and test sets together using rbind
## We will do the cbinds a bit further down
subject_combined <- rbind(subject_train, subject_test)
x_combined <- rbind(x_train,x_test)
y_combined <- rbind(y_train,y_test)

## Step 3 - 'Uses descriptive activity names to name the activities in the data set'
## Step 4 - 'Appropriately labels the data set with descriptive variable names'
## Note that I think it is easier to do steps 3 and 4 prior to step 2
## Then use mutate to combine the subject, X and Y dataframes (ie part of step 1)
colnames(subject_combined) <- c("Subject")
colnames(x_combined) <- features[,2]
y_combined_labelled <- mutate(y_combined, activity = factor(V1, labels = activity_labels$V2))

data <- cbind(subject_combined, y_combined_labelled[,2], x_combined)
colnames(data)[2] <- "Activity"

## Step 2 - Extracts only the measurements on the mean and standard deviation for each measurement
## Finding the mean and the standard deviation
## For Mean we want to find mean()
##      - we want to ignore meanFreq()
##      - and also ignore gravityMean or JerkMean
## Note that the instructions are not entirely clear on this point
## But David Hood (Community Teaching Assistant) in the following makes the point
## that it needs to be logical rather than there being one exact solution
## See https://class.coursera.org/getdata-011/forum/thread?thread_id=19



cols_to_select <- grep("[Mm]ean\\(\\)|-std\\(\\)", colnames(data))

data <- data[,c(1:2,cols_to_select)] 

## Step 4 Use appropriate activity names to name the activities in the data set
##  We are going to rename the column names to make them more useful
##      - We will use Camel cases
##      - Will replace the f at the beginning with Freq
##      - will replace the t at the beginning with Time
##      - will replace -std()- with Std
##      - will replace -mean()- with Mean
## I am sure we could combine all the following gsubs into a single line
## but as learning safer to do each step separately
col_names <- names(data)
col_names <- gsub("^t","Time", col_names)
col_names <- gsub("^f","Freq", col_names)
col_names <- gsub("-std\\(\\)-|-std\\(\\)","Std",col_names)
col_names <- gsub("-mean\\(\\)-|-mean\\(\\)","Mean", col_names)

colnames(data) <- col_names

# So this is the final data set for step 4

## Step 5 <- from the data set in step 4 create a second independent tidy data set with the average of each variable for each activity and each subject
## Going to use a new variable newdata to store the grouped data
newdata <- group_by(data, Subject,Activity)
data_output <- summarise_each(newdata,funs(mean))

setwd("../..")
write.table(data_output, "tidy_data.txt", append = FALSE, row.name=FALSE, col.names=TRUE)

