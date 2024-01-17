# make sure to load the correct R in conda


# test load library
cwd = getwd()
print(cwd)

clib = .libPaths()
print(clib)

# load libraries
library(Seurat)
library(randomForest)