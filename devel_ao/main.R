# The main script running RF classifier training & testing & downstream analysis
# Name: Ao Huang
# Date: Jan 17 2024

### pre-configure

rm(list = ls())
setwd("~/tsang_project/sc_annotation")

set.seed(72)

library(SeuratDisk)
library(Seurat)
library(tidyverse)
library(dplyr)
library(tibble)
library(randomForest) # power RF training 
library(caret) # train test partition 
library(yardstick) # model metric
library(pheatmap)

source("./devel_ao/utils.R")
source("./devel_ao/RF_classifier.R")


### CONSOLE CONFIG

args = commandArgs(trailingOnly = TRUE)

TRAIN_DIR = args[1]
TEST_DIR  = args[2]
SAVE_DIR = args[3]
DATATYPE = args[4]

system(paste0("mkdir -p ", SAVE_DIR))

### OTHER INTERNAL CONFIG

TRAIN_TEST_SPLIT = FALSE
NUM_TREE = 200 # number of trees to include in RF
NUM_SAMPLE = 100 # number of cells per class to include in training
CELL_LABEL = 'fine' # choose from 'coarse' or 'fine' for the level of
                      # granularity of celltype annotation
                      # the 'coarse' level doesn't have maps yet
LABEL_TRANS = FALSE # there's other conceptual problem associated
                    # -- still under devel
DOWNSAMPLE = FALSE  # whether downsample to some cell numbers for faster training
IMBALANCE = FALSE  # boolean input. if TRUE, deal with the class imbalance problem


### load & preprocess data

cat('\n----- Load & Preprocess data -----\n')

# Read in data
# tryCatch (
#     {
#         train_obj = LoadH5Seurat(TRAIN_DIR, verbose = FALSE)
#         test_obj  = LoadH5Seurat(TEST_DIR, verbose = FALSE)
#     },
#     error=function(){
#         message('The input file is not in h5Seurat format')
#         message('try readRDS instead')
        train_obj = readRDS(TRAIN_DIR)
        test_obj  = readRDS(TEST_DIR)
#    }
#)

# Specify features to include 
selected_features = rownames(train_obj)

# Preprocess data
TRAIN = data_preprocess(seurat_obj = train_obj,
                       features = selected_features,
                       cell_label = CELL_LABEL,
                       input_type = DATATYPE)

TEST = data_preprocess(seurat_obj = test_obj,
                       features = selected_features,
                       cell_label = CELL_LABEL,
                       input_type = DATATYPE)


### Include label transfer information

cat('\n----- LABEL TRANSFER Included =', LABEL_TRANS,'-----\n')

if (LABEL_TRANS == TRUE) {
    # -- still under devel
}


### Downsampling - FOR FASTER TRAINING

cat('\n----- DOWNSAMPLE considered =', DOWNSAMPLE,'-----\n')

if (DOWNSAMPLE) {
    TRAIN = TRAIN %>% group_by(cell_type) %>% slice_sample(n=NUM_SAMPLE, replace=TRUE)
}

# this is merely for faster testing
#TEST = TEST %>% group_by(cell_type) %>% slice_sample(n=NUM_SAMPLE, replace=TRUE)

# for class with samples less than NUM_SAMPLE, sample with replacement to hit that number


### Class Imbalance
# -- simple solution: oversampled to NUM_SAMPLE per class
# other sols: use imbalance package
# debate over imbalance prob: https://www.reddit.com/r/MachineLearning/comments/v3swj7/d_class_imbalance_overunder_sampling_and_class/

cat('\n----- IMBALANCE considered =', IMBALANCE,'-----\n')

if (IMBALANCE) {
    # -- still under devel
}


### Train test split (Optional)

cat('\n----- Train-Test-Split =', TRAIN_TEST_SPLIT,'-----\n')

if (TRAIN_TEST_SPLIT) {
    train_idx = createDataPartition(TRAIN$cell_type, p=.8, list=FALSE)
    TRAIN = data[train_idx,]
    TEST = data[-train_idx,]
}

cat('\n ----- Display TRAIN, TEST before training ----\n')

cat('-- head TRAIN\n')
head(TRAIN[,1:3],3)

cat('-- head TEST\n')
head(TEST[,1:3],3)

cat('-- disp celltype\n')
table(TRAIN$cell_type)
table(TEST$cell_type)

cat('TRAIN dim:\n')
print(dim(TRAIN))

cat('TEST dim:\n')
print(dim(TEST))


### Train RF classifier

cat('\n----- TRAIN RF classifier -----\n')

toc = Sys.time()

model = RF_classifier(TRAIN, ntree = NUM_TREE)

tic = Sys.time()

cat('Time Spent:\n')
print(tic-toc)

cat('\nModel Summary:\n')
print(model)

cat('\n -- saving model --\n')

# create saving name
library(stringr)
train_info = str_split(TRAIN_DIR, pattern='/', simplify=TRUE)
test_info  = str_split(TEST_DIR, pattern='/', simplify=TRUE)

save_dir = paste0(SAVE_DIR, '/', train_info, '-', test_info, '-', DATATYPE, '.RDS')
saveRDS(model, save_dir)


### Test/Pred RF classifier 

# consider do testing in another script

cat('\n----- TEST RF classifier -----\n')

#probs <- predict(model, TEST, 'prob')
class <- predict(model, TEST, 'raw')
TEST.scored = data.frame(cell_type = TEST$cell_type,
                         class = class)


cat('TEST.scored matrix examine: \n')
head(TEST.scored, 5)
dim(TEST.scored)

cm <- conf_mat(data = TEST.scored,
               truth = cell_type,
               estimate = class)
cat('Test summary:\n')
summary(cm)


cat('\n----- Analysis FINISHED -----\n')

                       
