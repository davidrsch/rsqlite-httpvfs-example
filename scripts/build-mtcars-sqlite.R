args <- commandArgs(trailingOnly = TRUE)

# Backwards-compatible positional args:
#   1) out_dir
#   2) out_file
#   3) sha256_file (optional)
out_dir <- if (length(args) >= 1L) args[[1L]] else "docs"
out_file <- if (length(args) >= 2L) {
    args[[2L]]
} else {
    file.path(out_dir, "mtcars.sqlite")
}
sha256_file <- if (length(args) >= 3L) args[[3L]] else NA_character_

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

invisible(DBI::dbWriteTable(con, "mtcars", mtcars, overwrite = TRUE))
invisible(DBI::dbExecute(
    con,
    "CREATE INDEX IF NOT EXISTS mtcars_car ON mtcars(car)"
))
invisible(DBI::dbExecute(con, "ANALYZE"))

cat("Wrote:", normalizePath(out_file, winslash = "/", mustWork = TRUE), "\n")

if (!is.na(sha256_file) && nzchar(sha256_file)) {
    if (!requireNamespace("openssl", quietly = TRUE)) {
        stop(
            "To write a SHA256 file from R, install the 'openssl' package, e.g. install.packages('openssl').\n",
            "Alternatively compute it with sha256sum (Linux/macOS) or Get-FileHash (PowerShell)."
        )
    }

    sha256_formals <- names(formals(openssl::sha256))
    if (!is.null(sha256_formals) && "file" %in% sha256_formals) {
        hash_raw <- openssl::sha256(file = out_file)
    } else {
        size <- as.integer(file.info(out_file)$size)
        f <- file(out_file, open = "rb")
        on.exit(close(f), add = TRUE)
        data <- readBin(f, what = "raw", n = size)
        hash_raw <- openssl::sha256(data)
    }
    hash_hex <- paste(sprintf("%02x", as.integer(hash_raw)), collapse = "")
    writeLines(hash_hex, sha256_file, useBytes = TRUE)
    cat(
        "Wrote:",
        normalizePath(sha256_file, winslash = "/", mustWork = TRUE),
        "\n"
    )
}
