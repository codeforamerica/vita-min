module StateFile
  module Questions
    class W2Controller < AuthenticatedQuestionsController
      include ReturnToReviewConcern
      before_action :load_w2s
      before_action :load_w2, only: [:edit, :update]

      def self.show?(intake)
        invalid_df_w2s(intake).any?
      end

      def index
        if @w2s.length == 1
          redirect_to action: :edit, id: @w2s[0].w2_index
        end
        get_w2s_with_metadata
      end

      def create
        # The below line must be a select to trigger validation on all w2s...
        @errors_present = @w2s.select { |w2| !w2.persisted? || !w2.valid? }.present?
        if @errors_present
          get_w2s_with_metadata
          render :index
          return
        end
        redirect_to next_path
      end

      def edit
      end

      def update
        @w2.assign_attributes(form_params)

        if @w2.valid?
          @w2.save
          redirect_to next_path and return if @w2s.length == 1 || params[:return_to_review].present?
          redirect_to action: :index
        else
          render :edit
        end
      end

      def self.navigation_actions
        [:index]
      end

      def form_params
        params.require(StateFileW2.name.underscore)
              .except(:state_file_intake_id, :state_file_intake_type)
              .permit(*StateFileW2.attribute_names)
      end

      def get_w2s_with_metadata
        @w2s_with_metadata ||= @w2s.map do |w2|
          dfw2 = w2.state_file_intake.direct_file_data.w2s[w2.w2_index]
          {
            w2: w2,
            employer_name: dfw2.EmployerName,
            wages_amount: dfw2.WagesAmt,
          }
        end
      end

      def load_w2s
        @w2s = self.class.w2s_for_intake(current_intake)
      end

      def load_w2
        w2_index = params[:id].to_i
        @w2 = @w2s.detect { |w2| w2.w2_index == w2_index }
        dfw2 = @w2.state_file_intake.direct_file_data.w2s[@w2.w2_index]
        @employer_name = dfw2.EmployerName
        @wages_amt = dfw2.WagesAmt
      end

      def prev_path
        if @w2s.length > 1 && ["update", "edit"].include?(action_name)
          return self.class.to_path_helper(action: :index, return_to_review: params[:return_to_review])
        end
        super
      end

      def self.w2s_for_intake(intake)
        (intake.direct_file_data.w2s.each_with_index.map do |df_w2, index|
          if intake.invalid_df_w2?(df_w2)
            existing_record = intake.state_file_w2s.find { |intake_w2| intake_w2.w2_index == index }
            if existing_record.present?
              existing_record
            else
              StateFileW2.new(
                state_file_intake: intake,
                w2_index: index,
                employer_state_id_num: df_w2.EmployerStateIdNum,
                state_wages_amt: df_w2.StateWagesAmt,
                state_income_tax_amt: df_w2.StateIncomeTaxAmt,
                local_wages_and_tips_amt: df_w2.LocalWagesAndTipsAmt,
                local_income_tax_amt: df_w2.LocalIncomeTaxAmt,
                locality_nm: df_w2.LocalityNm
              )
            end
          end
        end).compact
      end

      def self.invalid_df_w2s(intake)
        intake.direct_file_data.w2s.filter { |df_w2| intake.invalid_df_w2?(df_w2) }
      end

    end
  end
end
