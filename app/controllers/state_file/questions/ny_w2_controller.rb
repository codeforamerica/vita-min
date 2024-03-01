module StateFile
  module Questions
    class NyW2Controller < AuthenticatedQuestionsController
      def self.show?(intake)
        invalid_w2s(intake).any?
      end

      def index
        # Show the list of W2s and whether they are valid - we build this list on the fly based on existing and
        # new entries...
      end

      def edit
        # Show a single W2 to edit
        super
      end

      def update
        # Update a single W2 record
        super
      end

      def self.navigation_actions
        [:index, :edit]
      end

      def self.state_file_w2s(intake)
        # Generate a new array of unsaved W2s based on direct file data
        state_file_w2s = intake.direct_file_data.w2s.map do |df_w2|
          StateFileW2.from_df_w2(df_w2)
        end
        state_file_w2s.each_with_index do |state_file_w2, index|
          state_file_w2.index = index
        end
        # Override values in the array with any that are already persisted
        intake.state_file_w2s.each do |state_file_w2|
          state_file_w2s[state_file_w2.index] = state_file_w2
        end
        state_file_w2s
      end

      def self.invalid_w2s(intake)
        intake.direct_file_data.w2s.filter { |w2| invalid_w2?(intake, w2) }
      end

      private

      def form_params
        # We relax the form constraint here - we are gonna cherry pick the ones we want anyway
        params.fetch(form_name, {}) #.permit(*form_class.attribute_names)
      end

      def self.invalid_w2?(intake, w2)
        return true if w2.StateWagesAmt == 0
        if intake.nyc_residency_full_year?
          return true if w2.LocalWagesAndTipsAmt == 0 || w2.LocalityNm.blank?
        end
        if w2.LocalityNm.blank?
          return true if w2.LocalWagesAndTipsAmt != 0 || w2.LocalIncomeTaxAmt != 0
        end
        return true if w2.LocalIncomeTaxAmt != 0 && w2.LocalWagesAndTipsAmt == 0
        return true if w2.StateIncomeTaxAmt != 0 && w2.StateWagesAmt == 0
        return true if w2.StateWagesAmt != 0 && w2.EmployerStateIdNum.blank?
        return true if w2.LocalityNm.present? && !StateFileNyIntake::LOCALITIES.include?(w2.LocalityNm)

        false
      end
    end
  end
end
