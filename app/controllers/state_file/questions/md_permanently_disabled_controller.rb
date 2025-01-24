module StateFile
  module Questions
    class MdPermanentlyDisabledController < QuestionsController
      def self.show?(intake)
        Flipper.enabled?(:show_retirement_ui) && intake.state_file1099_rs.length.positive?
      end
    end
  end
end
