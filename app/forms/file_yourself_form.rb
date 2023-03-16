class FileYourselfForm < QuestionsForm
  set_attributes_for :diy_intake, :email_address, :preferred_first_name, :received_1099, :filing_frequency

  # TODO: uncomment these after the tests are written & running
  # validates :email_address, presence: true
  # validates :preferred_first_name, presence: true
  # validates :received_1099, presence: true
  # validates :filing_frequency, presence: true

  def save
    # TODO maybe use this form and if so fill out this method etc.
  end
end