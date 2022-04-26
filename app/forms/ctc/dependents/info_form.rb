module Ctc
  module Dependents
    class InfoForm < DependentForm
      include DateHelper

      set_attributes_for :dependent,
                         :first_name,
                         :middle_initial,
                         :last_name,
                         :suffix,
                         :relationship,
                         :filed_joint_return,
                         :tin_type,
                         :ssn
      set_attributes_for :birthday, :birth_date_month, :birth_date_day, :birth_date_year
      set_attributes_for :misc, :ssn_no_employment
      set_attributes_for :confirmation, :ssn_confirmation
      set_attributes_for :recaptcha, :recaptcha_score, :recaptcha_action

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
      validates :ssn, atin: true, if: -> { ["atin"].include?(tin_type) && ssn.present? }

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
        @dependent.assign_attributes(attributes_for(:dependent).merge(birth_date: birth_date))
        @dependent.lived_with_more_than_six_months = "yes" if @dependent.born_in_final_6_months_of_tax_year?(TaxReturn.current_tax_year)
        @dependent.save!

        if attributes_for(:recaptcha)[:recaptcha_score].present?
          @dependent.intake.client.recaptcha_scores.create(
            score: attributes_for(:recaptcha)[:recaptcha_score],
            action: attributes_for(:recaptcha)[:recaptcha_action]
          )
        end
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
        parse_date_params(birth_date_year, birth_date_month, birth_date_day)
      end

      def birth_date_is_valid_date
        valid_text_birth_date(birth_date_year, birth_date_month, birth_date_day, :birth_date)
      end
    end
  end
end
