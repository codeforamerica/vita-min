class EligibilityWagesForm < QuestionsForm
  set_attributes_for(
    :intake,
    :triage_income_level,
    :triage_vita_income_ineligible,
    :has_property_income,
    :has_crypto_income,
    :timezone,
    :source,
    :referrer,
    :locale,
    :visitor_id,
    )

  attr_accessor :has_property_income, :has_crypto_income

  validates :triage_income_level, presence: true
  validates :triage_income_level, inclusion: Intake::GyrIntake.triage_income_levels.keys, if: -> { triage_income_level.present? }
  validate :answered_vita_income_ineligible

  def initialize(intake = nil, params = {})
    @has_property_income = params[:has_property_income]
    @has_crypto_income = params[:has_crypto_income]
    super(intake, params)
  end

  def save
    client = Client.create!(
      intake_attributes: attributes_for(:intake).except(:has_property_income, :has_crypto_income).merge(type: @intake.type, product_year: Rails.configuration.product_year)
    )
    @intake = client.intake

    triage_vita_income_ineligible = attributes_for(:intake)[:triage_vita_income_ineligible]

    if triage_vita_income_ineligible == 'no'
      @intake.update(had_rental_income: 'no')
      @intake.update(had_rental_income_from_personal_property: 'no')
      @intake.update(primary_owned_or_held_any_digital_currencies: 'no')
      @intake.update(spouse_owned_or_held_any_digital_currencies: 'no')
    end

    data = MixpanelService.data_from([@intake.client, @intake])
    MixpanelService.send_event(
      distinct_id: @intake.visitor_id,
      event_name: "intake_started",
      data: data
    )
  end

  def answered_vita_income_ineligible
    if @has_property_income == "no" &&
       @has_crypto_income == "no" &&
       triage_vita_income_ineligible != "no"
      errors.add(:triage_vita_income_ineligible, I18n.t("general.please_select_at_least_one_option"))
    end
  end
end
