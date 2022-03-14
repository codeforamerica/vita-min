module Ctc
  module Dependents
    class ChildQualifiesForm < DependentForm
      set_attributes_for :dependent,
                         :full_time_student,
                         :permanently_totally_disabled
      set_attributes_for :confirmation, :none_of_the_above
      validates :none_of_the_above, at_least_one_or_none_of_the_above_selected: true

      def save
        @dependent.assign_attributes(attributes_for(:dependent))
        @dependent.save
      end

      def at_least_one_selected
        full_time_student == "yes" || permanently_totally_disabled == "yes"
      end
    end
  end
end
