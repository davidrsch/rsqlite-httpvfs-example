# Example: query mtcars.sqlite hosted on GitHub Pages via RSQLite HTTP VFS

# install.packages("pak")
# pak::pak("r-dbi/RSQLite#680")

library(DBI)
library(RSQLite)

url <- "https://<user>.github.io/<repo>/mtcars.sqlite"

stopifnot(sqliteHasHttpVFS())
con <- sqlite_remote(url)

print(dbGetQuery(con, "SELECT COUNT(*) AS n FROM mtcars"))
print(dbGetQuery(con, "SELECT car, mpg FROM mtcars ORDER BY mpg DESC LIMIT 5"))

dbDisconnect(con)
