module Gyr
  module Questions
    class AdoptedChildController < ::Questions::QuestionsController
      include AuthenticatedClientConcern

      def self.show?(intake)
        intake.had_dependents_yes?
      end

      layout "yes_no_question"
    end
  end
end