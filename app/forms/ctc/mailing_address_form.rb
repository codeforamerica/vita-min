module Ctc
  class MailingAddressForm < QuestionsForm
    set_attributes_for :intake, :urbanization, :street_address, :street_address2, :state, :city, :zip_code

    validates_presence_of :street_address
    validates_presence_of :city
    validates_presence_of :state
    validates :urbanization, format: { with: /\A[A-Za-z0-9\- ]+\z/, message: ->(_object, _data) { I18n.t('validators.urbanization') }, allow_blank: true }
    validates :zip_code, us_or_puerto_rico_zip_code: true
    validate :usps_valid_address

    def save
      if address_service.has_verified_address?
        attrs = address_service.verified_address_attributes.merge(
          street_address2: nil,
          usps_address_verified_at: DateTime.now,
        )
        @intake.update(attrs)
      else
        @intake.update(attributes_for(:intake))
      end
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
    end

    def address_service
      @address_service ||= StandardizeAddressService.new(@intake, read_timeout: 1000)
    end
  end
end
