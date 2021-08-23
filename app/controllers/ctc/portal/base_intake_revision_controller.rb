class Ctc::Portal::BaseIntakeRevisionController < Ctc::Portal::BaseAuthenticatedController
  def edit
    @form = form_class.from_intake(current_model)
  end

  def update
    original_model = current_model.dup
    @form = form_class.new(current_model, form_params)
    if @form.valid?
      @form.save
      SystemNote::CtcPortalUpdate.generate!(
        original_model: original_model,
        model: current_model,
        client: current_client,
      )
      redirect_to Ctc::Portal::PortalController.to_path_helper(action: :edit_info)
    else
      render :edit
    end
  end

  private

  def current_model
    current_intake
  end

  def form_params
    params.fetch(form_class.model_name.param_key, {}).permit(*form_class.attribute_names)
  end
end
