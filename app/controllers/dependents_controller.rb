class DependentsController < ApplicationController
  before_action :require_sign_in
  helper_method :section_title

  def section_title
    "Personal Information"
  end

  def index
    @dependents = current_intake.dependents
  end

  def new
    @dependent = Dependent.new
  end

  def edit
    @dependent = Dependent.find(params[:id])
  end

  def update

  end

  def create
    @dependent = Dependent.new(dependent_params.merge(intake: current_intake))

    if @dependent.save
      redirect_to dependents_path
    else
      render :new
    end
  end

  private

  def birth_date_param_keys
    [:dob_year, :dob_month, :dob_day]
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
    begin
      Date.new(*birth_date_params.values.map(&:to_i))
    rescue ArgumentError => e
      raise error unless error.to_s == "invalid date"
      nil
    end
  end
end