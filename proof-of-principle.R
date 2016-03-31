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

## JENNY just proving we can now push a rendered Rmd as Google Doc

## upload metadata --> get a fileId (Drive-speak)

## DO THIS MANUALLY
## RStudio > File > New File > R Markdown
## select word doc, I guess? I'd prefer to not specify output_format
## and save it as "test.Rmd"

local_rmd_file <- "test.Rmd"
## we'll replace "word_document" with "google_document" here
local_rendered_file <-
  rmarkdown::render(local_rmd_file, output_format = "word_document")

the_body <- list(title = "test",
                 mimeType = "application/vnd.google-document")
req <- httr::POST("https://www.googleapis.com/drive/v2/files",
                  httr::config(token = google_token),
                  body = the_body, encode = "json")
rc <- jsonlite::fromJSON(httr::content(req, as = "text", encoding = "UTF-8"))
(file_id <- rc$id)

## the actual file upload
the_url <-
  file.path("https://www.googleapis.com/upload/drive/v2/files", file_id)
the_url <-
  httr::modify_url(the_url,
                   query = list(uploadType = "media", convert = TRUE))
req <- httr::PUT(the_url,
                 httr::config(token = google_token),
                 body = httr::upload_file(local_rendered_file))
rc <- jsonlite::fromJSON(httr::content(req, as = "text", encoding = "UTF-8"))
rc
## this is a suboptimal URL ... working on that
browseURL(rc$alternateLink)


## render a local Rmd
##   * it has a novel document type in the YAML
##   * leaves behind a rendered version

## upload the rendered version to Drive as Google Doc
## get a Drive fileId back



## via Google Apps script + Execution API
## attach the Rmd to the rendered Doc as a ?custom document property?

## App Script
# function saveRMarkdown(file_id, raw_r_markdown) {
#   var property = {
#     key: "raw_r_markdown",
#     value: raw_r_markdown,
#     visibility: "PUBLIC"
#   };
#
#   Drive.Properties.insert(property, file_id);
#   return "yay!!!"
# }

client_id = "768463239017-5artdq2jvia96u5r318a3a3u9mpobdm3.apps.googleusercontent.com"
client_secret = "YH4lh5tlKhktj9xJj5Zv_XD3"

scope_list =c("https://www.googleapis.com/auth/drive", "https://www.googleapis.com/auth/script.storage")
script_app = httr::oauth_app("google", key=client_id, secret=client_secret)
script_google_token = httr::oauth2.0_token(httr::oauth_endpoints("google"), script_app, scope=scope_list, cache=TRUE)

script_id = "MlxF1pCyK3ROzBb-Mg-r-u5OP2w2mNFlH"
script_url = paste0("https://script.googleapis.com/v1/scripts/", script_id, ":run")

file_name = "test.Rmd"
raw_text = readChar(file_name, file.info(file_name)$size)

body = list(
  "function"="saveRMarkdown",
  parameters=c(file_id, raw_text)
)

req = httr::POST(script_url, httr::config(token=script_google_token), body=body, encode="json")
rc = jsonlite::fromJSON(httr::content(req, as="text", encoding="UTF-8"))
rc

## retrieve the rendered Doc
## read custom document property = the Rmd source
