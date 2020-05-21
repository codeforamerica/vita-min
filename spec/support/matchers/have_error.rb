RSpec::Matchers.define :have_error do |error_text|
  match do |label_text|
    field = find_field(label_text)
    error_span = field.send(:parent).send(:sibling, "span")
    error_span[:class].include?("text--error") &&
      error_span.text.include?(error_text)
  end
end
