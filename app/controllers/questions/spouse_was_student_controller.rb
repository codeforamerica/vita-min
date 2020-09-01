module Questions
  class SpouseWasStudentController < TicketedQuestionsController
    layout "yes_no_question"

    def self.show?(intake)
      false
    end

    def illustration_path
      "was-student.svg"
    end
  end
end