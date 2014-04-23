Codebook for run_analysis.R
=============================

*Programming Assignment for Coursera Course "Getting and Cleaning Data"*

# General
### Variable names
* All variables containing data start with "dat."
  + The second part of data variables signify the origin ".test.",".train." or ".all." for the combined (test+train) dataset
* Metadata (to the test/train data) is loaded into variables staring with "ref." (reference)

### Required data

The Script expects to be run in a working directory which contains a subfolder "UCI HAR Dataset" with the unzipped data files. (See "UCI HAR Dataset/README.txt" for further information)

# Task1: Merging the data
### Merge the training and the test sets to create one data set

### Reading Metadata files
```{r}
ref.activity<-read.table(".//UCI HAR Dataset//activity_labels.txt", header=FALSE)
ref.features<-read.table(".//UCI HAR Dataset//features.txt", header=FALSE)
```
Gives the Activity Labels (in Variable ref.activity) and the Features (=Variable names) (in Variable ref.features).

### Reading Data Files

Reading in the training data and the related subject information:
```{r}
# Read in Training Data
dat.train.subject<-read.table(".//UCI HAR Dataset//train//subject_train.txt", header=FALSE)
dat.train.y<-read.table(".//UCI HAR Dataset//train//y_train.txt", header=FALSE)
dat.train.x<-read.table(".//UCI HAR Dataset//train//X_train.txt", quote="\"")
```

Then adding names to the variables of "dat.train.x" taken from ref.features:
```{r}
## Naming the variables
colnames(dat.train.x) <- ref.features[,2] 
```

Adding a variable to indicate the origin of the data (not asked for here, but hopefully useful later):
```{r}
## Add identifier for data Origin (training data) 
dat.train.x$origin<-rep('train',dim(dat.train.x)[1])
```

Finally adding the Subject IDs to the data set:
```{r}
## Add Subjects identifier
dat.train.x<-cbind(dat.train.x,dat.train.subject)
colnames(dat.train.x)[563]<-"SubjectID"
```

All steps described in this section for the training data are then repeated for the test data. The code is the same, only all appearences of "train" in variable names, file names, etc. are replaces by "test":

```{r}
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
```

Finally the two tables are merged together: 

```{r}
dat.all.x=rbind(dat.train.x, dat.test.x)
```

# Task2: Variable Selection
### Extract only the measurements on the mean and standard deviation for each measurement

The variable names of the variables containing **mean** or **standard deviation** values are retrieved by using grep:

```{r}
ref.vars.mean<-grep("mean",colnames(dat.train.x))
ref.vars.std<-grep("std",colnames(dat.train.x))
```

And then a new smaller data set is created using only these variables plus the additional variables "origin" and "SubjectID" (variables nr.562 and nr.563):
```{r}
dat.allms.x<-dat.all.x[,sort(c(ref.vars.std, ref.vars.mean, 562:563))]
```

# Task3: Descriptive names
### Use descriptive activity names to name the activities in the data set

The names given to the activities in the file 'activity_labels.txt': 

    1            WALKING
    2   WALKING_UPSTAIRS
    3 WALKING_DOWNSTAIRS
    4            SITTING
    5           STANDING
    6             LAYING

are in my opinion descriptive enough. So they are sufficient to be used here.

So after combining the numeric labels from training and test data they are replaced (using a function 'actlabel') with the non-numeric descriptions:

```{r}
dat.all.y<-rbind(dat.train.y, dat.test.y)    # All Labels (train + test)
actlabel<-function(i) {x<-ref.activity[i,2]}
dat.all.ys<-sapply(dat.all.y, actlabel)
```

# Task4: Label data
### Appropriately labels the data set with descriptive activity names. 

Now these non-numeric labels for the activities are added as a new column to the data set and the column is named "Activity":

```{r}
dat.allms.x<-cbind(dat.allms.x,dat.all.ys)
colnames(dat.allms.x)[82]<-"Activity"
```

# Task5: Tidy data
### Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 

First the data are reshaped by using "Activity" and "SubjectID" as new ID variables:
```{r}
tmp<-melt(dat.allms.x, id=c("Activity","SubjectID"),
         measure.vars=names(dat.allms.x)[1:79], na.rm = TRUE)
```       

Then the data is summarized, using the Mean-Function:

```{r}
dat.tidy<-acast(tmp, formula = Activity+SubjectID ~ variable, mean)
write.table(dat.tidy, "tidy_dataset.txt", sep=",")
```








