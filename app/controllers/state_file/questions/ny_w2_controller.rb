module StateFile
  module Questions
    class NyW2Controller < AuthenticatedQuestionsController
      before_action :load_w2s
      before_action :load_w2, only: [:edit, :update]

      def self.show?(intake)
        Flipper.enabled?(:w2_override) && invalid_w2s(intake).any?
      end

      def index
        if @w2s.length == 1
          redirect_to action: :edit, id: @w2s[0].w2_index
        end
        get_w2s_with_metadata
      end

      def create
        # The below line triggers validation on all w2s...
        @errors_present = @w2s.select { |w2| !w2.valid? }.present?
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
          redirect_to next_path and return if @w2s.length == 1
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
          return path_for_step(self.class)
        end
        super
      end

      def self.w2s_for_intake(intake)
        (intake.direct_file_data.w2s.each_with_index.map do |w2, index|
          if invalid_w2?(intake, w2)
            existing_record = intake.state_file_w2s.find { |intake_w2| intake_w2.w2_index == index }
            existing_record.present? ? existing_record : StateFileW2.new(state_file_intake: intake, w2_index: index)
          end
        end).compact
      end

      def self.invalid_w2s(intake)
        intake.direct_file_data.w2s.filter { |w2| invalid_w2?(intake, w2) }
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
        return true if w2.LocalityNm.present? && !StateFileNyIntake.locality_nm_valid?(w2.LocalityNm.upcase)
        return true if w2.EmployerStateIdNum.present? && w2.StateAbbreviationCd.blank?
        return true if w2.StateIncomeTaxAmt > w2.StateWagesAmt
        return true if w2.LocalIncomeTaxAmt > w2.LocalWagesAndTipsAmt
        return true if w2.StateIncomeTaxAmt + w2.LocalIncomeTaxAmt > w2.WagesAmt
        false
      end
    end
  end
end
