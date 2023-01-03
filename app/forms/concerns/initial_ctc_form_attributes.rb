module InitialCtcFormAttributes
  extend ActiveSupport::Concern

  included do
    set_attributes_for :intake, :timezone
    set_attributes_for :efile_security_information,
                       :device_id,
                       :user_agent,
                       :browser_language,
                       :platform,
                       :timezone_offset,
                       :client_system_time,
                       :ip_address,
                       :timezone

    validates_presence_of :device_id, :user_agent, :browser_language, :platform, :timezone_offset, :client_system_time, :ip_address, :timezone

    def initial_intake_save
      @intake.assign_attributes(attributes_for(:intake).merge(locale: I18n.locale, timezone: timezone, product_year: MultiTenantService.new(:ctc).current_product_year))
      @intake.build_client(
        tax_returns_attributes: [{ year: MultiTenantService.new(:ctc).current_tax_year, is_ctc: true }],
        efile_security_informations_attributes: [attributes_for(:efile_security_information)],
        vita_partner: VitaPartner.ctc_site
      )
      @intake.save!
    end
  end
end
