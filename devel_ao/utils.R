# This script defines functions to preprocess data in correct formats for 
# training the random forest classifier
# Name: Ao Huang
# Date: Jan 17 2024

data_preprocess = function (seurat_obj, features, cell_label='fine',
                            input_type = 'expr') {
    # Returns a cell-by-feature dataframe plus another column that contains
    # cell labels, ready for classifier training
    # 
    # Parameter seurat_obj: a Seurat object
    # Preconditions: it contains a cell-level metadata specifying celltypes
    # 
    # Parameter features: a vector of feature names of type character
    # 
    # Parameter cell_label: specify the granularity of celltype annotation
    # Preconditions: choose from 'fine' or 'coarse'
    # 
    # Parameter input_type: specifying the normalization method to data
    # Preconditions: choose from "expr" (dsb-normalized expr) or "rank"
    # (MinMax-normalized after ranking)

    ## load libraries
    library(tidyverse)
    library(tibble)
    library(dplyr) 

    ## extract expr matrix
    expr_matrix = t(as.matrix(seurat_obj@assays$CITE@data)) # contains normalized data
    expr_df = data.frame(expr_matrix)
    
    ## if requires rank
    if (input_type == 'rank') {
        rank_matrix = t(apply(expr_matrix, 1, 
                              function (x) {rank(x,ties.method="average")} ))
        
        # MinMax normalize each row  between 0 & 1
        # rank_matrix = t(apply(rank_matrix), 1,
        #                 function (x) {(x-min(x)) / (max(x)-min(x))})

        expr_df = data.frame(rank_matrix)
    }

    ## add cell_label
    if (cell_label == 'coarse') {
        celltype = seurat_obj$coarse.cell.type
    } else if (cell_label == 'fine') {
        celltype = seurat_obj$cell.type
    }
    expr_df = mutate(expr_df, cell_type = factor(celltype))

    ## return data matrix
    return(expr_df)

}
