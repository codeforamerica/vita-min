module StateFile
  module Questions
    class AzQualifyingOrganizationContributionsController < QuestionsController
      include ReturnToReviewConcern

      before_action :maybe_opt_out_and_continue, only: [:update, :create]
      before_action :set_contribution_count

      def index
        @credit_limit = current_intake.filing_status_mfj? ? 938 : 470
        redirect_to action: :new, return_to_review: params[:return_to_review] unless contributions.present?
      end

      def edit
        @contribution = contribution
      end

      def update
        contribution.assign_attributes(az321_contribution_params)

        if contribution.save
          redirect_to action: :index, return_to_review: params[:return_to_review]
        else
          render :edit
        end
      end

      def new
        @contribution = contributions.build(date_of_contribution_year: @filing_year)
      end

      def create
        @contribution = contributions.build
        @contribution.assign_attributes(az321_contribution_params)

        if @contribution.save(context: :az321_form_create)
          redirect_to action: :index, return_to_review: params[:return_to_review]
        else
          render :new
        end
      end

      def destroy
        if contribution.destroy
          flash[:notice] = t('.removed', charity_name: contribution.charity_name)
        end

        redirect_to action: :index, return_to_review: params[:return_to_review]
      end

      def self.navigation_actions
        [:index, :new]
      end

      private

      def contributions
        @contributions ||= current_intake.az321_contributions
      end

      def contribution
        @contribution ||= contributions.find(params[:id])
      end

      def maybe_opt_out_and_continue
        current_intake.assign_attributes(
            az321_contribution_params.fetch(:state_file_az_intake_attributes, {})
          )
        current_intake.save(context: :az321_form_create)

        if current_intake.made_az321_contributions_no?
          redirect_to next_path, return_to_review: params[:return_to_review]
        end
      end

      def set_contribution_count = @contribution_count = contributions.count

      def az321_contribution_params
        params.require(:az321_contribution).permit(
            :charity_name, :charity_code, :amount,
            :date_of_contribution_day, :date_of_contribution_month,
            :date_of_contribution_year, :made_az321_contributions,
            state_file_az_intake_attributes: [:made_az321_contributions]
          )
      end
    end
  end
end
