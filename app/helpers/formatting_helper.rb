module FormattingHelper
  def format_text(text)
    # fix to display replacement params properly w/ simple_format
    # which get improperly interpreted as html tags without the internal space otherwise
    text.gsub!("<<", "<< ")
    # tag data is stored between double brackets: [[]]
    # replace tag with span for display purposes
    tag_data = text.scan(/\[{2}(.*?)\]{2}/)
    tag_data.each do |tag|
      next unless tag[0][0] == "{" && tag[0][-1] == "}" # skip content that won't respond to JSON.parse

      data = JSON.parse(tag[0]).to_hash
      span = "<span data-user-id='#{data['id']}' class='user-tag'>#{data['prefix']}#{data['name_with_role'] || data['name']}</span>"
      regex = /\[{2}#{Regexp.escape(tag[0])}\]{2}/
      text.gsub!(regex, span)
    end
    simple_format(text, {}, sanitize: false)
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
