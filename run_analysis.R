#************************************************************************
# Script for Courseproject 2 in the Getting and Cleaning Data course    *
# Author : G de Joode									*
# Notes: for this script to run the datafiles need to be in the same	*
# directory as the script is run from						*			*
#************************************************************************

library(dplyr)

# Part 1 and 4 of CP: First we load the datasets and merge them together using cbind and rbind

features <- read.table("features.txt")	# load the feature names data

trainX <- read.table("X_train.txt")		# load the training set
trainY <- read.table("Y_train.txt")		# load the activity code
subj <- read.table("subject_train.txt")	# load the subject id
colnames(trainX) <- features[,2]		# set the feature names (part 4 of the courseproject)


tot_train <- cbind(subj, trainY, trainX)	# bind the columns together
colnames(tot_train)[1] <- "subject"		# name the first column (i.e. subject)
colnames(tot_train)[2] <- "activity"	# name the second column (i.e. activity)

rm(trainX, trainY,subj)				# do some garbage collection since I have limited memory
gc()

testX <- read.table("X_test.txt")		# load the test set
testY <- read.table("Y_test.txt")		# load the test activity id
subj <- read.table("subject_test.txt")	# load the test subject id
colnames(testX) <- features[,2]		# set the feature names (part 4 of the courseproject)

tot_test <- cbind(subj, testY, testX)	# bind the columns together
colnames(tot_test)[1] <- "subject"		# name the first column (i.e. subject)
colnames(tot_test)[2] <- "activity"		# name the second column (i.e. activity)

rm(testX, testY,subj)				# do some garbage collection since I have limited memory
gc()

totdata <- rbind(tot_train, tot_test)	# bind the two datasets together rowwise

rm(tot_train, tot_test)				# garbage collection
gc()

# Part 2 : extract the measurements on mean and std for each measurement

# then I want to find out the column names which have info only on mean and std
# (I found this on StackOverflow from Brian Diggs)

toMatch <- c("str()","mean()")		# I want only the mean and std vars
matches <- unique(grep(paste(toMatch,collapse="|"), colnames(totdata), value=TRUE))

# now I have a list of columnnames matching "std" and "mean"
# now I need to add "subject" and "activity" to the list

allmatches <- c("subject", "activity", matches)

# now I subset the totdata dataframe containing only the columns with the columnnames in matches
subdata <- subset(totdata,select = allmatches)

# Part 3: Use descriptive activity names to name the activities in the dataset

act_labels <- read.table("activity_labels.txt")
colnames(act_labels) <- c("activity", "activity_name")	# set the name of the columns, especially the id column (for merging the two sets)

total <- merge(subdata, act_labels, by="activity")		# merge by activity id
total <- total[c("subject", "activity", "activity_name", matches)] # reorder the columns
total <- arrange(total, subject, activity)				 # sort total by subject and activity

rm(subdata, act_labels, allmatches)					# do some garbage collection since I have limited memory
gc()

# part 5: making a new tidy dataset grouped by subject and activity with means for all vars (so total 180 rows (=30 subjects x 6 activities)

# make the asked aggregation, could also have used the plyr package 
tidy <- aggregate(total[matches], by = total[c("activity_name", "subject")], FUN=mean, na.rm=TRUE)
# rearrange the columns
tidy <- tidy[c("subject", "activity_name", matches)]

# write the table to file
write.table(tidy, file = "tidy.txt", sep=",", row.names=FALSE)

