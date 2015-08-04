source("prediction.R")
library(shiny)

function(input, output) {
  output$prediction <- renderText({
    predict(input$sentence)
  })
}
