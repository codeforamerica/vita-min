class FileYourselfForm < Form
  include FormAttributes
  attr_accessor :diy_intake
  set_attributes_for :diy_intake, :email_address, :preferred_first_name, :received_1099, :filing_frequency, :referrer, :locale, :visitor_id, :source

  validates :email_address, 'valid_email_2/email': true, presence: true
  validates :preferred_first_name, presence: true
  validates :received_1099, presence: true
  # TODO: Validate that this check works i.e. Rails sends empty string
  validates :filing_frequency, presence: true

  def initialize(diy_intake = nil, params = {})
    @diy_intake = diy_intake
    super(params)
  end

  def save
    diy_intake.update!(attributes_for(:diy_intake))
  end
end