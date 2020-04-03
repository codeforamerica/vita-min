module PdfSpecHelper
  def filled_in_values(file_path)
    filled_in_fields = PdfForms.new.get_fields(file_path)

    filled_in_fields.each_with_object({}) do |field, hash|
      hash[field.name] = field.value
    end
  end

  def non_preparer_fields(filepath)
    filled_in_values(filepath).select do |key, value|
      key.exclude?("intake_specialist_")
    end
  end
end
