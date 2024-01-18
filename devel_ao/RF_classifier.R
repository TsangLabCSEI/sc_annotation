# This script defines the random forest classifer with configurations in train-
# test split, cross validation and training
# Name: Ao Huang
# Date: Jan 17 2024

RF_classifier = function (expr_df, ntree) {
    # Returns the RF model that's trained with input data
    # 
    # Parameter expr_df: a cell-by-(feature+cell_type) data frame
    # Preconditions: cell-by-feature entries are floats, cell_type entries are 
    # factors
    # 
    # Parameter ntree: number of trees used in RF model
    # Preconditions: an integer

    ## load libraries
    library(randomForest)
    library(caret)

    ## control training 
    train_ctrl = trainControl(method = 'cv',
                              number = 5,
                              search = 'random')

    ## train RF classifier
    model = train(cell_type ~ .,
                  data = expr_df,
                  method = 'rf', # use randomForest::randomForest
                  metric = 'Accuracy',
                  trControl = train_ctrl,
                  # options to pass to RF
                  ntree = ntree,
                  keep.forest = TRUE,
                  importance = TRUE)

    return(model)

}