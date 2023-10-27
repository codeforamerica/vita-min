module StateFile
  module Questions
    class FederalDependentsController < QuestionsController
      def self.navigation_actions
        [:index, :new]
      end

      def index
        @dependents = current_intake.dependents
      end

      def new
        @dependent = current_intake.dependents.build
      end

      def edit
        @dependent = current_intake.dependents.find(params[:id])
      end

      def update
        @dependent = current_intake.dependents.find(params[:id])
        if @dependent.update(dependent_params)
          redirect_to action: :index
        else
          render :edit
        end
      end

      def create
        @dependent = current_intake.dependents.build(dependent_params.merge(intake: current_intake))

        if @dependent.save
          redirect_to action: :index
        else
          render :new
        end
      end

      def destroy
        @dependent = current_intake.dependents.find(params[:id])
        if @dependent.destroy
          flash[:notice] = I18n.t("controllers.dependents_controller.removed_dependent", :full_name => @dependent.full_name)
        end
        redirect_to action: :index
      end

      private

      def dependent_params
        dependent_attribute_keys = [
          :first_name,
          :last_name,
          :relationship,
        ]
        permitted_params = params.require(:state_file_dependent).permit(
          *dependent_attribute_keys, *birth_date_param_keys
        )
        attributes = permitted_params.select { |key, _| dependent_attribute_keys.include?(key.to_sym) }
        birth_date_params = permitted_params.select { |key, _| birth_date_param_keys.include?(key.to_sym) }
        attributes.merge(dob: parse_birth_date_params(birth_date_params))
      end

      def parse_birth_date_params(birth_date_params)
        birth_date_values = birth_date_params.values
        return nil if birth_date_values.any?(&:blank?)
        begin
          parsed_birth_date = Date.new(*birth_date_params.values.map(&:to_i))
        rescue ArgumentError => error
          raise error unless error.to_s == "invalid date"
          return nil
        end

        if parsed_birth_date.year < 1900 || parsed_birth_date.year > Date.today.year
          return nil
        end

        parsed_birth_date
      end

      def birth_date_param_keys
        [:dob_year, :dob_month, :dob_day]
      end

      def illustration_path; end
    end
  end
end
