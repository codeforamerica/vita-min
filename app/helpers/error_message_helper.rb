module ErrorMessageHelper
  def error_message(object, error_attribute)
    errors = object.errors.messages[error_attribute.to_sym]
    return unless errors.present?

    content_tag :div, class: "text--error" do
      content_tag(:i, "", class: "icon-warning") + content_tag(:span, errors.join(", "))
    end
  end
end