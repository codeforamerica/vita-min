class DiyForm < Form
  extend AutoStripAttributes

  class_attribute :attribute_names
  attr_accessor :diy_intake

  def initialize(diy_intake, params = {})
    @diy_intake = diy_intake
    super(params)
  end

  def attributes_for(model)
    self.class.scoped_attributes[model].reduce({}) do |hash, attribute_name|
      hash[attribute_name] = send(attribute_name)
      hash
    end
  end

  def self.from_diy_intake(diy_intake)
    attribute_keys = Attributes.new(attribute_names).to_sym
    new(diy_intake, existing_attributes(diy_intake).slice(*attribute_keys))
  end

  def self.set_attributes_for(model, *attributes)
    scoped_attributes[model] = attributes
    self.attribute_names = scoped_attributes.values.flatten
    attribute_strings = Attributes.new(attributes).to_s

    attr_accessor(*attribute_strings)
    auto_strip_attributes *attribute_strings, virtual: true
  end

  def self.scoped_attributes
    @scoped_attributes ||= {}
  end

  def self.existing_attributes(diy_intake)
    if diy_intake.present?
      HashWithIndifferentAccess.new(diy_intake.attributes)
    else
      {}
    end
  end
end