# RSQLite HTTP VFS demo DB (mtcars)

This is a tiny, reproducible GitHub Pages repository that serves a SQLite database file (`mtcars.sqlite`) over HTTPS.

It’s meant to be used with the **experimental HTTP/HTTPS VFS support** proposed in r-dbi/RSQLite PR #680.

## 1) Create the database file

From the repo root:

```sh
Rscript scripts/build-mtcars-sqlite.R docs docs/mtcars.sqlite
```

This creates:

- `docs/mtcars.sqlite`

Optionally also create a checksum:

```sh
sha256sum docs/mtcars.sqlite > docs/mtcars.sqlite.sha256
```

(Windows PowerShell alternative shown below.)

## 2) Enable GitHub Pages

In GitHub:

- **Settings → Pages**
- **Build and deployment**: Source = **Deploy from a branch**
- Branch = `main`
- Folder = `/docs`

After it publishes, your DB URL will look like:

`https://<user>.github.io/<repo>/mtcars.sqlite`

## 3) Consume from R

Install an RSQLite build that includes the HTTP VFS (PR #680). For example:

```r
# install.packages("pak")
# pak::pak("r-dbi/RSQLite#680")
```

Then connect (read-only) using the helper:

```r
library(DBI)
library(RSQLite)

url <- "https://<user>.github.io/<repo>/mtcars.sqlite"

stopifnot(sqliteHasHttpVFS())
con <- sqlite_remote(url)

dbGetQuery(con, "SELECT COUNT(*) AS n FROM mtcars")
dbGetQuery(con, "SELECT car, mpg FROM mtcars ORDER BY mpg DESC LIMIT 5")

dbDisconnect(con)
```

## Notes

- This relies on the host supporting HTTP **Range requests**. GitHub Pages generally does.
- This is **read-only** by design.

## PowerShell checksum command

```powershell
(Get-FileHash docs\mtcars.sqlite -Algorithm SHA256).Hash.ToLower() | Out-File -Encoding ascii docs\mtcars.sqlite.sha256
```
