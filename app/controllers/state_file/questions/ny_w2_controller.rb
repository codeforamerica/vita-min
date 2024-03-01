module StateFile
  module Questions
    class NyW2Controller < AuthenticatedQuestionsController
      before_action :create_w2_list

      def self.show?(intake)
        invalid_w2s(intake).any?
      end

      def index
        # Show the list of W2s and whether they are valid - we build this list on the fly based on existing and
        # new entries...
      end

      def edit
        # Show a single W2 to edit
        @form = @w2s[params[:index].to_i]
      end

      def self.navigation_actions
        [:index, :edit]
      end

      def create_w2_list
        # Generate a new array of unsaved W2s based on direct file data
        @w2s = current_intake.direct_file_data.w2s.map do |df_w2|
          StateFileW2.from_df_w2(df_w2)
        end
        @w2s.each_with_index do |state_file_w2, index|
          state_file_w2.index = index
        end
        # Override values in the array with any that are already persisted
        current_intake.state_file_w2s.each do |state_file_w2|
          @w2s[state_file_w2.index] = state_file_w2
        end
      end

      def self.invalid_w2s(intake)
        intake.direct_file_data.w2s.filter { |w2| invalid_w2?(intake, w2) }
      end

      private

      def next_step
        # Edits on this redirect back to index
        #@w2s.detect { |w2| !w2.valid? }.present? ? self.class : super
        self.class
      end

      def form_params
        params.require(StateFileW2.name.underscore).permit(*StateFileW2.attribute_names)
      end

      def form_class
        StateFileW2
      end

      #def form_params
        # We relax the form constraint here - we are gonna cherry pick the ones we want anyway
      #  params.fetch(form_name, {}) #.permit(*form_class.attribute_names)
      #end

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
