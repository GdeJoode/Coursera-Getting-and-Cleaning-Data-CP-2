Readme file on Course Project 2 for the Getting and Cleaning Data course on Coursera

This readme file containt the routine I used for getting and cleaning the dataset given into a tidy dataset. Steps are
also explained in the scriptfile "Run_Analysis.R". I try to use the R base as much as possible. 

Make sure the dyplr package is loaded nonetheless.

I do not follow the steps of the assignment sequentially as noted below:

I first do steps 1 and 4 : reading the datasets, merging them, and apply descriptive column names

Put all the datafiles in the working directory of this script!!

# Part 1 and 4 of CP: First we load the datasets and merge them together using cbind and rbind

step 1: load the datasets : features, X_train, Y_train, subject_train
step 2: assign the second column of the features dataset to the columnnames of X_train
step 3: cbind() the Y_train and subject_train to X_train to obtain the complete training dataset stored in tot_train dataframe

step 4: repeat this procedure for the _test dataset into the tot_test dataframe

step 5: rbind() the tot_train and tot_test into the totdata dataset

step 6: filter out the colums with measurements on mean() and std(), by using grep() and unique() to get a list of columnnames
Since the mean() and std() columns do not have duplicate columnnames this is no problem

toMatch <- c("str()","mean()")		# I want only the mean and std vars
matches <- unique(grep(paste(toMatch,collapse="|"), colnames(totdata), value=TRUE))

step 7: add "subject" and "activity" to the columnname list, which I need for subsetting the data

allmatches <- c("subject", "activity", matches)

Step 8: subset the totdata dataframe containing only the columns with the columnnames in matches
subdata <- subset(totdata,select = allmatches)

# Part 3: Use descriptive activity names to name the activities in the dataset

Step 9: read the activity_labels file and merge with the subset dataframe. 
act_labels <- read.table("activity_labels.txt")
colnames(act_labels) <- c("activity", "activity_name")	
total <- merge(subdata, act_labels, by="activity")		

Step 10: reorder the columns and sort the dataframe
total <- total[c("subject", "activity", "activity_name", matches)] 
total <- arrange(total, subject, activity)				 

# part 5: making a new tidy dataset grouped by subject and activity with means for all vars (so total 180 rows (=30 subjects x 6 activities)

Step 11: make the asked aggregation, could also have used the plyr package 
tidy <- aggregate(total[matches], by = total[c("activity_name", "subject")], FUN=mean, na.rm=TRUE)
# rearrange the columns
tidy <- tidy[c("subject", "activity_name", matches)]

Step 12: write the table to file
write.table(tidy, file = "tidy.txt", sep=",", row.names=FALSE)
