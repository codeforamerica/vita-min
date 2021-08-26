module Ctc
  module Portal
    class PrimaryFilerForm < Ctc::BasePrimaryFilerForm
      set_attributes_for :intake,
        :primary_first_name,
        :primary_middle_initial,
        :primary_last_name,
        :primary_suffix,
        :primary_ssn,
        :primary_tin_type,
        :primary_ip_pin
      set_attributes_for :birthday, :primary_birth_date_month, :primary_birth_date_day, :primary_birth_date_year
      set_attributes_for :confirmation, :primary_ssn_confirmation

      validates :primary_ip_pin, ip_pin: true, if: -> { primary_ip_pin.present? }

      def save
        @intake.assign_attributes(
          has_primary_ip_pin: primary_ip_pin.present? ? "yes" : "no"
        )
        super
      end
    end
  end
end
