class Ctc::Portal::VerificationAttemptsController < Ctc::Portal::BaseAuthenticatedController
  layout "intake"
  helper_method :prev_path, :illustration_path, :illustration_folder
  before_action :load_verification_attempt

  def edit
    if current_client.verification_attempts.reviewing.exists?
      redirect_to ctc_portal_root_path and return
    end
    @is_resubmission = current_client.verification_attempts.not_in_state(:new).exists?
  end

  def update
    if params[:commit] && @verification_attempt.selfie.present? && @verification_attempt.photo_identification.present?
      @verification_attempt.transition_to(:pending)
      redirect_to ctc_portal_root_path and return
    end

    @verification_attempt.update!(permitted_params)
    redirect_to action: :edit
  end

  # allows for deletion of photos from an existing attempt
  def destroy
    @verification_attempt = current_client.verification_attempts.find(params[:id])
    if @verification_attempt.blank? || !params[:photo_type].in?(["selfie", "photo_identification"])
      flash["alert"] = "You aren't authorized to take this action"
      redirect_to action: :edit
    end
    @verification_attempt.update!(params[:photo_type] => nil)
    redirect_to action: :edit
  end

  def load_verification_attempt
    @verification_attempt = current_client.verification_attempts.in_state(:new).last || current_client.verification_attempts.new
  end

  def prev_path; end

  def illustration_folder
    "questions"
  end

  def illustration_path
    "ids.svg"
  end

  def permitted_params
    params.require(:verification_attempt).permit(:selfie, :photo_identification)
  end
end
