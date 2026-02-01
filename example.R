# Example: query mtcars.sqlite hosted on GitHub Pages via RSQLite HTTP VFS

# For loading RSQLite with HTTP VFS support, you can use pak to install from the PR. Once
# the PR is merged to main you can just do install.packages("RSQLite") as usual.
# install.packages("pak")
# pak::pak("r-dbi/RSQLite#680")

library(DBI)
library(RSQLite)

url <- "https://davidrsch.github.io/rsqlite-httpvfs-example/mtcars.sqlite"

stopifnot(sqliteHasHttpVFS())
con <- sqlite_remote(url)

print(dbGetQuery(con, "SELECT COUNT(*) AS n FROM mtcars"))
print(dbGetQuery(con, "SELECT car, mpg FROM mtcars ORDER BY mpg DESC LIMIT 5"))

dbListTables(con)

if (requireNamespace("dplyr", quietly = TRUE)) {
  library(dplyr)

  mtcars_db <- tbl(con, "mtcars")
  mtcars_db |>
    filter(cyl == 6) |>
    select(car, mpg, hp) |>
    arrange(desc(mpg)) |>
    head(10) |>
    collect() |>
    print()
} else {
  message("Package 'dplyr' not installed; skipping dplyr example.")
}

dbDisconnect(con)
