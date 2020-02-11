class ZendeskSmsService
  def initialize(phone_number:)
    @phone_number = phone_number
  end

  def find_associated_records
    User.where(phone_number: @phone_number)
  end
end