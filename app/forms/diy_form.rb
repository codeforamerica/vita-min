class DiyForm < Form
  include FormAttributes

  attr_accessor :diy_intake

  def initialize(diy_intake = nil, params = {})
    @diy_intake = diy_intake
    super(params)
  end

  def save
    diy_intake.update!(attributes_for(:diy_intake))
  end

  def self.existing_attributes(diy_intake)
    HashWithIndifferentAccess.new(diy_intake.attributes)
  end

  def self.from_diy_intake(diy_intake)
    new(diy_intake, existing_attributes(diy_intake).slice(
      *Attributes.new(attribute_names).to_sym))
  end
end
