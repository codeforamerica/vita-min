module Ctc
  class MailingAddressForm < QuestionsForm
    set_attributes_for :intake, :street_address, :street_address2, :state, :city, :zip_code
    set_attributes_for :misc, :address_not_found

    validates_presence_of :street_address
    validates_presence_of :city
    validates_presence_of :state
    validates :zip_code, us_or_puerto_rico_zip_code: true
    validate :usps_valid_address

    def save
      attrs = {
        zip_code: address_service.zip_code,
        street_address: address_service.street_address,
        street_address2: nil,
        state: address_service.state,
        city: address_service.city
      }
      @intake.update(attrs)
    rescue => e
      @intake.update(attributes_for(:intake))
    end

    private

    def usps_valid_address
      return unless errors.blank?

      @intake.assign_attributes(attributes_for(:intake))
      if !address_service.valid?
        case address_service.error_code
        when "USPS-2147219400"
          errors.add(:city, I18n.t("forms.errors.mailing_address.city"))
        when "USPS-2147219402"
          errors.add(:state, I18n.t("forms.errors.mailing_address.state"))
        when "USPS-2147219403"
          errors.add(:address_not_found, I18n.t("forms.errors.mailing_address.multiple"))
        when "USPS-2147219401"
          errors.add(:address_not_found, I18n.t("forms.errors.mailing_address.not_found"))
        when "USPS-2147219396"
          errors.add(:address_not_found, I18n.t("forms.errors.mailing_address.invalid"))
        end
      end
    rescue
      true
    end

    def address_service
      @address_service ||= StandardizeAddressService.new(@intake)
    end
  end
end