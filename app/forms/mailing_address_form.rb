class MailingAddressForm < QuestionsForm
  set_attributes_for :intake, :street_address, :city, :state, :zip_code

  validates_presence_of :street_address, message: "Can't be blank."
  validates_presence_of :city, message: "Can't be blank."
  validates_presence_of :state, message: "Can't be blank."
  validates :zip_code, zip_code: true


  def save
    @intake.update(attributes_for(:intake))
  end

  def self.existing_attributes(intake)
    if intake.street_address.present?
      attributes = intake.attributes
    else
      attributes = intake.primary_user.attributes
    end
    HashWithIndifferentAccess.new(attributes)
  end
end
