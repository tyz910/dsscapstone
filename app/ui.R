library(shiny)

fluidPage(
  titlePanel("Prediction"),
  
  sidebarPanel(
    textInput('sentence', 'Text')
  ),

  mainPanel(
    textOutput('prediction')
  )
)