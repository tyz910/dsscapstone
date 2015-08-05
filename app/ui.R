library(shiny)

fluidPage(
  titlePanel("Word prediction"),
  
  fluidRow(
    column(4, div(br(), wellPanel(textInput('sentence', 'Input text:')))),
    column(8, h3("Suggestions:"), uiOutput('prediction'))
  )
)
