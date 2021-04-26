module Hub
  class ZipCodeRoutingForm < Form
    attr_accessor :zip_code
    attr_accessor :vita_partner
    delegate :edit_hub_organization_path, :edit_hub_site_path, to: 'Rails.application.routes.url_helpers'

    validate :unused_zipcode
    validate :valid_serviced_zip_code

    def initialize(vita_partner, form_params = nil)
      @vita_partner = vita_partner
      @params = form_params
      @serviced_zip_code = vita_partner.serviced_zip_codes.new(@params)

    end

    def save!
      @serviced_zip_code.save!
    end

    def vita_partner_id
      vita_partner.id
    end

    def unused_zipcode
      existing = VitaPartnerZipCode.includes(:vita_partner).find_by(zip_code: @params[:zip_code])
      if existing.present?
        if existing.vita_partner == vita_partner
          errors.add(:zip_code, I18n.t("hub.zip_codes.already_applied", zip_code: existing.zip_code))
        else
          params = { anchor: "zip-code-routing-form", id: existing.vita_partner.id }
          path = existing.vita_partner.organization? ? edit_hub_organization_path(params) : edit_hub_site_path(params)
          errors.add(:zip_code, I18n.t("hub.zip_codes.already_taken", vita_partner_name: existing.vita_partner.name, vita_partner_path: path, zip_code: existing.zip_code))
        end
      end
    end

    def valid_serviced_zip_code
      return if errors[:zip_code].present?
      errors.merge!(@serviced_zip_code.errors) unless @serviced_zip_code.valid?
    end
  end
end