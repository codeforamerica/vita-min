module StateFile
  module Questions
    class AzPublicSchoolContributionsController < QuestionsController
      include ReturnToReviewConcern
      before_action :load_filing_year, only: [:new, :create, :edit, :update]

      def self.navigation_actions
        [:index, :new]
      end

      def index
        @az322_contributions = current_intake.az322_contributions
        unless @az322_contributions.present?
          redirect_to action: :new
        end
      end

      def new
        @az322_contribution = current_intake.az322_contributions.build
      end

      def create
        @az322_contribution = current_intake.az322_contributions.build(az322_contribution_params)
        @az322_contributions = current_intake.az322_contributions
        if @az322_contribution.made_contribution_no?
          return redirect_to next_path
        end

        if @az322_contribution.valid?
          @az322_contribution.save
          redirect_to action: :index, return_to_review: params[:return_to_review]
        else
          render :new
        end
      end

      def edit
        @az322_contribution = current_intake.az322_contributions.find(params[:id])
      end

      def update
        @az322_contribution = current_intake.az322_contributions.find(params[:id])
        @az322_contribution.assign_attributes(az322_contribution_params)

        if @az322_contribution.made_contribution_no?
          @az322_contribution.destroy
          return redirect_to action: :index, return_to_review: params[:return_to_review]
        end

        if @az322_contribution.valid?
          @az322_contribution.save
          redirect_to action: :index, return_to_review: params[:return_to_review]
        else
          render :edit
        end
      end

      def destroy
        @az322_contribution = current_intake.az322_contributions.find(params[:id])
        if @az322_contribution.destroy
          flash[:notice] = I18n.t("state_file.questions.az_public_school_contributions.destroy.removed", school_name: @az322_contribution.school_name)
        end
        redirect_to action: :index, return_to_review: params[:return_to_review]
      end

      private

      def az322_contribution_params
        params.require(:az322_contribution).permit(
          :made_contribution,
          :school_name,
          :ctds_code,
          :district_name,
          :amount,
          :date_of_contribution_day,
          :date_of_contribution_month,
          :date_of_contribution_year
        )
      end

      def load_filing_year
        @filing_year = Rails.configuration.statefile_current_tax_year
      end
    end
  end
end
