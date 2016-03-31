gdoc <- function(template = "template.docx") {
  output_format(
    post_processor = function(input_file, output_file, clean, verbose) {
      # file_id_or_url = upload_to_gdrive (output_file)
      # result  = attach_property(file_id_or_url, readChar(input_file, file.info(input_file)$size)

      message(gdoc_url)
      message(result)
      return(output_file)
    },
    base_format  = word_document(reference_docx = template)
  )
}
