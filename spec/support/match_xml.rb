def match_xml(expected, node_ignore_list, attr_ignore_list)
  MatchXml.new(expected, node_ignore_list, attr_ignore_list)
end

class MatchXml
  def initialize(expected, node_ignore_list, attr_ignore_list)
    @node_ignore_list = node_ignore_list
    @attr_ignore_list = attr_ignore_list
    @expected = MatchXml.xml_to_hash(expected, @node_ignore_list, @attr_ignore_list)
  end

  def matches?(actual)
    @actual = MatchXml.xml_to_hash(actual, @node_ignore_list, @attr_ignore_list)
    RSpec::Matchers::BuiltIn::Include.new(@expected).matches?(@actual)
  end

  def failure_message
    RSpec::Support::Differ.new.diff(@actual, @expected)
  end

  class << self
    def traverse_elements(base_node, node_ignore_list, &block)
      return to_enum(:traverse_elements, base_node, node_ignore_list) unless block_given?
      return if node_ignore_list.include?(base_node.name)
      yield base_node
      base_node.elements.each do |child_node|
        traverse_elements(child_node, node_ignore_list, &block)
      end
    end

    def xml_to_hash(xml, node_ignore_list, attr_ignore_list)
      traverse_elements(xml, node_ignore_list).flat_map do |e|
        pairs = []
        if e.elements.count == 0
          # We use css_path as a key because it includes the full node hierarchy AND will differentiate between
          # nodes with identical paths, e.g. elements in a list, by appending ":nth-of-type(N)"
          pairs.append([e.css_path, e.text])
        end
        e.each do |attr_name, attr_value|
          unless attr_ignore_list.include? attr_name
            pairs.append(["#{e.css_path}:#{attr_name}", attr_value])
          end
        end
        pairs
      end.to_h
    end
  end
end
