source("prediction.R")
library(shiny)

function(input, output) {
  output$prediction <- renderUI({
    HTML(paste("<ul>", paste(lapply(predict(input$sentence), function (word) {
      paste('<li>', word, '</li>')
    }), collapse = " "), "</ul>"))
  })
}
