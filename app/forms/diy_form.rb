class DiyForm < Form
  include FormAttributes

  attr_accessor :diy_intake

  def initialize(diy_intake, params = {})
    @diy_intake = diy_intake
    super(params)
  end

  def self.from_diy_intake(diy_intake)
    attribute_keys = Attributes.new(attribute_names).to_sym
    new(diy_intake, existing_attributes(diy_intake).slice(*attribute_keys))
  end

end
