module Ctc
  module Dependents
    class ChildDisqualifiersForm < DependentForm
      set_attributes_for :dependent,
                         :filed_joint_return,
                         :no_ssn_atin,
                         :provided_over_half_own_support
      set_attributes_for :confirmation, :none_of_the_above
      validate :at_least_one_selected

      def save
        @dependent.assign_attributes(attributes_for(:dependent))
        @dependent.save
      end

      def at_least_one_selected
        chose_one = filed_joint_return == "yes" ||
          no_ssn_atin == "yes" ||
          provided_over_half_own_support == "yes" ||
          none_of_the_above == "yes"
        errors.add(:none_selected, I18n.t("views.ctc.questions.dependents.child_disqualifiers.error")) unless chose_one
      end

      def self.existing_attributes(model, attribute_keys)
        HashWithIndifferentAccess[attribute_keys.filter { |key| key != :none_of_the_above }.map { |k| [k, model.send(k)] }]
      end
    end
  end
end
