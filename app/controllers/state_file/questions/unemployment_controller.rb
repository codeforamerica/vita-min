module StateFile
  module Questions
    class UnemploymentController < QuestionsController
      include OtherOptionsLinksConcern
      before_action :load_links, only: [:new, :edit]

      def self.show?(intake)
        fed_unemployment = intake.direct_file_data.fed_unemployment
        fed_unemployment.present? && fed_unemployment > 0
      end

      def self.navigation_actions
        [:index, :new]
      end

      def index
        @state_file1099_gs = current_intake.state_file1099_gs
        unless @state_file1099_gs.present?
          redirect_with_review_param(:new)
        end
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
          return redirect_with_review_param(:index)
        end

        if @state_file1099_g.valid?
          @state_file1099_g.save
          redirect_with_review_param(:index)
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
          redirect_with_review_param(:index)
        else
          render :new
        end
      end

      def destroy
        @state_file1099_g = current_intake.state_file1099_gs.find(params[:id])
        if @state_file1099_g.destroy
          flash[:notice] = I18n.t("state_file.questions.unemployment.destroy.removed", name: @state_file1099_g.recipient_name)
        end
        redirect_with_review_param(:index)
      end

      private

      def next_path
        income_review_or_super_path
      end

      def prev_path
        income_review_or_super_path
      end

      def income_review_or_super_path
        case params[:return_to_review].present?
        when true
          StateFile::Questions::IncomeReviewController.to_path_helper(return_to_review: params[:return_to_review])
        when false
          super
        end
      end

      def redirect_with_review_param(action)
        redirect_to action: action, return_to_review: params[:return_to_review]
      end

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
          :federal_income_tax_withheld_amount,
          :state_income_tax_withheld_amount,
          :unemployment_compensation_amount,
          :recipient_city,
          :recipient_street_address,
          :recipient_street_address_apartment,
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
