library("RSQLite")
library("tm")

this.dir <- dirname(parent.frame(2)$ofile)
setwd(this.dir)

con <- dbConnect(SQLite(), dbname = "dictionary.sqlite")

getLastWords <- function (sentence, n = 1) {
  sentence <- stripWhitespace(sentence)
  words <- strsplit(sentence, " ")
  tail(words[[1]], n)
}

substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}

findTokens <- function (sentence, num = 1, limit = 25) {
  #print(paste(sentence, num, sep = ", "))
  
  dbGetQuery(con, paste("select * from tokens", num, " WHERE token LIKE '", sentence, "%' ORDER BY num DESC LIMIT ", limit, sep = ""))
}

predict <- function (sentence, maxSuggestions = 10) {
  sentence <- removePunctuation(sentence)
  sentence <- removeNumbers(sentence)
  sentence <- tolower(sentence)
  
  blank <- substrRight(sentence, 1)
  if (blank != " ") {
    blank = ""
    words <- getLastWords(sentence, 4)
  } else {
    words <- getLastWords(sentence, 3)
  }

  len <- length(words)
  if (blank == " ") {
    len <- len + 1
  }
  
  if (!len) {
    return(c())
  }

  suggestions <- c()

  repeat {
    tokens <- findTokens(paste(paste(words, collapse = " "), blank, sep = ""), num = len)
    suggestions <- unique(c(suggestions, apply(tokens, 1, function (row) {
      getLastWords(as.character(row[1]))
    })))
    
    if ((length(suggestions) >= maxSuggestions) || len == 1) {
      break
    } else {
      len <- len - 1
      words <- words[2:length(words)]
    }
  }

  return(head(suggestions, maxSuggestions))
}