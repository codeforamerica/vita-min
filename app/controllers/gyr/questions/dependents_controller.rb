module Questions
  class DependentsController < ApplicationController
    include AuthenticatedClientConcern

    helper_method :next_path

    def self.show?(intake)
      intake.had_dependents_yes?
    end

    def self.i18n_base_path
      "views.dependents"
    end

    def self.navigation_actions
      [:index, :new]
    end

    def index
      @dependents = current_intake.dependents
    end

    def new
      @dependent = Dependent.new
    end

    def edit
      @dependent = current_intake.dependents.find(params[:id])
    end

    def update
      @dependent = current_intake.dependents.find(params[:id])
      if @dependent.update(dependent_params)
        send_mixpanel_event(event_name: "dependent_updated", data: mixpanel_data(@dependent))
        redirect_to action: :index
      else
        send_mixpanel_validation_error(@dependent.errors)
        render :edit
      end
    end

    def create
      @dependent = Dependent.new(dependent_params.merge(intake: current_intake))

      if @dependent.save
        send_mixpanel_event(event_name: "dependent_added", data: mixpanel_data(@dependent))
        redirect_to action: :index
      else
        send_mixpanel_validation_error(@dependent.errors)
        render :new
      end
    end

    def destroy
      @dependent = current_intake.dependents.find(params[:id])
      if @dependent.destroy
        flash[:notice] = I18n.t("controllers.dependents_controller.removed_dependent", :full_name => @dependent.full_name)
        send_mixpanel_event(event_name: "dependent_removed")
      end
      redirect_to action: :index
    end

    def show_progress?
      true
    end

    def progress_calculator
      IntakeProgressCalculator
    end
    helper_method :progress_calculator

    def next_path
      dependent_care_questions_path
    end

    private

    def mixpanel_data(dependent)
      {
        dependent_age_at_end_of_tax_year: dependent.age_during(MultiTenantService.new(:gyr).current_tax_year).to_s,
        dependent_under_6: dependent.age_during(MultiTenantService.new(:gyr).current_tax_year) < 6 ? "yes" : "no",
        dependent_months_in_home: dependent.months_in_home.to_s,
        dependent_was_student: dependent.was_student,
        dependent_us_citizen: dependent.us_citizen,
        dependent_north_american_resident: dependent.north_american_resident,
        dependent_disabled: dependent.disabled,
        dependent_was_married: dependent.was_married,
      }
    end

    def birth_date_param_keys
      [:birth_date_year, :birth_date_month, :birth_date_day]
    end

    def dependent_params
      dependent_attribute_keys = [
        :first_name,
        :last_name,
        :relationship,
        :months_in_home,
        :was_student,
        :us_citizen,
        :north_american_resident,
        :disabled,
        :was_married,
      ]
      permitted_params = params.require(:dependent).permit(
        *dependent_attribute_keys, *birth_date_param_keys
      )
      attributes = permitted_params.select { |key, _| dependent_attribute_keys.include?(key.to_sym) }
      birth_date_params = permitted_params.select { |key, _| birth_date_param_keys.include?(key.to_sym) }
      attributes.merge(birth_date: parse_birth_date_params(birth_date_params))
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
  end
end
