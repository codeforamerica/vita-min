module StateFile
  module Questions
    class AzPublicSchoolContributionsController < QuestionsController
      include ReturnToReviewConcern

      before_action :set_contribution_count

      def self.navigation_actions
        [:index, :new]
      end

      def index
        @az322_contributions = current_intake.az322_contributions
        unless @az322_contributions.present?
          build_contribution
          render :new
        end
      end

      def new
        build_contribution
      end

      def build_contribution
        @az322_contribution = current_intake.az322_contributions.build
      end

      def create
        @az322_contribution = current_intake.az322_contributions.build
        @az322_contribution.assign_attributes(az322_contribution_params)

        if came_from_old_page || (current_intake.valid?(:az322_form_create) && @az322_contribution.valid?)
          @az322_contribution.save
          redirect_to action: :index, return_to_review: params[:return_to_review]
        else
          render :new
        end
      end

      # remove this after it has been deployed
      def came_from_old_page
        params["az322_contribution"].include?("made_contribution") && current_intake.valid? && @az322_contribution.valid?
      end

      def edit
        @az322_contribution = current_intake.az322_contributions.find(params[:id])
      end

      def update
        @az322_contribution = current_intake.az322_contributions.find(params[:id])
        @az322_contribution.assign_attributes(az322_contribution_params)

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

      def contributions
        @contributions ||= current_intake.az322_contributions
      end

      def set_contribution_count = @contribution_count = contributions.count

      def az322_contribution_params
        params.require(:az322_contribution).permit(
          :school_name,
          :ctds_code,
          :district_name,
          :amount,
          :date_of_contribution_day,
          :date_of_contribution_month,
          :date_of_contribution_year,
          state_file_az_intake_attributes: [:made_az322_contributions]
        )
      end
    end
  end
end
