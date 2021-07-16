module Ctc
  module Dependents
    class TinForm < DependentForm
      include BirthDateHelper
      set_attributes_for :dependent,
        :tin_type,
        :ssn
      set_attributes_for :confirmation, :ssn_confirmation
      set_attributes_for :birthday, :birth_date_month, :birth_date_day, :birth_date_year

      validates :ssn, confirmation: true, if: -> { ssn.present? && ssn != @dependent.ssn }
      validates :ssn, social_security_number: true, if: -> { tin_type == "ssn" && ssn.present? }

      validates_presence_of :tin_type
      validates_presence_of :ssn_confirmation, if: -> { ssn.present? && ssn != @dependent.ssn }

      before_validation do
        [ssn, ssn_confirmation].each do |field|
          field.remove!(/\D/) if field
        end
      end

      def save
        @dependent.assign_attributes(attributes_for(:dependent))
        @dependent.save
      end
    end
  end
end
