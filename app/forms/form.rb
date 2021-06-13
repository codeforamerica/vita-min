class Form
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations::Callbacks
  extend ActiveModel::Callbacks

  define_model_callbacks :save

  def error_summary(exclude_keys: [])
    if errors.present?
      visible_errors = errors.messages.select{ |key, _| exclude_keys.exclude? key }
      concatenated_message_strings = visible_errors.map{ |key, messages| messages.join(" ")}.join(" ")
      "Errors: " + concatenated_message_strings
    end
  end

  def self.form_param
    name.delete("::").underscore
  end
end
