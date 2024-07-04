def match_xml(expected, ignore_list)
  MatchXml.new(expected, ignore_list)
end

class MatchXml
  def initialize(expected, ignore_list)
    @ignore_list = ignore_list
    @expected = MatchXml.xml_to_hash(expected, @ignore_list)
  end

  def matches?(actual)
    @actual = MatchXml.xml_to_hash(actual, @ignore_list)
    RSpec::Matchers::BuiltIn::Include.new(@expected).matches?(@actual)
  end

  def failure_message
    RSpec::Support::Differ.new.diff(@actual, @expected)
  end

  class << self
    def traverse_elements(base_node, ignore_list, &block)
      return to_enum(:traverse_elements, base_node, ignore_list) unless block_given?
      return if ignore_list.include?(base_node.name)
      base_node.element_children.each do |child_node|
        if child_node.children.count == 1 && !ignore_list.include?(child_node.name)
          yield child_node
        end
        traverse_elements(child_node, ignore_list, &block)
      end
    end

    def xml_to_hash(xml, ignore_list)
      traverse_elements(xml, ignore_list).to_h { |e| [e.css_path, e.text] }
    end
  end
end
