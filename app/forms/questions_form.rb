class QuestionsForm < Form
  class_attribute :attribute_names
  attr_accessor :intake

  def initialize(intake, params = {})
    @intake = intake
    super(params)
  end

  def attributes_for(model)
    self.class.scoped_attributes[model].reduce({}) do |hash, attribute_name|
      hash[attribute_name] = send(attribute_name)
      hash
    end
  end

  def self.from_intake(intake)
    attribute_keys = Attributes.new(attribute_names).to_sym
    new(intake, existing_attributes(intake).slice(*attribute_keys))
  end

  def self.set_attributes_for(model, *attributes)
    scoped_attributes[model] = attributes
    self.attribute_names = scoped_attributes.values.flatten
    attribute_strings = Attributes.new(attributes).to_s

    attr_accessor(*attribute_strings)
  end

  def self.scoped_attributes
    @scoped_attributes ||= {}
  end

  def self.existing_attributes(intake)
    if intake.present?
      HashWithIndifferentAccess.new(intake.attributes)
    else
      {}
    end
  end
end