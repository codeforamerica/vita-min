module Ctc
  class EitcQualifiersForm < QuestionsForm
    set_attributes_for :intake, :former_foster_youth, :homeless_youth, :not_full_time_student, :full_time_student_less_than_four_months
    set_attributes_for :confirmation, :none_of_the_above
    validates :none_of_the_above, at_least_one_or_none_of_the_above_selected: true

    def save
      additional_attributes = { full_time_student_less_than_five_months: full_time_student_less_than_four_months }
      @intake.update(attributes_for(:intake).merge(additional_attributes))
    end

    def at_least_one_selected
      former_foster_youth == "yes" ||
        homeless_youth == "yes" ||
        not_full_time_student == "yes" ||
        full_time_student_less_than_four_months == "yes"
    end
  end
end
