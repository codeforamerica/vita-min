class DependentsController < ApplicationController
  include AuthenticatedClientConcern

  helper_method :next_path

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
      send_mixpanel_event(event_name: "dependent_updated", data: @dependent.mixpanel_data)
      redirect_to dependents_path
    else
      send_mixpanel_validation_error(@dependent.errors)
      render :edit
    end
  end

  def create
    @dependent = Dependent.new(dependent_params.merge(intake: current_intake))

    if @dependent.save
      send_mixpanel_event(event_name: "dependent_added", data: @dependent.mixpanel_data)
      redirect_to dependents_path
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
    redirect_to dependents_path
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
      :on_visa,
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
      Date.new(*birth_date_params.values.map(&:to_i))
    rescue ArgumentError => error
      raise error unless error.to_s == "invalid date"
      nil
    end
  end
end
