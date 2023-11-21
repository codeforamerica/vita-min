class StateFileQaFormBuilder < VitaMinFormBuilder
  def state_file_qa_input_field(
    method,
    label_text,
    type: "text",
    help_text: nil,
    options: {},
    classes: []
  )
    text_field_options = standard_options.merge(
      type: type,
      class: (classes + ["text-input"]).join(" "),
    ).merge(options).merge(error_attributes(method: method))

    text_field_options[:id] ||= sanitized_id(method)
    options[:input_id] ||= sanitized_id(method)

    text_field_html = text_field(method, text_field_options)

    label_and_field_html = label_and_field(
      method,
      add_selector_to_label(method, label_text),
      text_field_html,
      help_text: help_text,
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

  def state_file_qa_cfa_select(
    method,
    label_text,
    collection,
    options = {},
    &block
  )
    cfa_select(
      method,
      add_selector_to_label(method, label_text),
      collection,
      options = {},
    )
  end

  def state_file_nested_xml_field(
    method
  )
    <<~HTML.html_safe
      <tr>
        <td>#{label(method, method)}</td>
        <td>#{text_field(method)}</td>
      </tr>
    HTML
  end

  private

  def add_selector_to_label(method, label_text)
    if DirectFileData::SELECTORS[method]
      decorated_selector = DirectFileData::SELECTORS[method].split(' ').map { |node_name| "&lt;#{node_name}&gt;" }.join('')
      <<~LABEL
        <strong style='font-family: monospace; color: purple;'>#{decorated_selector}</strong>
        <br/>
        <small>(#{label_text})</small>
      LABEL
    else
      label_text
    end
  end
end
