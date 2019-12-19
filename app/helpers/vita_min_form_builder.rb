class VitaMinFormBuilder < Cfa::Styleguide::CfaFormBuilder
  def vita_min_field_in_label(
      method,
      label_text,
      field,
      help_text: nil,
      prefix: nil,
      postfix: nil,
      optional: false,
      options: {},
      notice: nil,
      wrapper_classes: []
  )
    # this override allows us to wrap the field in a label
    if options[:input_id]
      for_options = options.merge(
          for: options[:input_id],
          )
      for_options.delete(:input_id)
      for_options.delete(:maxlength)
    end
    field_html = formatted_field(prefix, field, postfix, wrapper_classes).html_safe

    formatted_label = label(
        method,
        label_contents(label_text, help_text, optional) + field_html,
        (for_options || options),
        )
    formatted_label += notice_html(notice).html_safe if notice

    formatted_label.html_safe
  end

  def cfa_file_field(method, label_text, help_text: nil, options: {}, classes: [], optional: false)

    file_field_options = {
        class: (classes + ["file-input"]).join(" ")
    }.merge(options).merge(error_attributes(method: method))

    file_field_options[:id] ||= sanitized_id(method)
    options[:input_id] ||= sanitized_id(method)

    file_field_html = file_field(method, file_field_options)
    label_and_field_html = vita_min_field_in_label(
      method,
      label_text,
      file_field_html,
      help_text: help_text,
      optional: optional,
      options: options,
      wrapper_classes: classes,
    )

    html_output = <<~HTML
      <div class="form-group#{error_state(object, method)}">
        #{label_and_field_html}
        #{errors_for(object, method)}
      </div>
    HTML
    html_output.html_safe
  end

  def vita_min_searchbar(method, label_text, options: {}, classes: [])
    text_field_options = {
      class: (classes + ["vita-min-searchbar__input text-input"]).join(" ")
    }.merge(options).merge(error_attributes(method: method))

    text_input_html = text_field(method, text_field_options)

    return <<~HTML.html_safe
      <div class="vita-min-searchbar form-group#{error_state(object, method)}" role="search">
        <div class="vita-min-searchbar__field">
          <label class="vita-min-searchbar__label sr-only" for="#{object_name}_#{method}">#{label_text}</label>
          <div>
            #{text_input_html}
          </div>
          <button class="vita-min-searchbar__button button button--primary" type="submit">
            <span class="vita-min-searchbar__submit-text hide-on-mobile">#{label_text}</span>
            <i class="icon-navigate_next"></i>
          </button>
        </div>
        #{errors_for(object, method)}
      </div>
    HTML
  end
end
