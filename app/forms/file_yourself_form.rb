class FileYourselfForm < Form
  include FormAttributes
  attr_accessor :diy_intake
  set_attributes_for :diy_intake, :email_address, :preferred_first_name, :filing_frequency, :referrer, :locale, :visitor_id, :source

  validates :email_address, presence: true, 'valid_email_2/email': { mx: true }
  validates :preferred_first_name, presence: true
  validates :filing_frequency, presence: true

  def initialize(diy_intake = nil, params = {})
    @diy_intake = diy_intake
    super(params)
  end

  def save
    diy_intake.update!(attributes_for(:diy_intake))
  end
end
