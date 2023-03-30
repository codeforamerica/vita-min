module FormattingHelper
  def note_body(text)
    formatted_text = simple_format(text)
    # replace JSON in [[]] with span containing data usable by our JS
    tag_data = formatted_text.scan(/\[{2}(.*?)\]{2}/)
    tag_data.each do |tag|
      next unless tag[0][0] == "{" && tag[0][-1] == "}" # skip content that won't respond to JSON.parse

      data = JSON.parse(tag[0]).to_hash
      span = content_tag(:span, class: "user-tag") do
        data['prefix'] + (data['name_with_role'] || data['name'])
      end
      regex = /\[{2}#{Regexp.escape(tag[0])}\]{2}/
      formatted_text.gsub!(regex, span)
    end
    formatted_text
  end

  def message_body(body)
    if body.blank?
      return content_tag(:div, class: "grid-flex center-aligned") do
        image_tag("icons/exclamation.svg", class: "message__status item-5r") +
        content_tag(:i, "Message has no content.")
      end
    end
    simple_format(body)
  end
end
