class Ctc::Portal::DependentsController < Ctc::Portal::BaseIntakeRevisionController
  def edit
    @form = form_class.from_dependent(current_model)
  end

  def confirm_remove
  end

  def destroy
    current_model.update(soft_deleted_at: Time.current)
    SystemNote::CtcPortalAction.generate!(
      model: current_model,
      action: 'removed',
      client: current_client
    )

    redirect_to Ctc::Portal::PortalController.to_path_helper(action: :edit_info)
  end

  private

  def current_model
    @_current_model ||= current_intake.dependents.find(params[:id])
  end
  helper_method :current_model

  def form_class
    Ctc::Portal::DependentForm
  end
end
