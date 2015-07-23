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

barplot(files_stat[, "Lines"], names.arg = row.names(files_stat), main = "Line counts")
barplot(files_stat[, "Words"], names.arg = row.names(files_stat), main = "Word counts")