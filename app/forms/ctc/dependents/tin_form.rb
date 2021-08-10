module Ctc
  module Dependents
    class TinForm < DependentForm
      include BirthDateHelper
      set_attributes_for :dependent,
        :tin_type,
        :ssn
      set_attributes_for :confirmation, :ssn_confirmation
      set_attributes_for :birthday, :birth_date_month, :birth_date_day, :birth_date_year
      set_attributes_for :misc, :ssn_no_employment

      validates :ssn, confirmation: true, if: -> { ssn.present? && ssn != @dependent.ssn }
      validates :ssn, social_security_number: true, if: -> { tin_type == "ssn" && ssn.present? }

      validates_presence_of :tin_type
      validates_presence_of :ssn_confirmation, if: -> { ssn.present? && ssn != @dependent.ssn }

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
        @dependent.assign_attributes(attributes_for(:dependent))
        @dependent.save!
      end
    end
  end
end
