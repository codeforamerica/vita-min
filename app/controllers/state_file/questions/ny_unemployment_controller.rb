module StateFile
  module Questions
    class NyUnemploymentController < QuestionsController
      def self.navigation_actions
        [:new, :index]
      end

      def index
        @state_file1099s = current_intake.state_file1099s
      end

      def new
        @state_file1099 = StateFile1099.new
      end

      def edit
        @state_file1099 = current_intake.state_file1099s.find(params[:id])
      end

      def update
        @state_file1099 = current_intake.state_file1099s.find(params[:id])
        if @state_file1099.update(dependent_params)
          redirect_to action: :index
        else
          render :edit
        end
      end

      def create
        @state_file1099 = Dependent.new(dependent_params.merge(intake: current_intake))

        if @state_file1099.save
          redirect_to action: :index
        else
          render :new
        end
      end

      def destroy
        @state_file1099 = current_intake.state_file1099s.find(params[:id])
        if @state_file1099.destroy
          # flash[:notice] = I18n.t("controllers.dependents_controller.removed_dependent", :full_name => @dependent.full_name)
        end
        redirect_to action: :index
      end

      private
    end
  end
end
