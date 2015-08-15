library("RSQLite")

this.dir <- dirname(parent.frame(2)$ofile)
setwd(this.dir)

getCon <- function (clear = FALSE) {
  base <- "app/dictionary.sqlite"

  if (clear && file.exists(base)) {
    unlink(base)
  }
  
  if (clear && file.exists("./data/locks")) {
    unlink("./data/locks", recursive = TRUE)
  }
  
  if (!file.exists("./data/locks")) {
    dir.create("./data/locks")
  }
  
  con <- dbConnect(SQLite(), dbname = "app/dictionary.sqlite")
  
  if (clear) {
    for (tokenNum in 1:4) {
      dbSendQuery(con, paste("CREATE TABLE tokens", tokenNum, " (token VARCHAR NOT NULL PRIMARY KEY ASC, num INTEGER NOT NULL)", sep = ""))
      dbSendQuery(con, paste("CREATE INDEX tokens", tokenNum, "_num_idx ON tokens", tokenNum, " (num)", sep = ""))
    }
  }
  
  con
}

con <- getCon(FALSE)

loadChunk <- function (name, chunkNum, minFreq = 1, nNums = 1:4) {
  cacheFile <- paste("./data/cache/", name, "-", chunkNum, ".RDS", sep = '')
  data <- readRDS(cacheFile)
  for (tokenNum in nNums) {
    print(paste(name, chunkNum, tokenNum))
    
    lockFile <- paste("./data/locks/", name, "-", chunkNum, "-", tokenNum, ".lock", sep = '')
    if (!file.exists(lockFile)) {
      file.create(lockFile)
      
      apply(data[[tokenNum]], 1, function (row) {
        token <- as.symbol(row[1])
        freq <- as.integer(row[2])
        print(paste(token, freq))
        if (freq >= minFreq) {
          dbSendQuery(con, paste("INSERT OR IGNORE INTO tokens", tokenNum, " VALUES ('", token, "', 0)", sep = ""))
          dbSendQuery(con, paste("UPDATE tokens", tokenNum, " SET num = num + ", freq, " WHERE token = '", token, "'", sep = ""))
        }
      })
    }
  }
}

#loadChunk ("news", 1, minFreq = 2)
#loadChunk ("twitter", 1, minFreq = 2)
#loadChunk ("blogs", 1, minFreq = 2)

#loadChunk ("twitter", 2, minFreq = 1, nNums = 3:3)
#loadChunk ("blogs", 2, minFreq = 1, nNums = 3:3)
#loadChunk ("news", 2, minFreq = 1, nNums = 3:3)

#loadChunk ("twitter", 3, minFreq = 1, nNums = 3:3)
#loadChunk ("blogs", 3, minFreq = 1, nNums = 3:3)
#loadChunk ("news", 3, minFreq = 1, nNums = 3:3)

#dbSendQuery(con, "DELETE FROM tokens3 WHERE num < 2")
#dbSendQuery(con, "VACUUM")

