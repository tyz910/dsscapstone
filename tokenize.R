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

printNGram <- function (corpus, n = 1, topN = 15, delim = " \\r\\n\\t.!?,;\"()") {
  label <- paste('Top ', topN, ' ', n, '-grams', sep = '')
  token <- NGramTokenizer(corpus$content, Weka_control(min = n, max = n, delimiters = delim))
  top <- as.data.frame(table(token))
  top <- head(top[order(-top$Freq), ], topN)
  
  par(mar = c(5, 8, 2, 1))
  barplot(rev(top$Freq), names.arg = rev(top$token), main = label, xlab = "Frequency", horiz = TRUE, las = 1, cex.names = 0.9)
  
  return(top)
}

printNGrams <- function (corpus, num = 4, topN = 15) {
  for (n in 1:num) { 
    printNGram(corpus, n, topN)
  }
}

corpus <- getSampleCorpus(cache = TRUE)
printNGrams(corpus)
