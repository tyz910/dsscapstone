library("RWeka")
library("tm")
set.seed(123)

createSample <- function (blogs, news, twitter) {
  samples <- c()

  for (name in names(files)) {
    file <- files[[name]]
    samples <- c(samples, sample(file, get(name)))
  }
  
  return(samples)
}

getCorpus <- function (data) {
  corpus <- Corpus(VectorSource(data))
  corpus <- tm_map(corpus, tolower)
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, removeNumbers)

  return(corpus)
}

getSampleCorpus <- function (blogs = 10000, news = 1000, twitter = 50000, cache = TRUE) {
  cacheFile <- "./data/sample_corpus.RDS"
  if (cache && file.exists(cacheFile)) {
    corpus <- readRDS(cacheFile)
  } else {
    samples <- createSample(blogs, news, twitter)
    corpus <- getCorpus(samples)
    saveRDS(corpus, file = "./data/sample_corpus.RDS")
  }

  return(corpus)
}

printNGrams <- function (corpus) {
  delim <- " \\r\\n\\t.!?,;\"()"
  topN <- 15
  for (i in 1:4) {
    label <- paste('Top ', topN, ' ', i, '-grams', sep = '')
    token <- NGramTokenizer(corpus$content, Weka_control(min = i, max = i, delimiters = delim))
    top <- as.data.frame(table(token))
    top <- head(top[order(-top$Freq), ], 15)
    print(label)
    print(top)
  }
}

corpus <- getSampleCorpus(cache = TRUE)
printNGrams(corpus)
