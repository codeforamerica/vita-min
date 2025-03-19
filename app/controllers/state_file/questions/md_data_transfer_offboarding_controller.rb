module StateFile
  module Questions
    class MdDataTransferOffboardingController < QuestionsController

      def self.show?(intake)
        intake.nra_spouse?
      end
    end
  end
end