module Ctc
  module Portal
    class DependentForm < Ctc::Dependents::DependentForm
      include BirthDateHelper

      set_attributes_for :dependent,
                         :first_name,
                         :middle_initial,
                         :last_name,
                         :suffix,
                         :tin_type,
                         :ssn,
                         :ip_pin
      set_attributes_for :confirmation, :ssn_confirmation
      set_attributes_for :birthday, :birth_date_month, :birth_date_day, :birth_date_year

      validates :first_name, presence: true, legal_name: true
      validates :last_name, presence: true, legal_name: true
      validates :middle_initial, length: { maximum: 1 }, legal_name: true
      validate :birth_date_is_valid_date
      validates_presence_of :tin_type
      validates_presence_of :ssn

      with_options if: -> { (ssn.present? && ssn != @dependent.ssn) || ssn_confirmation.present? } do
        validates :ssn, confirmation: true
        validates :ssn_confirmation, presence: true
      end

      validates :ssn, social_security_number: true, if: -> { tin_type == "ssn" && ssn.present? }

      validates :ip_pin, ip_pin: true, if: -> { ip_pin.present? }

      def save
        @dependent.assign_attributes(attributes_for(:dependent).merge(
          birth_date: birth_date,
          has_ip_pin: ip_pin.present? ? "yes" : "no"
        ))
        @dependent.save!
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
