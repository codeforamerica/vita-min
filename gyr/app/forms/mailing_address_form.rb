class MailingAddressForm < QuestionsForm
  set_attributes_for :intake, :street_address, :city, :state, :zip_code

  validates_presence_of :street_address
  validates_presence_of :city
  validates_presence_of :state
  validates :zip_code, zip_code: true


  def save
    @intake.update(attributes_for(:intake))
  end

  def self.existing_attributes(intake)
    HashWithIndifferentAccess.new(intake.attributes.merge(state: intake.state_of_residence))
  end
end
