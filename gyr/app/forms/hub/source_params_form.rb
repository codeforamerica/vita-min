module Hub
  class SourceParamsForm < Form
    attr_accessor :code
    attr_accessor :vita_partner
    delegate :edit_hub_organization_path, :edit_hub_site_path, to: 'Rails.application.routes.url_helpers'

    validate :unused_code
    validates_presence_of :code

    def initialize(vita_partner, form_params = nil)
      @vita_partner = vita_partner
      @params = form_params
      @source_param = vita_partner.source_parameters.new(@params)
      super(form_params)
    end

    def save!
      @source_param.save!
    end

    def vita_partner_id
      vita_partner.id
    end

    def unused_code
      existing = SourceParameter.includes(:vita_partner).find_by(code: code)
      if existing.present?
        if existing.vita_partner == vita_partner
          errors.add(:code, I18n.t("hub.source_params.already_applied", code: existing.code))
        else
          params = { anchor: "source-params-form", id: existing.vita_partner.id }
          path = existing.vita_partner.organization? ? edit_hub_organization_path(params) : edit_hub_site_path(params)
          errors.add(:code, I18n.t("hub.source_params.already_taken", vita_partner_name: existing.vita_partner.name, vita_partner_path: path, code: existing.code))
        end
      end
    end
  end
end
