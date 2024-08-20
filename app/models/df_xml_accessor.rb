class DfXmlAccessor
  include DfXmlCrudMethods

  attr_reader :node

  def initialize(node = nil)
    @node = node || default_node
  end

  def self.selectors
    raise NotImplementedError, "Must define SELECTORS"
  end
  delegate :selectors, to: :class

  def self.define_xml_methods
    self.selectors.keys.each do |key|
      if key.ends_with?("Amt")
        define_method(key) do
          df_xml_value(__method__)&.to_i || 0
        end
      else
        define_method(key) do
          df_xml_value(__method__)
        end
      end

      define_method("#{key}=") do |value|
        create_or_destroy_df_xml_node(__method__, value)
        write_df_xml_value(__method__, value)
      end
    end
  end
end