# == Schema Information
#
# Table name: intake_site_drop_offs
#
#  id                  :bigint           not null, primary key
#  additional_info     :string
#  certification_level :string
#  email               :string
#  hsa                 :boolean          default(FALSE)
#  intake_site         :string           not null
#  name                :string           not null
#  organization        :string
#  phone_number        :string
#  pickup_date         :date
#  signature_method    :string           not null
#  state               :string
#  timezone            :string
#  created_at          :datetime
#  updated_at          :datetime
#  prior_drop_off_id   :bigint
#  zendesk_ticket_id   :string
#
# Indexes
#
#  index_intake_site_drop_offs_on_prior_drop_off_id  (prior_drop_off_id)
#
# Foreign Keys
#
#  fk_rails_...  (prior_drop_off_id => intake_site_drop_offs.id)
#

class IntakeSiteDropOff < ApplicationRecord
  SIGNATURE_METHODS = %w(in_person e_signature).freeze
  CERTIFICATION_LEVELS = %w(Basic Advanced).freeze
  INTAKE_SITES = {
    thc: [
      "Adams City High School",
      "Clayton Early Learning Center",
      "Colorado Community Action Association",
      "Denver Housing Authority - Connections",
      "Denver Housing Authority - Mulroy",
      "Denver Housing Authority - Quigg Newton",
      "Denver Housing Authority - Westwood",
      "Denver Human Services - East Office",
      "Denver Human Services - Montbello",
      "Denver International Airport",
      "Dress for Success",
      "Fort Collins Tax Site",
      "Lamar Community College",
      "Northeastern Junior College",
      "Pueblo Community College",
      "Trinidad State Junior College - Alamosa",
      "Trinidad State Junior College - Trinidad",
    ],
    gwisr: [
      "GoodwillSR Columbus Intake",
      "GoodwillSR Opelika Intake",
      "GoodwillSR Phenix City Intake",
      "GoodwillSR Thomas Crossroads Intake",
    ],
    uwba: [
      "Family Bridges",
      "Gum Moon Residence",
      "San Francisco Conservation Corps",
    ],
    uwco: [
      "IMPACT Community Action",
      "United Way of Central Ohio",
      "United Way of Central Ohio – Mobile"
    ],
  }.freeze
  ORGANIZATIONS = INTAKE_SITES.keys.map(&:to_s).freeze
  ORGANIZATION_NAMES = {
    "thc" => "Tax Help Colorado",
    "gwisr" => "Goodwill Industries of the Southern Rivers",
    "uwba" => "United Way Bay Area",
    "uwco" => "United Way of Central Ohio"
  }.freeze

  strip_attributes only: [:name, :email, :phone_number, :additional_info]

  validates_presence_of :name
  validates :intake_site, inclusion: { in: INTAKE_SITES.values.flatten, message: I18n.t("models.intake_site_drop_off.validators.intake_site_inclusion") }
  # TODO: use the States table, e.g.:
  # belongs_to :state, foreign_key: :abbreviation
  validates :state, inclusion: { in: States.keys, message: I18n.t("models.intake_site_drop_off.validators.state_inclusion") }
  validates :organization, inclusion: { in: ORGANIZATIONS }
  validates :signature_method, inclusion: { in: SIGNATURE_METHODS, message: I18n.t("models.intake_site_drop_off.validators.signature_method_inclusion") }
  validates :certification_level, allow_blank: true, inclusion: {
    in: CERTIFICATION_LEVELS,
    message: I18n.t("models.intake_site_drop_off.validators.certification_level_inclusion")
  }
  validates :email, allow_blank: true, format: {
    with: URI::MailTo::EMAIL_REGEXP,
    message: I18n.t("models.intake_site_drop_off.validators.email_valid"),
  }
  validates :phone_number, allow_blank: true, phone: { message: I18n.t("models.intake_site_drop_off.validators.phone_number_valid") }
  validate :has_document_bundle?
  validate :has_valid_pickup_date?

  has_one_attached :document_bundle
  belongs_to :prior_drop_off, class_name: self.name, optional: true

  def has_document_bundle?
    doc_is_attached = document_bundle.attached?
    errors.add(:document_bundle, I18n.t("models.intake_site_drop_off.errors.choose_file")) unless doc_is_attached
    doc_is_attached
  end

  def phone_number=(value)
    if value.present? && value.is_a?(String)
      unless value[0] == "1" || value[0..1] == "+1"
        value = "1#{value}" # add USA country code
      end
      self[:phone_number] = Phonelib.parse(value).sanitized
    else
      self[:phone_number] = value
    end
  end

  # Returns the phone number formatted for user display, e.g.: "(510) 555-1234"
  def formatted_phone_number
    Phonelib.parse(phone_number).local_number
  end

  # Returns the phone number in the E164 standardized format, e.g.: "+15105551234"
  def standardized_phone_number
    Phonelib.parse(phone_number, "US").e164
  end

  def pickup_date_string=(input_value)
    if input_value.present? && input_value.is_a?(String)
      input_value = input_value.strip
      parsed_date = parse_month_day_date_string(input_value)
      if parsed_date
        self.pickup_date = parsed_date
      else
        @pickup_date_string = input_value
      end
    end
  end

  def pickup_date_string
    return pickup_date.strftime("%-m/%-d") if pickup_date.present?
    @pickup_date_string
  end

  def has_valid_pickup_date?
    return true if pickup_date_string.blank? || parse_month_day_date_string(pickup_date_string)
    errors.add(:pickup_date_string, I18n.t("models.intake_site_drop_off.errors.valid_pickup_date"))
    false
  end

  def formatted_signature_method
    Date::DATE_FORMATS
    {
      "e_signature" => "E-Signature",
      "in_person" => "In Person"
    }[signature_method]
  end

  def error_summary
    if errors.present?
      visible_errors = errors.messages.select { |key, _| key != :pickup_date }
      concatenated_message_strings = visible_errors.map { |key, messages| messages.join(" ") }.join(" ")
      "Errors: " + concatenated_message_strings
    end
  end

  def add_prior_drop_off_if_present!
    prior_drop_off = self.class.find_prior_drop_off(self)
    self.prior_drop_off = prior_drop_off
    self.zendesk_ticket_id = prior_drop_off.zendesk_ticket_id if prior_drop_off
  end

  def state_name
    States.name_for_key(state)
  end

  def external_id
    return unless id.present?

    ["drop-off", id].join("-")
  end

  def self.intake_sites
    INTAKE_SITES
  end

  def self.certification_levels
    CERTIFICATION_LEVELS
  end

  def self.find_prior_drop_off(new_drop_off)
    drop_offs_with_zendesk_ids = where.not(zendesk_ticket_id: nil)
    if new_drop_off.email.present?
      email_match = drop_offs_with_zendesk_ids.where(email: new_drop_off.email).first
      return email_match if email_match
    end

    if new_drop_off.phone_number.present?
      phone_match = drop_offs_with_zendesk_ids.where(phone_number: new_drop_off.phone_number, name: new_drop_off.name).first
      return phone_match if phone_match
    end

    if new_drop_off.phone_number.blank? && new_drop_off.email.blank?
      name_only_match = drop_offs_with_zendesk_ids.where(name: new_drop_off.name).first
      return name_only_match if name_only_match
    end
  end

  private

  def append_year_to_date_string(date_string)
    date_string + "/2020"
  end

  def parse_month_day_date_string(md_string)
    full_date_string = append_year_to_date_string(md_string)
    begin
      return Date.strptime(full_date_string, "%m/%d/%Y")
    rescue ArgumentError => error
      raise error unless error.to_s == "invalid date"
      return nil
    end
  end
end
