module StateFile
  module Questions
    class UnemploymentController < QuestionsController
      def self.navigation_actions
        [:new, :index]
      end

      def index
        ap current_intake.state_file1099s
        @state_file1099s = current_intake.state_file1099s
      end

      def new
        @state_file1099 = current_intake.state_file1099s.build
      end

      def edit
        @state_file1099 = current_intake.state_file1099s.find(params[:id])
      end

      def update
        @state_file1099 = current_intake.state_file1099s.find(params[:id])
        @state_file1099.assign_attributes(state_file1099_params)
        if @state_file1099.valid?
          @state_file1099.save
          redirect_to action: :index
        else
          render :edit
        end
      end

      def create
        @state_file1099 = current_intake.state_file1099s.build(state_file1099_params)
        if @state_file1099.valid?
          @state_file1099.save
          redirect_to action: :index
        else
          render :new
        end
      end

      def destroy
        @state_file1099 = current_intake.state_file1099s.find(params[:id])
        if @state_file1099.destroy
          flash[:notice] = I18n.t("state_file.questions.unemployment.destroy.removed", name: @state_file1099.recipient_name)
        end
        redirect_to action: :index
      end

      private

      def state_file1099_params
        params.require(:state_file1099).permit(
          :had_box_11,
          :address_confirmation,
          :payer_name_is_default,
          :recipient,
          :payer_name,
          :federal_income_tax_withheld,
          :state_income_tax_withheld,
          :unemployment_compensation,
          :recipient_city,
          :recipient_state,
          :recipient_street_address,
          :recipient_zip
        )
      end
    end
  end
end
