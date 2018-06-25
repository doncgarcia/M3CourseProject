###########################################
#
# FILE: run_analysis.R
#
# OVERVIEW:
# Creating a tidy data using the collected data from the experiment on accelometers
# on Samsung Galaxy S Smartphones and saved the resulting file "tidy_data.txt"
#
###########################################

library(dplyr)

###########################################
# Downloading data
###########################################

fileURL <-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
fileDest <- "UCI_HAR_Data.zip"

#Checking if file exists

if (!file.exists(fileDest)) {
  download.file(fileURL, fileDest, mode = "wb")
}

# Unzip file in new file path

filePath <- "UCI HAR Dataset"

if (!file.exists(filePath)) {
  unzip(fileDest)
}

###########################################
# Reading Data
###########################################

filePath <- "UCI HAR Dataset"

# reading test and training data

TestSubject <- read.table(file.path(filePath,"test","subject_test.txt"))
TestSet <- read.table(file.path(filePath,"test","X_test.txt"))
TestLabels <- read.table(file.path(filePath,"test","y_test.txt"))

TrainSubject <- read.table(file.path(filePath,"train","subject_train.txt"))
TrainSet <- read.table(file.path(filePath,"train","X_train.txt"))
TrainLabels <- read.table(file.path(filePath,"train","y_train.txt"))




# read features and activities

DataFeatures <- read.table(file.path(filePath,"features.txt"))
ActivityName <- read.table(file.path(filePath,"activity_labels.txt"))

#Rename Column Names 

colnames(ActivityName)<-c("ActID","ActLabel")

colnames(TestSubject) <- "SubjectID"
colnames(TestSet) <- DataFeatures[,2]
colnames(TestLabels) <- "Activity"

colnames(TrainSubject) <- "SubjectID"
colnames(TrainSet) <- DataFeatures[,2]
colnames(TrainLabels) <- "Activity"

###########################################
# Step 1: Merging Data
###########################################

CompleteData <- rbind(cbind(TestSubject,TestSet,TestLabels),cbind(TrainSubject,TrainSet,TrainLabels))
rm(TestSubject,TestLabels,TestSet,TrainSubject,TrainLabels,TrainSet)

###########################################
# Step 2: Keeping Columns: SubjectID, Activity, Std and Mean
###########################################

ColToKeep <- grepl("SubjectID|Activity|mean|std", colnames(CompleteData))
CompleteData <- CompleteData[, ColToKeep]

###########################################
# Step 3: Change Activity Factor with Activity Labels
###########################################

CompleteData$Activity <-factor(CompleteData$Activity,
                                levels = ActivityName[,1],
                                labels = ActivityName[,2])

###########################################
# Step 4: Appropriately labels the data set with descriptive variable names
###########################################

# Extract Column Names
CompleteDataCol <- colnames(CompleteData)

# Clean Column Names
CompeteDataCol <- gsub("[\\(\\)-]", "", CompleteDataCol)

CompleteDataCol <- gsub("^f", "frequencyDomain", CompleteDataCol)
CompleteDataCol <- gsub("^t", "timeDomain", CompleteDataCol)
CompleteDataCol <- gsub("Acc", "Accelerometer", CompleteDataCol)
CompleteDataCol <- gsub("Mag", "Magnitude", CompleteDataCol)
CompleteDataCol <- gsub("Gyro", "Gyroscope", CompleteDataCol)
CompleteDataCol <- gsub("Freq", "Frequency", CompleteDataCol)
CompleteDataCol <- gsub("mean", "Mean", CompleteDataCol)
CompleteDataCol <- gsub("std", "StandardDeviation", CompleteDataCol)
CompleteDataCol <- gsub("BodyBody", "Body", CompleteDatCol)
colnames(CompleteData2) <- CompleteDataCol

###########################################
# Step 5:  independent tidy data set with the average of each variable for each activity and each subject
###########################################


# Group by SubjectID and Activity

CompleteDataMeans <- CompleteData %>% 
        group_by(SubjectID, Activity) %>%
        summarise_each(funs(mean))%>%
        print
  
# Output to file "tidy_data.txt"
  write.table(CompleteDataMeans, "tidy_data.txt", row.names = FALSE, 
              quote = FALSE)