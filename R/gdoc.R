.app <- new.env(parent = emptyenv())
.app$client_id <-
  "768463239017-5artdq2jvia96u5r318a3a3u9mpobdm3.apps.googleusercontent.com"
.app$script_id <- "MlxF1pCyK3ROzBb-Mg-r-u5OP2w2mNFlH"
.app$client_secret <- "YH4lh5tlKhktj9xJj5Zv_XD3"
.app$scopes <- c("https://www.googleapis.com/auth/drive",
                 "https://www.googleapis.com/auth/documents",
                 "https://www.googleapis.com/auth/script.storage")
.app$app <- httr::oauth_app("google", key = .app$client_id,
                            secret = .app$client_secret)
#' @export
gd_auth <- function() {
  invisible(httr::oauth2.0_token(httr::oauth_endpoints("google"),
                                 .app$app, scope = .app$scopes, cache = TRUE))
}

#' @export
#' @import httr jsonlite rmarkdown
gdoc <- function(template = NULL, token = NULL,
                 keep_md = FALSE, clean_supporting = TRUE,
                 verbose = TRUE, browse = TRUE) {

  if (is.null(token)) {
    token <- gd_auth()
  }
  if (is.null(template)) {
    template = system.file("template.docx", package = "googlestuff")
  }
  output_format(
    knitr = knitr_options(),
    pandoc = pandoc_options(to = "docx"),
    keep_md = keep_md,
    clean_supporting = clean_supporting,
    post_processor = function(metadata, input_file, output_file, clean, verbose) {
      if (is.null(metadata$title)) {
        title = "Test"
      } else {
        title = metadata$title
      }
      the_body <- list(title = title,
                       mimeType = "application/vnd.google-apps.document")
      req <- httr::POST("https://www.googleapis.com/drive/v2/files",
                        httr::config(token = token),
                        body = the_body, encode = "json")
      rc <- jsonlite::fromJSON(httr::content(req, as = "text", encoding = "UTF-8"))
      file_id <- rc$id

      the_url <-
        file.path("https://www.googleapis.com/upload/drive/v2/files", file_id)
      the_url <-
        httr::modify_url(the_url,
                         query = list(uploadType = "media", convert = TRUE))
      req <- httr::PUT(the_url,
                       httr::config(token = token),
                       body = httr::upload_file(output_file))
      rc <- jsonlite::fromJSON(httr::content(req, as = "text", encoding = "UTF-8"))

      editURL <- file.path("https://docs.google.com/document/d", rc$id, "edit")
      if(browse) browseURL(editURL)
      message(editURL)
      # file_id_or_url = upload_to_gdrive (output_file)
      # result  = attach_property(file_id_or_url, readChar(input_file, file.info(input_file)$size)
      # save_r_markdown_as_gdoc(input_file, token)
      return(output_file)
    },
    base_format = word_document(reference_docx = template)
  )
}

save_r_markdown_as_gdoc = function(input_file, token) {
  script_url = paste0("https://script.googleapis.com/v1/scripts/", .app$script_id, ":run")
  raw_text = readChar(input_file, file.info(input_file)$size)

  body = list(
    "function"="saveRMarkdown",
    parameters=c(file_id, raw_text)
  )

  invisible(httr::POST(script_url, httr::config(token=token), body=body, encode="json"))
}
