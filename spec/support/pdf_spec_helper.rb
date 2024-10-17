module PdfSpecHelper
  def filled_in_values(file_path)
    filled_in_fields = PdfForms.new.get_fields(file_path)

    filled_in_fields.each_with_object({}) do |field, hash|
      # The pdf-forms gem returns HTML-escaped form values when using pdftk-java. Unescape.
      hash[field.name] = field.value.nil? ? nil : CGI.unescapeHTML(field.value)
    end
  end

  def non_preparer_fields(filepath)
    filled_in_values(filepath).select do |key, value|
      key.exclude?("intake_specialist_")
    end
  end

  # Only works for Field Type: Button
  def check_if_valid_pdf_option(file_path, field_name, value)
    data_dump = PdfForms.new.call_pdftk(file_path, :dump_data_fields)
    matching_field = data_dump.split("---").find { |data_field| data_field.match(field_name) }
    value_pairs = matching_field.split("\n")
    field_state_options = value_pairs.filter { |pair| pair.match("FieldStateOption") }
    clean_field_state_options = field_state_options.map { |field| field.sub("FieldStateOption: ", "") }
    clean_field_state_options.include?(value)
  end
end
