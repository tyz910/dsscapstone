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

file_stats <- getFileStats()
