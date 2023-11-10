# sc_annotation

## Goals 
1. Automate celltype annotations process; predict celltype labels with high accuracy.
2. Remove technical variation across batches while preserving biological variation.

----- Meeting Notes -----

### 11/10/2023

#### [Review of current methods in celltype label prediction]

-- Strategy I: Integration in low-dimensional space coupled w/ Label transfer

+ Step 1: integrate across modalities/batches in low-dimentional space (PCA, CCA, aPCA, sPCA, Harmony, etc.)
+ Step 2: find MNNs in low-d space as anchors (**Note:** can also find them directly using protein expression level)
+ Step 3: label transfer using anchors, prediction.score calculated from weigted distance of query cell w/ anchors (normalized to 1)

Main reference: [link](https://www.sciencedirect.com/science/article/pii/S0092867419305598)

-- Strategy II: Direct prediction - classification task

Current methods
1. scPred [link](https://genomebiology.biomedcentral.com/articles/10.1186/s13059-019-1862-5) - SVM
2. MMoCHi [link](https://www.biorxiv.org/content/10.1101/2023.07.06.547944v1) - Random forest
3. Celltypist [link](https://www.science.org/doi/10.1126/science.abl5197) - Logistic regression

Notes
1. Feature selection is important. Dimension reduction (in scRNA-seq) is a way of feature selection. Since CITE-seq panel has way less features (~100), it might be feasible to bypass dimension reduction and use some other methods for feature selection.
2. Batch effect needs to be considered and remained challenging. If the batch effect is substantial between different datasets, then it'd impact the classifier performance trained on one labeled batch but used to predict other unlabeled batches.

-- Strategy III: NN-based approach

Popular methods include scVI [link](https://www.nature.com/articles/s41592-018-0229-2) and totalVI [link](https://www.nature.com/articles/s41592-020-01050-x) (specifically for CITE-seq data), but they are focused more on joint latent embeddings than direct celltype prediction.


#### [Results on LabelTransfer on acute-covid & covid-flu]

1. High prediction.score (from LabelTransfer) tends to correlate w/ correct predicted labels
2. Iterative LabelTransfer (removal of correctly labeled cells w/ arbitraty thresdhold of prediction.score) tends to improve prediction accuracy
3. Whether we can design hierarchical protein markers at different levels during iterative LabelTransfer


#### [Next steps]

1. Test acute-covid & covid-flu on MMoCHi
   + evalutate batch effects
   + investigate global variable importance & local variable importance in prediction
   + investigate how to calculate a `confidence.score` for each cell label prediction --> idea: concordance of label assignment in different trees

