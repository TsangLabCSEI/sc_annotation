# the main script running RF classifier training & testing & downstream analysis
# Name: Ao Huang
# Date: Jan 17 2024

### pre-configure

rm(list = ls())
setwd("~/tsang_project/sc_annotation")

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


### Console input

DATA_DIR = "./data/sorted_cells.adt.raw.h5Seurat"
DATATYPE = "expr"
TRAIN_TEST_SPLIT = TRUE
SAVE_DIR = "./devel_ao/models"


### load & perprocess data

cat('\n----- Load & Preprocess data -----\n')

seurat_obj = LoadH5Seurat(DATA_DIR, verbose = FALSE)

# specify features to include 
DefaultAssay(seurat_obj) = 'CITE'
selected_features = rownames(seurat_obj) # might be overlapped features between train & pred

# specify celltypes
cell_type = seurat_obj$cell.type

# extract expr data
data = data_preprocess(seurat_obj = seurat_obj,
                       features = selected_features,
                       cell_label = cell_type,
                       input_type = DATATYPE)
head(data[,1:5],5)


### Downsampling - FOR TESTING

data = data[sample(1:nrow(data), 500), ]


### Train test split (Optional)

cat('\n----- Train-Test-Split = ', TRAIN_TEST_SPLIT,'-----\n')

if (TRAIN_TEST_SPLIT) {
    train_idx = createDataPartition(data$cell_type, p=.8, list=FALSE)
    TRAIN = data[train_idx,]
    TEST = data[-train_idx,]
} else {
    TRAIN = data
    #TEST = test_data
}

cat('TRAIN dim:\n')
print(dim(TRAIN))

cat('TEST dim:\n')
print(dim(TEST))


### Train RF classifier

cat('\n----- TRAIN RF classifier -----\n')

toc = Sys.time()
model = RF_classifier(TRAIN)
tic = Sys.time()

cat('Time Spent:\n')
print(tic-toc)

cat('\nModel Summary:\n')
print(model)


### Test/Pred RF classifier 

cat('\n----- TEST RF classifier -----\n')

probs <- predict(model, TEST, 'prob')
class <- predict(model, TEST, 'raw')
TEST.scored <- cbind(TEST, probs, class)

cm <- conf_mat(TEST.scored, truth = cell_type, class)
cat('Test summary:\n')
summary(cm)


### save model

saveRDS(model, 
        paste0(SAVE_DIR,'/rf_model-',DATATYPE))

cat('\n----- Analysis FINISHED -----\n')

                       