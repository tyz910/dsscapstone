library("RSQLite")

getLastWords <- function (sentence, n = 1) {
  # todo clean?
  words <- strsplit(sentence, " ")
  tail(words[[1]], n)
}

predict <- function (sentence) {
  last <- getLastWords (sentence, 4)

  tail(last, 1)
}
