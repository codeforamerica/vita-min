module XmlMethods
  def delete_blank_nodes(node)
    return unless [1, 9].include?(node.node_type) # <nodesWithChildren></nodesWithChildren>
    node.children.to_a.each do |child|
      delete_blank_nodes(child)
    end
    content = node.inner_html.strip
    if content == "" || content == "0"
      node.remove
      return
    end
    node.inner_html = content
    if node.children.empty?
      node.remove
    end
  end
end
