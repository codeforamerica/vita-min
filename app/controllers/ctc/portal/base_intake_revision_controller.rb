class Ctc::Portal::BaseIntakeRevisionController < Ctc::Portal::BaseAuthenticatedController
  helper_method :prev_path

  def edit
    @form = form_class.from_intake(current_model)
    render edit_template
  end

  def update
    @form = form_class.new(current_model, form_params)
    if @form.valid?
      @form.save
      create_system_note
      next_path
    else
      render edit_template
    end
  end

  def edit_template
    raise StandardError, "Edit template must be defined"
  end


  private

  def next_path
    redirect_to Ctc::Portal::PortalController.to_path_helper(action: :edit_info)
  end

  def prev_path
    ctc_portal_edit_info_path
  end

  def current_model
    current_intake
  end

  def form_params
    params.fetch(form_class.model_name.param_key, {}).permit(*form_class.attribute_names)
  end

  def create_system_note
    SystemNote::CtcPortalUpdate.generate!(
      model: current_model,
      client: current_client,
      )
  end
end
