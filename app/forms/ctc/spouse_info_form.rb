module Ctc
  class SpouseInfoForm < QuestionsForm
    include BirthDateHelper
    set_attributes_for :intake,
                       :spouse_first_name,
                       :spouse_middle_initial,
                       :spouse_last_name,
                       :spouse_suffix,
                       :spouse_tin_type,
                       :spouse_ssn,
                       :spouse_active_armed_forces
    set_attributes_for :birthday, :spouse_birth_date_month, :spouse_birth_date_day, :spouse_birth_date_year
    set_attributes_for :confirmation, :spouse_ssn_confirmation
    set_attributes_for :misc, :ssn_no_employment

    validates :spouse_first_name, presence: true, legal_name: true
    validates :spouse_last_name, presence: true, legal_name: true
    validates :spouse_middle_initial, length: { maximum: 1 }, legal_name: true
    validate  :spouse_birth_date_is_valid_date
    validates :spouse_ssn, confirmation: true, if: -> { spouse_ssn.present? }
    validates :spouse_ssn, social_security_number: true, if: -> { spouse_tin_type == "ssn" && spouse_ssn.present? }

    validates_presence_of :spouse_ssn, message: -> (_object, _data) { I18n.t('views.ctc.questions.spouse_info.ssn_required_message') }, if: -> { spouse_tin_type != "none" }
    validates_presence_of :spouse_ssn_confirmation, if: -> { spouse_ssn.present? }

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

    def save
      spouse_last_four_ssn = spouse_ssn.last(4) # merge last_four_ssn so that client can use data for logging in.
      @intake.update(attributes_for(:intake).merge(
        spouse_birth_date: spouse_birth_date,
        spouse_last_four_ssn: spouse_last_four_ssn
      ))
    end

    def self.existing_attributes(intake, attributes)
      super.merge(ssn_attributes(intake)).merge(date_of_birth_attributes(intake))
    end

    def self.ssn_attributes(intake)
      {
        spouse_ssn: intake.spouse_ssn,
        spouse_ssn_confirmation: intake.spouse_ssn
      }
    end

    def self.date_of_birth_attributes(intake)
      {
        spouse_birth_date_day: intake.spouse_birth_date&.day,
        spouse_birth_date_month: intake.spouse_birth_date&.month,
        spouse_birth_date_year: intake.spouse_birth_date&.year
      }
    end

    private

    def spouse_birth_date
      parse_birth_date_params(spouse_birth_date_year, spouse_birth_date_month, spouse_birth_date_day)
    end

    def spouse_birth_date_is_valid_date
      valid_text_birth_date(spouse_birth_date_year, spouse_birth_date_month, spouse_birth_date_day, :spouse_birth_date)
    end
  end
end
