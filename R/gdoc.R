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

#' Get a Google token
#'
#' @examples{
#' \dontrun{
#' gd_auth()
#' }
#' }
#'
#' @export
gd_auth <- function() {
  ## I do not understand why these tokens are not refreshable
  ## so this works for now.
  if (!file.exists(".httr-oauth") && !interactive()) {
    stop("Token needed which requires an interactive environment.")
  }
  .app$token <-
    httr::oauth2.0_token(httr::oauth_endpoints("google"),
                         .app$app, scope = .app$scopes, cache = TRUE)
  if (!.app$token$validate()) {
    unlink(".httr-oauth")
    .app$token <- NULL
    Recall()
  }
  invisible(.app$token)
}

#' Get an R Markdown document for practice
#'
#' @param filename filename
#'
#' @examples{
#' \dontrun{
#' my_rmd <- gtemplate()
#' rmarkdown::render(my_rmd)
#' }
#' }
#' @export
gtemplate <- function(filename = "test.Rmd") {
  template_file <- system.file("test.Rmd", package = "gdoc")
  file.copy(template_file, filename)
  filename
}


#' Create a Google Doc from an R Markdown File
#'
#' @param reference_docx Use the specified file as a style reference in
#'   producing an intermediate MS Word docx file. For best results, the
#'   reference docx should be a modified version of a docx file produced using
#'   pandoc. `NULL` requests the default reference docx built into the package.
#' @param token Google OAuth2 token. \code{\link{gd_auth}()} will load a
#'   previously cached token from \code{.httr-oauth}, if available and still
#'   valid. Otherwise, \code{\link{gd_auth}()} will initiate the browser dance
#'   to obtain and cache a new token, which requires an \code{interactive()}
#'   session. \code{\link{gd_auth}()} can be called explicitly to prepare for
#'   non-\code{interactive()} use, such as via the "Knit" button in RStudio.
#' @param keep_md Logical.  Whether to retain the knit markdown file.
#' @param clean_supporting Logical. Whether to keep other intermediate files,
#'   including the MS Word docx file.
#'
#' @export
gdoc <- function(reference_docx = NULL, token = gd_auth(),
                 keep_md = FALSE, clean_supporting = TRUE) {


  before_knit = function(x) {
    message("Validating Token")
    stopifnot(token$validate())
    x
  }


  if (is.null(reference_docx)) {
    template = system.file("reference.docx", package = "gdoc")
  }

  post_processor = function(metadata, input_file, output_file, clean, verbose) {
    if (is.null(metadata$title)) {
      title = "Test"
    } else {
      title = metadata$title
    }

 #   if (is.null(metadata$gdoc_id)) {
      req <- doc_init(output_file, token, title)
#    } else {
#      req <- doc_update(metadata$gdoc_id, output_file, token)
#    }
    httr::stop_for_status(req)
    rc <- jsonlite::fromJSON(httr::content(req, as = "text", encoding = "UTF-8"))

    input_file_orig = stringi::stri_replace_all_fixed(input_file, "utf8.md", "Rmd")
    document_body = rmarkdown:::partition_yaml_front_matter(readLines(input_file_orig))$body
    front_matter = rmarkdown:::parse_yaml_front_matter(readLines(input_file_orig))
    front_matter$gdoc_id = rc$id
    front_matter = paste0("---\n",
                          yaml::as.yaml(front_matter),
                          "---\n"
    )

    cat(front_matter, paste(document_body, collapse = "\n"),
        file = input_file_orig)
    editURL = file.path("https://docs.google.com/document/d", rc$id, "edit")
    if (clean_supporting) file.remove(output_file)
    url_file = paste0(tools::file_path_sans_ext(output_file), ".url")
    cat(paste0("[InternetShortcut]\nURL=", editURL, "\n"), file = url_file)
    message(editURL)
    return(url_file)
  }

  rmarkdown::output_format(
    knitr = rmarkdown::knitr_options(knit_hooks = list(document = before_knit)),
    pandoc = rmarkdown::pandoc_options(to = "docx"),
    keep_md = keep_md,
    clean_supporting = clean_supporting,
    post_processor = post_processor,
    base_format  = rmarkdown::word_document(reference_docx = template)
  )
}

doc_init <- function(output_file, token, title) {
  the_body <- list(title = title,
                   mimeType = "application/vnd.google-apps.document")
  req <- httr::POST("https://www.googleapis.com/drive/v2/files",
                    httr::config(token = token),
                    body = the_body, encode = "json")
  rc <- jsonlite::fromJSON(httr::content(req, as = "text", encoding = "UTF-8"))
  the_url <-
    file.path("https://www.googleapis.com/upload/drive/v2/files", rc$id)
  the_url <-
    httr::modify_url(the_url,
                     query = list(uploadType = "media", convert = TRUE))
  httr::PUT(the_url,
            httr::config(token = token),
            body = httr::upload_file(output_file))
}

doc_update <- function(file_id, output_file, token) {
  ## https://developers.google.com/drive/v3/reference/files/update#http-request
  the_url <-
    file.path("https://www.googleapis.com/upload/drive/v2/files", file_id)
  the_url <-
    httr::modify_url(the_url,
                     query = list(uploadType = "media", convert = TRUE))
  httr::PUT(the_url,
            httr::config(token = token),
            body = list(file = httr::upload_file(output_file),
                        mimeType = "application/vnd.google-apps.document"))
}
