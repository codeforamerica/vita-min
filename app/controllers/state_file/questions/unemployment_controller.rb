module StateFile
  module Questions
    class UnemploymentController < QuestionsController
      def self.show?(intake)
        intake.direct_file_data.fed_unemployment > 0
      end

      def self.navigation_actions
        [:new, :index]
      end

      def index
        @state_file1099_gs = current_intake.state_file1099_gs
      end

      def new
        @state_file1099_g = current_intake.state_file1099_gs.build
      end

      def edit
        @state_file1099_g = current_intake.state_file1099_gs.find(params[:id])
      end

      def update
        @state_file1099_g = current_intake.state_file1099_gs.find(params[:id])
        @state_file1099_g.assign_attributes(state_file1099_params)

        if @state_file1099_g.had_box_11_no?
          @state_file1099_g.destroy
          return redirect_to action: :index
        end

        if @state_file1099_g.valid?
          @state_file1099_g.save
          redirect_to action: :index
        else
          render :edit
        end
      end

      def create
        @state_file1099_g = current_intake.state_file1099_gs.build(state_file1099_params)
        if @state_file1099_g.had_box_11_no?
          return redirect_to next_path
        end

        if @state_file1099_g.valid?
          @state_file1099_g.save
          redirect_to action: :index
        else
          render :new
        end
      end

      def destroy
        @state_file1099_g = current_intake.state_file1099_gs.find(params[:id])
        if @state_file1099_g.destroy
          flash[:notice] = I18n.t("state_file.questions.unemployment.destroy.removed", name: @state_file1099_g.recipient_name)
        end
        redirect_to action: :index
      end

      private

      def state_file1099_params
        state_file_params = params.require(:state_file1099_g).permit(
          :had_box_11,
          :address_confirmation,
          :recipient,
          :payer_city,
          :payer_name,
          :payer_street_address,
          :payer_tin,
          :payer_zip,
          :federal_income_tax_withheld,
          :state_income_tax_withheld,
          :unemployment_compensation,
          :recipient_city,
          :recipient_street_address,
          :recipient_zip,
          :state_identification_number
        )
        unless current_intake.filing_status_mfj?
          state_file_params[:recipient] = 'primary'
        end
        state_file_params
      end
    end
  end
end
