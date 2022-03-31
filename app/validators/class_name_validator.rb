class ClassNameValidator < ActiveModel::EachValidator
  def validate_each(record, attr_name, value)
    return false if value.nil?

    record.errors.add(attr_name, "Must be a valid application class") unless Object.descendants.map(&:name).include?(value)
  end
end