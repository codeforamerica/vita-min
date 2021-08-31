module Ctc
  class IncomeForm < QuestionsForm
    set_attributes_for :intake, :timezone
    set_attributes_for :efile_security_information,
                       :device_id,
                       :user_agent,
                       :browser_language,
                       :platform,
                       :timezone_offset,
                       :client_system_time,
                       :ip_address
    set_attributes_for :misc, :had_reportable_income

    validates_presence_of :device_id, :user_agent, :browser_language, :platform, :timezone_offset, :client_system_time, :ip_address

    def save
      @intake.assign_attributes(attributes_for(:intake).merge(locale: I18n.locale))
      @intake.build_client(
        tax_returns_attributes: [{ year: 2020, is_ctc: true }],
        efile_security_informations_attributes: [attributes_for(:efile_security_information).merge(timezone_offset: format_timezone_offset(timezone_offset))]
      )
      @intake.save!
    end

    def had_reportable_income?
      had_reportable_income == "yes"
    end

    def format_timezone_offset(tz_offset)
      return unless tz_offset.present?

      (tz_offset.include?("-") || tz_offset.include?("+")) ? tz_offset : "+" + tz_offset
    end
  end
end
