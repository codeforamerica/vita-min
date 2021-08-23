module Ctc
  module Portal
    class SpouseForm < Ctc::BaseSpouseForm
      set_attributes_for :intake,
        :spouse_first_name,
        :spouse_middle_initial,
        :spouse_last_name,
        :spouse_suffix,
        :spouse_tin_type,
        :spouse_ssn,
        :spouse_ip_pin
      set_attributes_for :birthday, :spouse_birth_date_month, :spouse_birth_date_day, :spouse_birth_date_year
      set_attributes_for :confirmation, :spouse_ssn_confirmation

      validates :primary_ip_pin, presence: true, ip_pin: true, if: -> { @intake.has_spouse_ip_pin_yes? }
    end
  end
end
