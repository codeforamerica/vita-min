class PersonalInfoForm < QuestionsForm
  set_attributes_for(
    :intake,
    :preferred_name,
    :phone_number,
    :zip_code,
    :need_itin_help,
    :timezone,
    :source,
    :referrer,
    :locale,
    :visitor_id,
  )

  set_attributes_for(
    :confirmation,
    :phone_number_confirmation,
  )

  before_validation :normalize_phone_numbers

  validates :zip_code, zip_code: true
  validates :preferred_name, presence: true
  validates :phone_number, presence: true, confirmation: true, e164_phone: true
  validates :phone_number_confirmation, presence: true
  validates :need_itin_help, inclusion: { in: ['yes', 'no'], message: -> (_object, _data) { I18n.t('errors.messages.blank') } }

  def normalize_phone_numbers
    self.phone_number = PhoneParser.normalize(phone_number) if phone_number.present?
    self.phone_number_confirmation = PhoneParser.normalize(phone_number_confirmation) if phone_number_confirmation.present?
  end

  def save
    state = ZipCodes.details(zip_code)[:state]
    client = Client.create!(
      intake_attributes: attributes_for(:intake).merge(type: @intake.type, state_of_residence: state)
    )
    @intake = client.intake

    data = MixpanelService.data_from([@intake.client, @intake])
    MixpanelService.send_event(
      distinct_id: @intake.visitor_id,
      event_name: "intake_started",
      data: data
    )
  end
end
