# == Schema Information
#
# Table name: state_file1099_gs
#
#  id                                 :bigint           not null, primary key
#  address_confirmation               :integer          default("unfilled"), not null
#  federal_income_tax_withheld        :integer
#  had_box_11                         :integer          default("unfilled"), not null
#  intake_type                        :string           not null
#  payer_city                         :string
#  payer_name                         :string
#  payer_street_address               :string
#  payer_tin                          :string
#  payer_zip                          :string
#  recipient                          :integer          default("unfilled"), not null
#  recipient_city                     :string
#  recipient_street_address           :string
#  recipient_street_address_apartment :string
#  recipient_zip                      :string
#  state_identification_number        :string
#  state_income_tax_withheld          :integer
#  unemployment_compensation          :integer
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  intake_id                          :bigint           not null
#
# Indexes
#
#  index_state_file1099_gs_on_intake  (intake_type,intake_id)
#
class StateFile1099G < ApplicationRecord
  belongs_to :intake, polymorphic: true
  before_validation :update_conditional_attributes

  enum address_confirmation: { unfilled: 0, yes: 1, no: 2 }, _prefix: :address_confirmation
  enum had_box_11: { unfilled: 0, yes: 1, no: 2 }, _prefix: :had_box_11
  enum recipient: { unfilled: 0, primary: 1, spouse: 2 }, _prefix: :recipient

  validates_inclusion_of :had_box_11, in: ['yes', 'no'], message: ->(_object, _data) { I18n.t("errors.messages.blank") }
  validates :payer_name, :presence => {:message => I18n.t("errors.attributes.payer_name.blank") }, format: { with: /\A([A-Za-z0-9#&'() -]*[A-Za-z0-9#&'()])?\z/.freeze, message: I18n.t("errors.attributes.payer_name.invalid")}
  validates :payer_street_address, :presence => {:message => I18n.t("errors.attributes.address.street_address.blank") }, format: { with: /\A[a-zA-Z0-9\/\s-]+\z/.freeze, message: I18n.t("errors.attributes.address.street_address.invalid")}
  validates :payer_city, :presence => {:message => I18n.t("errors.attributes.address.city.blank")}, format: { with: /\A[a-zA-Z\s]+\z/.freeze, message: I18n.t("errors.attributes.address.city.invalid")}
  validates :payer_zip, zip_code: true
  validates_presence_of :state_identification_number, :message => I18n.t("errors.attributes.state_id_number.empty")
  validates :recipient_street_address, presence: true, format: { :with => /\A[a-zA-Z0-9\/\s-]+\z/.freeze, message: I18n.t("errors.attributes.address.street_address.invalid")}
  validates :recipient_street_address_apartment, format: { :with => /\A[a-zA-Z0-9\/\s-]+\z/.freeze, message: I18n.t("errors.attributes.address.street_address.invalid")}, allow_blank: true
  validates :recipient_city, presence: true, format: { with: /\A[a-zA-Z\s]+\z/.freeze, message: I18n.t("errors.attributes.address.city.invalid")}
  validates :recipient_zip, zip_code: true
  validates_numericality_of :unemployment_compensation, only_integer: true, message: I18n.t('errors.messages.whole_number')
  validates :unemployment_compensation, numericality: { greater_than_or_equal_to: 1 }
  validates_numericality_of :federal_income_tax_withheld, only_integer: true, message: I18n.t('errors.messages.whole_number')
  validates :federal_income_tax_withheld, numericality: { greater_than_or_equal_to: 0}
  validates_numericality_of :state_income_tax_withheld, only_integer: true, message: I18n.t('errors.messages.whole_number')
  validates :state_income_tax_withheld, numericality: { greater_than_or_equal_to: 0}
  validate :state_specific_validation

  def update_conditional_attributes
    if address_confirmation_yes?
      self.recipient_city = intake.direct_file_data.mailing_city
      self.recipient_street_address = intake.direct_file_data.mailing_street
      self.recipient_street_address_apartment = intake.direct_file_data.mailing_apartment
      self.recipient_zip = intake.direct_file_data.mailing_zip
    end
  end

  def recipient_name
    if recipient_primary?
      intake.primary.full_name
    elsif recipient_spouse?
      intake.spouse.full_name
    end
  end

  def recipient_address_line1
    "#{recipient_street_address}".strip
  end

  def recipient_address_line2
    "#{recipient_street_address_apartment}".strip if recipient_street_address_apartment
  end

  def state_specific_validation
    intake.validate_state_specific_1099_g_requirements(self) if intake.present?
  end
end
