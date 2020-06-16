module ApplicationHelper
  def will_paginate(collection_or_options = nil, options = {})
    if collection_or_options.is_a? Hash
      options, collection_or_options = collection_or_options, nil
    end
    unless options[:renderer]
      options = options.merge :renderer => VitaMinLinkRenderer
    end
    super *[collection_or_options, options].compact
  end

  def round_meters_up_to_5_mi(meters)
    five_miles_in_meters = 8046.72
    (meters / five_miles_in_meters).ceil * 5
  end

  def link_to_locale(locale, label, additional_attributes = {})
    link_to(label,
            "?" + request.query_parameters.merge("new_locale" => locale).to_query,
            lang: locale,
            "data-track-click": "intake-language-changed",
            "data-track-attributes-to_locale": locale,
            "data-track-attributes_from_locale": I18n.locale,
            **additional_attributes).html_safe
  end

  def link_to_spanish(additional_attributes={})
    link_to_locale('es', 'Español', additional_attributes)
  end

  def link_to_english(additional_attributes={})
    link_to_locale('en', 'English', additional_attributes)
  end

end
