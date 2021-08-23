module Ctc
  class SpouseInfoForm < Ctc::BaseSpouseForm
    set_attributes_for :intake,
                       :spouse_first_name,
                       :spouse_middle_initial,
                       :spouse_last_name,
                       :spouse_suffix,
                       :spouse_tin_type,
                       :spouse_ssn,
                       :spouse_can_be_claimed_as_dependent,
                       :spouse_active_armed_forces
    set_attributes_for :birthday, :spouse_birth_date_month, :spouse_birth_date_day, :spouse_birth_date_year
    set_attributes_for :confirmation, :spouse_ssn_confirmation
    set_attributes_for :misc, :ssn_no_employment

    before_validation do
      if ssn_no_employment == "yes" && spouse_tin_type == "ssn"
        self.spouse_tin_type = "ssn_no_employment"
      end
    end

    def initialize(intake, params)
      super
      if spouse_tin_type == "ssn_no_employment"
        self.spouse_tin_type = "ssn"
        self.ssn_no_employment = "yes"
      end
    end
  end
end
