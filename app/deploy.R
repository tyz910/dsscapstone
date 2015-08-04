library(shinyapps)
this.dir <- dirname(parent.frame(2)$ofile)
setwd(this.dir)
deployApp(appName = "predict")