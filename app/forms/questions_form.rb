class QuestionsForm < Form
  include FormAttributes

  attr_accessor :intake

  def initialize(intake = nil, params = {})
    @intake = intake
    super(params)
  end

  def self.from_intake(intake)
    attribute_keys = Attributes.new(attribute_names).to_sym
    new(intake, existing_attributes(intake).slice(*attribute_keys))
  end

end
