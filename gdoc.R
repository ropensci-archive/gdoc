gdoc <- function(template = "template.docx", token = google_token, keep_md = FALSE, clean_supporting=TRUE, verbose = TRUE, browse = TRUE) {
  output_format(
    knitr = knitr_options(),
    pandoc = pandoc_options(to = "docx"),
    keep_md = keep_md,
    clean_supporting = clean_supporting,
    post_processor = function(metadata, input_file, output_file, clean, verbose) {
      if(is.null(metadata$title)) {
        title = "Test"
      } else {
        title = metadata$title
      }
      the_body <- list(title = title,
                       mimeType = "application/vnd.google-document")
      req <- httr::POST("https://www.googleapis.com/drive/v2/files",
                        httr::config(token = google_token),
                        body = the_body, encode = "json")
      rc <- jsonlite::fromJSON(httr::content(req, as = "text", encoding = "UTF-8"))
      file_id <- rc$id

      the_url <-
        file.path("https://www.googleapis.com/upload/drive/v2/files", file_id)
      the_url <-
        httr::modify_url(the_url,
                         query = list(uploadType = "media", convert = TRUE))
      req <- httr::PUT(the_url,
                       httr::config(token = google_token),
                       body = httr::upload_file(output_file))
      rc <- jsonlite::fromJSON(httr::content(req, as = "text", encoding = "UTF-8"))
      rc
      message(rc$alternateLink)
      if(browse) browseURL(rc$alternateLink)
      # file_id_or_url = upload_to_gdrive (output_file)
      # result  = attach_property(file_id_or_url, readChar(input_file, file.info(input_file)$size)
      return(output_file)
    },
    base_format  = word_document(reference_docx = template)
  )
}
