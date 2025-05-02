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
    # used only for file field
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
        label_contents(label_text, has_help_text: !!help_text, optional: optional) + field_html,
        (for_options || options),
        )
    formatted_label += help_text_html(help_text, method) if help_text
    formatted_label += notice_html(notice).html_safe if notice

    formatted_label.html_safe
  end

  def h1_label_contents(label_text, help_text, optional = false)
    label_text = <<~HTML
      <h1 class="form-question">#{label_text + optional_text(optional)}</h1>
    HTML

    if help_text
      label_text << <<~HTML
        <p class="text--help">#{help_text}</p>
      HTML
    end

    label_text.html_safe
  end

  def vita_min_state_file_select(
    method,
    label_text,
    collection,
    options = {},
    &block
  )

    html_options = {
      class: "select__element",
      'aria-describedby': get_describedby(method, help_text: options[:help_text]),
    }

    label_class = options[:label_class] || ""
    label_class += options[:hide_label] ? " sr-only" : ""
    formatted_label = label(
      method,
      label_contents(
        label_text,
        has_help_text: !!options[:help_text],
        optional: options[:optional],
      ),
      class: label_class,
    )

    help_html = help_text_html(options[:help_text], method)

    html_output = <<~HTML
      <div class="form-group#{error_state(object, method)}">
        #{formatted_label}
        #{help_html}
        <div class="select">
          #{select(method, collection, options, html_options, &block)}
        </div>
        #{errors_for(object, method)}
      </div>
    HTML

    html_output.html_safe
  end

  def vita_min_select(
    method,
    label_text,
    collection,
    options = {},
    &block
  )
    html_options = {
      class: "select__element",
    }

    formatted_label = label(
      method,
      h1_label_contents(label_text, options[:help_text], options[:optional])
    )
    html_options_with_errors = html_options.merge(error_attributes(method: method))

    html_output = <<~HTML
      <div class="form-group#{error_state(object, method)}">
        #{formatted_label}
        <div class="select">
          #{select(method, collection, options, html_options_with_errors, &block)}
        </div>
        #{errors_for(object, method)}
      </div>
    HTML

    html_output.html_safe
  end

  def vita_min_select_and_input_fields(
    select_method,
    input_method,
    error_method,
    label_text,
    collection,
    options = {},
    classes: [],
    &block
  )
    html_options = {
      class: "select__element",
    }

    formatted_label = label(
      select_method,
      h1_label_contents(label_text, options[:help_text], options[:optional])
    )
    html_options_with_errors = html_options.merge(error_attributes(method: select_method))

    text_field_options = standard_options.merge(
      type: 'text',
      class: "text-input",
    ).merge(options).merge(error_attributes(method: input_method))

    text_field_options[:id] ||= sanitized_id(input_method)
    options[:input_id] ||= sanitized_id(input_method)

    text_field_html = text_field(input_method, text_field_options)

    html_output = <<~HTML
      <div class="form-group#{error_state(object, error_method)}">
        #{formatted_label}
        <div class="select-and-input #{classes.join(' ')}">
          <div class="select">
            #{select(select_method, collection, options, html_options_with_errors, &block)}
          </div>
          #{text_field_html}
        </div>

        #{errors_for(object, error_method)}
      </div>
    HTML

    html_output.html_safe
  end

  def vita_min_input_field_pair(
    first_input_method,
    second_input_method,
    error_method,
    label_text,
    options = {},
    classes: []
  )
    formatted_label = label(
      first_input_method,
      h1_label_contents(label_text, options[:help_text], options[:optional])
    )

    first_text_field_html = text_field_with_options(first_input_method, options)
    second_text_field_html = text_field_with_options(second_input_method, options)

    html_output = <<~HTML
      <div class="form-group#{error_state(object, error_method)}">
        #{formatted_label}
        <div class="input-pair #{classes.join(' ')}">
          #{first_text_field_html}
          #{second_text_field_html}
        </div>

        #{errors_for(object, error_method)}
      </div>
    HTML

    html_output.html_safe
  end

  def text_field_with_options(input_method, options)
    text_field_options = standard_options.merge(
      type: 'text',
      class: "text-input",
    ).merge(options).merge(error_attributes(method: input_method))

    text_field_options[:id] ||= sanitized_id(input_method)
    text_field_options[:input_id] ||= sanitized_id(input_method)

    text_field(input_method, text_field_options)
  end

  def simplified_cfa_checkbox(method, label_text, options: {})
    checked_value = options[:checked_value] || "1"
    unchecked_value = options[:unchecked_value] || "0"

    classes = ["checkbox checkbox--simplified"]
    if options[:disabled] && object.public_send(method) == checked_value
      classes.push("is-selected")
    end
    if options[:disabled]
      classes.push("is-disabled")
    end

    options_with_errors = options.merge(error_attributes(method: method))
    <<~HTML.html_safe
      <fieldset class="input-group form-group#{error_state(object, method)}">
        <label class="#{classes.join(' ')}">
          #{check_box(method, options_with_errors, checked_value, unchecked_value)} #{label_text}
        </label>
        #{errors_for(object, method)}
      </fieldset>
    HTML
  end

  def hub_checkbox(method, label_text, options: {})
    checked_value = options[:checked_value] || "1"
    unchecked_value = options[:unchecked_value] || "0"

    classes = (options[:classes] || []).push("checkbox--gyr")
    if options[:disabled] && object.public_send(method) == checked_value
      classes.push("is-selected")
    end
    if options[:disabled]
      classes.push("is-disabled")
    end

    options_with_errors = options.merge(error_attributes(method: method))
    <<~HTML.html_safe
      <div class="checkbox-group input-group form-group#{error_state(object, method)}">
        <label class="#{classes.join(' ')}" style="width:fit-content">
          #{check_box(method, options_with_errors, checked_value, unchecked_value)} #{label_text}
        </label>
        #{errors_for(object, method)}
      </div>
    HTML
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

  def vita_min_money_field(
      method,
      label_text,
      options: {},
      classes: [],
      help_text: nil
    )
    describedby = get_describedby(method, help_text: help_text)

    text_field_options = standard_options.merge(error_attributes(method: method)).merge(
      class: (classes + ["text-input money-input"]).join(" "),
      'aria-describedby': describedby
    ).merge(placeholder: '0.00').merge(options)

    text_field_options[:id] ||= sanitized_id(method)
    options[:input_id] ||= sanitized_id(method)

    text_field_html = text_field(method, text_field_options)

    wrapper_classes = classes + ['money-input-group']
    label_and_field_html = label_and_field(
      method,
      label_text,
      text_field_html,
      prefix: '$',
      options: options,
      wrapper_classes: wrapper_classes,
      help_text: help_text
      )

    html_output = <<~HTML
      <div class="form-group#{error_state(object, method)} money-input-form-group">
      #{label_and_field_html}
        #{errors_for(object, method)}
      </div>
    HTML
    html_output.html_safe
  end

  def vita_min_text_field(
    method,
    label_text,
    help_text: nil,
    options: {},
    classes: []
  )
    text_field_options = standard_options.merge(
      class: (classes + ["text-input"]).join(" "),
    ).merge(options).merge(error_attributes(method: method))

    text_field_options[:id] ||= sanitized_id(method)

    text_field_html = text_field(method, text_field_options)

    formatted_label = label(method, h1_label_contents(label_text, help_text), options)

    label_and_field_html = formatted_label + formatted_field(nil, text_field_html, nil, []).html_safe

    html_output = <<~HTML
      <div class="form-group#{error_state(object, method)}">
      #{label_and_field_html}
        #{errors_for(object, method)}
      </div>
    HTML
    html_output.html_safe
  end

  def vita_min_searchbar(method, label_text, label_icon: "", options: {}, classes: [])
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
            #{label_icon.present? ? label_icon.html_safe : "<i class=\"icon-navigate_next\"></i>".html_safe }
          </button>
        </div>
        #{errors_for(object, method)}
      </div>
    HTML
  end

  def vita_min_date_text_fields(method, label_text, help_text: nil, options: {}, options_by_date_component: {}, classes: [])
    date_text_fields = [["month", 2], ["day", 2], ["year", 4]].map do |date_component, max_length|
      date_component_slug = "#{method}_#{date_component}"
      classes += ["text-input date-text-input form-width--short"]
      classes += ["date-text-input-year"] if date_component == "year"

      text_field_options = standard_options
       .merge(class: classes.join(" "))
       .merge(options).merge(error_attributes(method: date_component_slug))
       .merge(
         type: 'tel',
         inputmode: 'numeric',
         maxlength: max_length,
         oninput: "this.value = this.value.replace(/[^0-9]/gi, '');",
       )

      text_field_options[:id] ||= sanitized_id(date_component_slug)
      text_field_options.merge!(options_by_date_component[date_component.to_sym] || {})

      text_field(date_component_slug, text_field_options)
    end

    <<~HTML.html_safe
      <fieldset class="date-text-fields form-group#{error_state(object, method)}">
        #{fieldset_label_contents(label_text: label_text, help_text: help_text)}
        <div>
          #{date_text_fields[0]}
          #{date_text_fields[1]}
          #{date_text_fields[2]}
        </div>
        #{errors_for(object, method)}
      </fieldset>
    HTML
  end

  def vita_min_checkbox_in_set(
    item,
    enum: false
  )
    container_id = nil
    container_class = nil
    item_options = item[:options] || {}
    if item[:opens_follow_up_with_id]
      container_class = "question-with-follow-up__question"
      item_options["data-follow-up"] = "#" + item[:opens_follow_up_with_id]
    elsif item[:follow_up_id]
      container_class = "question-with-follow-up__follow-up"
      container_id = item[:follow_up_id]
    end

    joined_classes = ((item[:classes] || []) + ["checkbox"]).join(" ")
    checkbox_args = [item[:method], item_options]
    checkbox_args += ["yes", "no"] if enum

    <<~HTML.html_safe
      <div id="#{container_id}" class="#{container_class}">
        <label class="#{joined_classes}">
        #{check_box(*checkbox_args)} <span class="text--normal">#{item[:label]}</span>
        </label>
      </div>
    HTML
  end

  # Coped from Honeycrisp form builder v1 cfa_checkbox_set, modified to allow checkboxes to have follow up
  def vita_min_checkbox_set(
    method,
    collection = [],
    label_text: "",
    help_text: nil,
    optional: false,
    legend_class: "",
    enum: false,
    checkboxes: nil
  )
    checkbox_html = (checkboxes || collection.map do |item|
      vita_min_checkbox_in_set(item, enum: enum)
    end.join).html_safe

    checkbox_container_classes = ["tight-ish-checkboxes"]
    includes_follow_up = (collection.any? { |item| item[:opens_follow_up_with_id] }) || (checkbox_html.include? "follow-up")
    checkbox_container_classes << "question-with-follow-up" if includes_follow_up

    fieldset_classes = ["input-group", "form-group#{error_state(object, method)}"]
    describedby = get_describedby(method, help_text: help_text)

    <<~HTML.html_safe
      <fieldset class="#{fieldset_classes.join(' ')}" aria-describedby="#{describedby}">
        #{fieldset_label_contents(
          label_text: label_text,
          help_text: help_text,
          legend_class: legend_class,
          optional: optional,
          )}
          <div class="#{checkbox_container_classes.join(' ')}">
            #{checkbox_html}
          </div>
          #{errors_for(object, method)}
        </fieldset>
    HTML
  end

  def submit(value, options = {})
    options[:data] ||= {}
    options[:data][:disable_with] = value
    super(value, **options)
  end

  def continue(value = I18n.t("general.continue"))
    submit(value, class: "button button--primary button--wide")
  end

  def warning_for_select(element_id, permitted_values, msg)
    @template.content_tag(:div, msg,
      class: "warning warning-for-select",
      'data-warning-for-select': element_id,
      style: "display:none",
      'data-permitted': permitted_values.to_json
    )
  end
end
