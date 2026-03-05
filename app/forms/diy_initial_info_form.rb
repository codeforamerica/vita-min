class DiyInitialInfoForm < Form
  include FormAttributes
  attr_accessor :diy_intake
  set_attributes_for :diy_intake, :preferred_first_name, :state_of_residence, :zip_code

  def initialize(diy_intake = nil, params = {})
    @diy_intake = diy_intake
    super(params)
  end

  def save
    attrs = attributes_for(:diy_intake)
    attrs[:preferred_first_name] ||= 'unfilled'
    attrs[:state_of_residence] ||= 'unfilled'
    attrs[:zip_code] ||= 'unfilled'
    diy_intake.update!(attrs)
    #diy_intake.update!(attributes_for(:diy_intake))
  end

  def self.existing_attributes(diy_intake)
    HashWithIndifferentAccess.new(diy_intake.attributes)
  end
end
