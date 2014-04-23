
# Libraries
library(reshape2)

# Set working directory
#setwd("H:\\Dropbox\\07_Exzerpte_CS\\+R\\getdata-002-RScripte\\Assignment")

# Read in Metadata tables
ref.activity<-read.table(".//UCI HAR Dataset//activity_labels.txt", header=FALSE)
ref.features<-read.table(".//UCI HAR Dataset//features.txt", header=FALSE)

# Read in Training Data
dat.train.subject<-read.table(".//UCI HAR Dataset//train//subject_train.txt", header=FALSE)
dat.train.y<-read.table(".//UCI HAR Dataset//train//y_train.txt", header=FALSE)
dat.train.x<-read.table(".//UCI HAR Dataset//train//X_train.txt", quote="\"")
## Naming the variables
colnames(dat.train.x) <- ref.features[,2] 
## Add identifier for data Origin (training data) 
dat.train.x$origin<-rep('train',dim(dat.train.x)[1])
## Add Subjects identifier
dat.train.x<-cbind(dat.train.x,dat.train.subject)
colnames(dat.train.x)[563]<-"SubjectID"

# Read in Test Data
dat.test.subject<-read.table(".//UCI HAR Dataset//test//subject_test.txt", header=FALSE)
dat.test.y<-read.table(".//UCI HAR Dataset//test//y_test.txt", header=FALSE)
dat.test.x<-read.table(".//UCI HAR Dataset//test//X_test.txt", quote="\"")
## Naming the variables
colnames(dat.test.x) <- ref.features[,2] 
## Add identifier for data Origin (training data) 
dat.test.x$origin<-rep('test',dim(dat.test.x)[1])
## Add Subjects identifier
dat.test.x<-cbind(dat.test.x,dat.test.subject)
colnames(dat.test.x)[563]<-"SubjectID"


# Task1.Merge the training and the test sets to create one data set.
dat.all.x=rbind(dat.train.x, dat.test.x)

# Task 2.Extracts only the measurements on the mean and standard deviation for 
#        each measurement.
ref.vars.mean<-grep("mean",colnames(dat.train.x))
ref.vars.std<-grep("std",colnames(dat.train.x))
dat.allms.x<-dat.all.x[,sort(c(ref.vars.std, ref.vars.mean, 562:563))]

# Task3.Uses descriptive activity names to name the activities in the data set
dat.all.y<-rbind(dat.train.y, dat.test.y)    # All Labels (train + test)
actlabel<-function(i) {x<-ref.activity[i,2]}
dat.all.ys<-sapply(dat.all.y, actlabel)

# Task4.Appropriately labels the data set with descriptive activity names. 
dat.allms.x<-cbind(dat.allms.x,dat.all.ys)
colnames(dat.allms.x)[82]<-"Activity"

# Task5.Creates a second, independent tidy data set with the average of 
#       each variable for each activity and each subject. 
tmp<-melt(dat.allms.x, id=c("Activity","SubjectID"),
         measure.vars=names(dat.allms.x)[1:79], na.rm = TRUE)
dat.tidy<-acast(tmp, formula = Activity+SubjectID ~ variable, mean)
write.table(dat.tidy, "tidy_dataset.txt", sep=",")

