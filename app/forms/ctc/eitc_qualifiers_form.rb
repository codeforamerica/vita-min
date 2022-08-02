module Ctc
  class EitcQualifiersForm < QuestionsForm
    set_attributes_for :intake, :former_foster_youth, :homeless_youth, :not_full_time_student, :full_time_student_less_than_four_months
    set_attributes_for :confirmation, :none_of_the_above

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end
