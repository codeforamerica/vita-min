class DfXmlAccessor
  include DfXmlCrudMethods

  attr_reader :node

  def initialize(node = nil)
    @node = node || default_node
  end

  def to_h
    selectors.to_h do |selector|
      [selector, send(selector)]
    end
  end

  def self.selectors
    raise NotImplementedError, "Must define SELECTORS"
  end
  delegate :selectors, to: :class

  def self.define_xml_readers
    self.selectors.keys.each do |key|
      if key.ends_with?("Amt", "_amt", "_amount")
        define_method(key) do
          df_xml_value(__method__)&.to_i || 0
        end
      elsif key.ends_with?("_year", "_status")
        define_method(key) do
          df_xml_value(__method__)&.to_i
        end
      else
        define_method(key) do
          df_xml_value(__method__)
        end
      end
    end
  end

  def self.define_xml_writers
    self.selectors.keys.each do |key|
      define_method("#{key}=") do |value|
        create_or_destroy_df_xml_node(__method__, value)
        write_df_xml_value(__method__, value)
      end
    end
  end

  def self.define_xml_accessors
    define_xml_readers
    define_xml_writers
  end
end