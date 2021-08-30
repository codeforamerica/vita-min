module Ctc
  module Dependents
    class InfoForm < DependentForm
      include BirthDateHelper

      set_attributes_for :dependent,
                         :first_name,
                         :middle_initial,
                         :last_name,
                         :suffix,
                         :relationship,
                         :full_time_student,
                         :tin_type,
                         :ssn,
                         :permanently_totally_disabled
      set_attributes_for :birthday, :birth_date_month, :birth_date_day, :birth_date_year
      set_attributes_for :misc, :ssn_no_employment
      set_attributes_for :confirmation, :ssn_confirmation

      validates :first_name, presence: true, legal_name: true
      validates :last_name, presence: true, legal_name: true
      validates :middle_initial, legal_name: true
      validates :ssn, presence: true
      validates :tin_type, presence: true
      validates_presence_of :relationship
      validate :birth_date_is_valid_date

      with_options if: -> { (ssn.present? && ssn != @dependent.ssn) || ssn_confirmation.present? } do
        validates :ssn, confirmation: true
        validates :ssn_confirmation, presence: true
      end

      validates :ssn, social_security_number: true, if: -> { ["ssn", "ssn_no_employment"].include?(tin_type) && ssn.present? }

      before_validation do
        if ssn_no_employment == "yes" && tin_type == "ssn"
          self.tin_type = "ssn_no_employment"
        end
      end

      def initialize(dependent, params)
        super
        if tin_type == "ssn_no_employment"
          self.tin_type = "ssn"
          self.ssn_no_employment = "yes"
        end
      end

      def save
        @dependent.assign_attributes(attributes_for(:dependent).merge(
          birth_date: birth_date
        ))
        @dependent.save

        @dependent.update!(lived_with_more_than_six_months: "yes") if @dependent.born_in_last_6_months_of_2020?
      end

      def self.existing_attributes(dependent, _attribute_keys)
        if dependent.birth_date.present?
          super.merge(
            birth_date_day: dependent.birth_date.day,
            birth_date_month: dependent.birth_date.month,
            birth_date_year: dependent.birth_date.year,
          )
        else
          super
        end
      end

      private

      def birth_date
        parse_birth_date_params(birth_date_year, birth_date_month, birth_date_day)
      end

      def birth_date_is_valid_date
        valid_text_birth_date(birth_date_year, birth_date_month, birth_date_day, :birth_date)
      end
    end
  end
end
