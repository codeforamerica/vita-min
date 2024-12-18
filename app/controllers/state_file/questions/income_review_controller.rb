module StateFile
  module Questions
    class IncomeReviewController < QuestionsController
      include ReturnToReviewConcern
      before_action :set_sorted_vars
      before_action :set_conditions

      def set_sorted_vars 
        @w2s = current_intake.state_file_w2s&.sort_by { |w2| [w2.employee_name, w2.employer_name] }
      end

      def set_conditions
        conditions = self.class.determine_conditions(current_intake)
        @show_w2s = conditions[:show_w2s]
        @show_unemployment = conditions[:show_unemployment]
        @show_retirement_income = conditions[:show_retirement_income]
        @show_interest_income = conditions[:show_interest_income]
        @show_ssa = conditions[:show_ssa]
      end

      def update
        update_for_device_id_collection(current_intake&.initial_efile_device_info)
      end

      def self.show?(intake)
        conditions = determine_conditions(intake)
        conditions.values.any?
      end

      private

      def self.determine_conditions(intake)
        {
          show_w2s: intake.state_file_w2s.present?,
          show_unemployment: intake.direct_file_data.fed_unemployment > 0 &&
                             intake.direct_file_data.mailing_state != "NJ",
          show_retirement_income: intake.state_file1099_rs.present?,
          show_interest_income: intake.direct_file_json_data.interest_reports.count > 0 &&
                                intake.direct_file_data.mailing_state != "NJ",
          show_ssa: (intake.direct_file_data.fed_ssb > 0 ||
                     intake.direct_file_data.fed_taxable_ssb > 0) &&
                     intake.direct_file_data.mailing_state != "NJ"
        }
      end
    end
  end
end
