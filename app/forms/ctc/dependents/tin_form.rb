module Ctc
  module Dependents
    class TinForm < DependentForm
      set_attributes_for :dependent,
        :tin_type,
        :ssn
      set_attributes_for :confirmation, :ssn_confirmation
      set_attributes_for :misc, :ssn_no_employment
      validates_presence_of :tin_type
      validates_presence_of :ssn

      with_options if: -> { (ssn.present? && ssn != @dependent.ssn) || ssn_confirmation.present? } do
        validates :ssn, confirmation: true
        validates :ssn_confirmation, presence: true
      end

      validates :ssn, social_security_number: true, if: -> { tin_type == "ssn" && ssn.present? }

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
