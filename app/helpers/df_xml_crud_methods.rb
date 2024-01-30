module DfXmlCrudMethods
  def df_xml_value(key)
    return nil unless node

    selector = selectors[key]
    return nil unless selector

    node.at(selector)&.text
  end

  def create_or_destroy_df_xml_node(key, value, after = nil)
    # Given a key path Root1 Root2 Leaf,
    #   if 'value' is truthy, creates the entire path <Root1><Root2><Leaf> if it doesn't exist
    #   if 'value' is falsey, destroys the <Leaf> node but not <Root1><Root2> (yet?)
    selector = setter_symbol_to_selector(key)
    if value.present? && !node.at(selector).present?
      node_names = selector.split(' ')
      current_node = node
      node_names.each do |node_name|
        next_node = current_node.at(node_name)
        # TODO: this just adds it as the next thing on the parent but if we want it to be schema-compliant it needs to be in the right order
        # (we might not care for this to be schema-compliant)
        if next_node
          current_node = next_node
        elsif after && current_node.at(after)
          current_node.at(after).add_next_sibling("<#{node_name}/>")
        else
          current_node.add_child("<#{node_name}/>").first
        end
      end
      current_node
    elsif value.blank? && node.at(selector).present?
      node.at(selector).remove
    end
  end

  def write_df_xml_value(key, value)
    selector = setter_symbol_to_selector(key)
    selected_node = node.at(selector)

    selected_node.content = value if selected_node.present?
  end

  def setter_symbol_to_selector(method_name)
    # Remove trailing equals sign from method e.g. :filing_status= -> :filing_status
    selectors[method_name.to_s.sub(/=$/, '').to_sym]
  end

  def to_pretty_s
    Nokogiri::XML(node.to_s, &:noblanks).to_xhtml(indent: 2)
  end
end
