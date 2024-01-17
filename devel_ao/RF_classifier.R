# This script defines the random forest classifer with configurations in train-
# test split, cross validation and training
# Name: Ao Huang
# Date: Jan 17 2024

RF_classifier = function (expr_df) {
    # Returns the RF model that's trained with input data
    # 
    # Parameter expr_df: a cell-by-(feature+cell_type) data frame
    # Preconditions: cell-by-feature entries are floats, cell_type entries are 
    # factors

    ## load libraries
    library(randomForest)
    library(caret)

    ## control training 
    train_ctrl = trainControl(method = 'cv',
                              number = 10,
                              search = 'random')

    ## train RF classifier
    model = train(cell_type ~ .,
                  data = expr_df,
                  method = 'rf', # use randomForest::randomForest
                  metric = 'Accuracy',
                  trControl = train_ctrl,
                  # options to pass to RF
                  ntree = 200,
                  keep.forest = TRUE,
                  importance = TRUE)

    return(model)

}