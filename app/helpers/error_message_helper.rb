module ErrorMessageHelper
  def error_message(object, error_attribute)
    errors = object.errors.messages[error_attribute.to_sym]
    return unless errors.present?

    tag.div class: "text--error" do
      tag.i(class: "icon-warning") + tag.span(errors.join(", "))
    end
  end
end