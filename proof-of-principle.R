scope_list <- c("https://www.googleapis.com/auth/drive",
                "https://www.googleapis.com/auth/script.storage")
key <-
  "178989665258-f4scmimctv2o96isfppehg1qesrpvjro.apps.googleusercontent.com"
secret <- "iWPrYg0lFHNQblnRrDbypvJL"
googlestuff_app <- httr::oauth_app("google", key = key, secret = secret)
google_token <-
  httr::oauth2.0_token(httr::oauth_endpoints("google"), googlestuff_app,
                       scope = scope_list, cache = TRUE)

## now drop this into any future httr calls:
## httr::config(token = google_token)

## render a local Rmd
##   * it has a novel document type in the YAML
##   * leaves behind a rendered version

## upload the rendered version to Drive as Google Doc
## get a Drive fileId back

## via Google Apps script + Execution API
## attach the Rmd to the rendered Doc as a ?custom document property?

## retrieve the rendered Doc
## read custom document property = the Rmd source
