class ClassNameValidator < ActiveModel::EachValidator
  def validate_each(record, attr_name, value)
    return false if value.nil?
    begin
      Object.class_eval(value)
    rescue NameError
      record.errors.add(attr_name, "Must be a valid application class")
    end
  end
end