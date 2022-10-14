class Ctc::Portal::W2s::BaseController < Ctc::Portal::BaseIntakeRevisionController
  private

  def generate_system_note
    if @new_record
      SystemNote::CtcPortalAction.generate!(
        model: current_model,
        action: 'created',
        client: current_client
      )
    else
      SystemNote::CtcPortalUpdate.generate!(
        model: current_model,
        client: current_client,
      )
    end
  end
end
