module StateFile
  module Questions
    class MdPermanentlyDisabledController < QuestionsController
      # def self.show?(intake)
      #   # Flipper.enabled?(:show_retirement_ui) && intake.state_file1099_rs.length.positive?
      # end
      def form_params
        params.require(:state_file_md_permanently_disabled_form).permit(:mfj_disability, :primary_disabled, :spouse_disabled, :proof_of_disability_submitted)
      end
    end
  end
end
