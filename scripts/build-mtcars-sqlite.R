args <- commandArgs(trailingOnly = TRUE)
out_dir <- if (length(args) >= 1L) args[[1L]] else "docs"
out_file <- if (length(args) >= 2L) {
    args[[2L]]
} else {
    file.path(out_dir, "mtcars.sqlite")
}

dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

if (!requireNamespace("DBI", quietly = TRUE)) {
    stop("Package 'DBI' is required")
}
if (!requireNamespace("RSQLite", quietly = TRUE)) {
    stop("Package 'RSQLite' is required")
}

mtcars <- datasets::mtcars
mtcars <- cbind(car = rownames(mtcars), mtcars)
rownames(mtcars) <- NULL

con <- DBI::dbConnect(RSQLite::SQLite(), out_file)
on.exit(DBI::dbDisconnect(con), add = TRUE)

DBI::dbWriteTable(con, "mtcars", mtcars, overwrite = TRUE)
DBI::dbExecute(con, "CREATE INDEX IF NOT EXISTS mtcars_car ON mtcars(car)")
DBI::dbExecute(con, "ANALYZE")

cat("Wrote:", normalizePath(out_file, winslash = "/", mustWork = TRUE), "\n")
