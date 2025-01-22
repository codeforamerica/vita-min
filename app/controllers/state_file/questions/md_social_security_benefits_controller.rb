module StateFile
  module Questions
    class MdSocialSecurityBenefitsController < QuestionsController
      def self.show?(intake)
        Flipper.enabled?(:show_md_ssa) &&
        intake.filing_status_mfj? && intake.direct_file_data.fed_ssb.positive?
      end

      def edit
        super
        @total_ssb = current_intake.direct_file_data.fed_ssb || 0
      end
    end
  end
end
