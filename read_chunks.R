library("RWeka")
library("tm")

if (!file.exists("./data/cache")) {
  dir.create("./data/cache")
}

filePaths <- c(
  "blogs"   = "./data/final/en_US/en_US.blogs.txt",
  "news"    = "./data/final/en_US/en_US.news.txt",
  "twitter" = "./data/final/en_US/en_US.twitter.txt"
)

chunkSizes <- c(
  "blogs"   = 10000,
  "news"    = 10000,
  "twitter" = 30000
)

getCorpus <- function (data) {
  corpus <- Corpus(VectorSource(data))
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, tolower)
  corpus <- tm_map(corpus, stripWhitespace)

  return(corpus)
}

readChunks <- function (name, num) {
  f <- file(filePaths[[name]], "r")

  for (chunkNum in 1:num) {
    print(paste("Chunk", name, chunkNum))
    text <- readLines(f, n = chunkSizes[[name]], encoding = "UTF-8", skipNul = TRUE)
    cacheFile <- paste("./data/cache/", name, "-", chunkNum, ".RDS", sep = '')

    if (!file.exists(cacheFile)) {
      corpus <- getCorpus(text)
      data <- c()
      for (tokenNum in 1:4) {
        print(paste("Calculate", tokenNum, "grams"))
        tokens <- NGramTokenizer(corpus$content, Weka_control(min = tokenNum, max = tokenNum, delimiters = " \\r\\n\\t.!?,;\"()"))
        data[[tokenNum]] <- as.data.frame(table(tokens))
      }

      saveRDS(data, file = cacheFile)
    }
  }
  
  close(f)
}

readChunks("news", 10)
readChunks("blogs", 10)
readChunks("twitter", 10)