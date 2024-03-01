module StateFile
  module Questions
    class NyW2Controller < AuthenticatedQuestionsController
      before_action :create_w2_list

      def self.show?(intake)
        get_w2s_for_intake(intake).any? { |w2| !w2.valid? }
      end

      def index
        # Show the list of W2s and whether they are valid - we build this list on the fly based on existing and
        # new entries...
      end

      def edit
        @w2 = @w2s[params[:id].to_i]
        dfw2 = @w2.state_file_intake.direct_file_data.w2s[@w2.w2_index]
        @employer_name = dfw2.EmployerName
        @wages_amt = dfw2.WagesAmt
      end

      def update
        @w2 = @w2s[params[:id].to_i]
        @w2.assign_attributes(form_params)

        if @w2.valid?
          @w2.save
          redirect_to action: :index
        else
          render :edit
        end
      end

      def self.navigation_actions
        [:index, :edit]
      end

      def create_w2_list
        # Generate a new array of unsaved W2s based on direct file data
        @w2s = self.class.get_w2s_for_intake(current_intake)
      end

      def self.get_w2s_for_intake(intake)
        # instantiates new StateFileW2 with fields from direct file xml
        w2s = intake.direct_file_data.w2s.map do |df_w2|
          StateFileW2.from_df_w2(df_w2)
        end
        # sets w2_index and associated intake on each StateFileW2
        w2s.each_with_index do |state_file_w2, index|
          state_file_w2.w2_index = index
          state_file_w2.state_file_intake = intake
        end
        # replaces w2s from df xml with any that are already persisted in our db
        intake.state_file_w2s.each do |state_file_w2|
          w2s[state_file_w2.w2_index] = state_file_w2
        end
        w2s
      end

      # def self.invalid_w2s(intake)
      #   intake.direct_file_data.w2s.filter { |w2| invalid_w2?(intake, w2) }
      # end

      # private

      # def next_step
      #   # Edits on this redirect back to index
      #   #@w2s.detect { |w2| !w2.valid? }.present? ? self.class : super
      #   self.class
      # end

      def form_params
        params.require(StateFileW2.name.underscore).permit(*StateFileW2.attribute_names)
      end

      # def form_class
      #   StateFileW2
      # end

      #def form_params
        # We relax the form constraint here - we are gonna cherry pick the ones we want anyway
      #  params.fetch(form_name, {}) #.permit(*form_class.attribute_names)
      #end

      # def self.invalid_w2?(intake, w2)
      #   return true if w2.StateWagesAmt == 0
      #   if intake.nyc_residency_full_year?
      #     return true if w2.LocalWagesAndTipsAmt == 0 || w2.LocalityNm.blank?
      #   end
      #   if w2.LocalityNm.blank?
      #     return true if w2.LocalWagesAndTipsAmt != 0 || w2.LocalIncomeTaxAmt != 0
      #   end
      #   return true if w2.LocalIncomeTaxAmt != 0 && w2.LocalWagesAndTipsAmt == 0
      #   return true if w2.StateIncomeTaxAmt != 0 && w2.StateWagesAmt == 0
      #   return true if w2.StateWagesAmt != 0 && w2.EmployerStateIdNum.blank?
      #   return true if w2.LocalityNm.present? && !StateFileNyIntake::LOCALITIES.include?(w2.LocalityNm)
      #
      #   false
      # end
    end
  end
end
