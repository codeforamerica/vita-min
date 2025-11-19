module Hub
  class ZipCodeRoutingForm < Form
    attr_accessor :zip_code
    attr_accessor :vita_partner
    delegate :edit_hub_organization_path, :edit_hub_site_path, to: 'Rails.application.routes.url_helpers'

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

    def valid_serviced_zip_code
      return if errors[:zip_code].present?
      errors.merge!(@serviced_zip_code.errors) unless @serviced_zip_code.valid?
    end
  end
end