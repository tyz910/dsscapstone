loadData <- function () {
  if (!file.exists("./data/Coursera-SwiftKey.zip")) {
    dataUrl <- "https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip"
    download.file(dataUrl, destfile = "./data/Coursera-SwiftKey.zip", method = "curl")
  }
  
  unzip("./data/Coursera-SwiftKey.zip", exdir = "./data");
}

if (!file.exists("./data")) {
  dir.create("./data")
}

if (!file.exists("./data/final")) {
  loadData()
}

readFiles <- function () {
  files <- c()
  paths <- c(
    "blogs"   = "./data/final/en_US/en_US.blogs.txt",
    "news"    = "./data/final/en_US/en_US.news.txt",
    "twitter" ="./data/final/en_US/en_US.twitter.txt"
  )
  
  for (name in names(paths)) {
    files[[name]] <- readLines(paths[name], encoding = "UTF-8", skipNul = TRUE)
  }
  
  return(files)
}

if (!exists("files")) {
  files <- readFiles()
}
