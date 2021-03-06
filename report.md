# Data Science Capstone: Milestone Report

## Synopsis

In this report we perform exploratory analysis of the training data for the Courcera Data Science Capstone Project. We evaluate basic summaries of the data such as word and line counts. We build figures and tables to understand distribution of words, variation in the frequencies of words and word pairs in the data.

## Loading training data

Download training data from [Courcera site](https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip). Files stored in zip archive, unzip it.

```r
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
```

There are 4 folders after unzipping.

```r
list.files("./data/final")
```

```
## [1] "de_DE" "en_US" "fi_FI" "ru_RU"
```

Each folder contains 3 files for specific language.

```r
list.files("./data/final/en_US")
```

```
## [1] "en_US.blogs.txt"   "en_US.news.txt"    "en_US.twitter.txt"
```

## Files analysis

We use english files for analysis. First we read the files.

```r
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
```

Calculate word and line counts.

```r
library(stringi)

getFileStats <- function () {
  files_stat <- NULL
  
  for (name in names(files)) {
    file <- files[[name]]
    stats <- stri_stats_general(file)
    data <- data.frame(t(stats), row.names = name)
    data$Words <- sum(stri_count_words(file))

    if (is.null(files_stat)) {
      files_stat <- data
    } else {
      files_stat <- rbind(files_stat, data)
    }
  }
  
  return(files_stat)
}

files_stat <- getFileStats()
files_stat
```

```
##           Lines LinesNEmpty     Chars CharsNWhite    Words
## blogs    899288      899288 206824382   170389539 37546246
## news    1010242     1010242 203223154   169860866 34762395
## twitter 2360148     2360148 162096241   134082806 30093410
```

Plot graphs.

```r
barplot(files_stat[, "Lines"], names.arg = row.names(files_stat), main = "Line counts")
```

![](report_files/figure-html/files_stat_graph-1.png) 

```r
barplot(files_stat[, "Words"], names.arg = row.names(files_stat), main = "Word counts")
```

![](report_files/figure-html/files_stat_graph-2.png) 

News and blogs data have similar word and lines count. Twitter data have more lines with similar word count - result of Twitter limitation to message size and microblog nature of text.

## N-gram analysis

For N-gram analysis we create sample set contains 1000 lines from news, 10000 lines from blogs and 50000 lines from twitter.

```r
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

corpus <- getSampleCorpus(cache = TRUE)
```

Calculate and plot top 15 tokens from 1-grams to 4-grams.

```r
library("RWeka")

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

printNGrams(corpus)
```

![](report_files/figure-html/tokens_plot-1.png) ![](report_files/figure-html/tokens_plot-2.png) ![](report_files/figure-html/tokens_plot-3.png) ![](report_files/figure-html/tokens_plot-4.png) 

We found most common words and word pairs in english. This data will be used to make a prediction model.

## Plans

Use found n-grams to make a prediction model(possibly Katz's back-off model). Use prediction model to create Shiny app.
