class Ctc::Portal::VerificationAttemptsController < Ctc::Portal::BaseAuthenticatedController
  layout "intake"
  helper_method :prev_path, :illustration_path, :illustration_folder
  before_action :load_verification_attempt
  before_action :redirect_if_cant_update_attempt
  skip_before_action :redirect_if_read_only, only: [:edit, :paper_file]

  def edit
    @is_resubmission = current_client.verification_attempts.not_in_state(:new).exists?
  end

  def update
    if params[:commit]
      if @verification_attempt.selfie.present? && @verification_attempt.photo_identification.present?
        @verification_attempt.transition_to!(:pending)
        redirect_to ctc_portal_root_path and return
      else
        redirect_to action: :edit and return
      end
    end
    @verification_attempt.assign_attributes(permitted_params)

    if @verification_attempt.valid?
      @verification_attempt.save
      redirect_to action: :edit
    else
      render :edit
    end
  end

  def paper_file
    @submission = current_client.efile_submissions.last
  end

  # allows for deletion of photos from an existing attempt
  def destroy
    @verification_attempt = current_client.verification_attempts.find_by(id: params[:id])
    if @verification_attempt.blank? || !params[:photo_type].in?(["selfie", "photo_identification"])
      flash["alert"] = I18n.t("general.access_denied")
      redirect_to action: :edit and return
    end
    @verification_attempt.send(params[:photo_type]).purge_later
    redirect_to action: :edit
  end

  private

  def load_verification_attempt
    @verification_attempt = current_client.verification_attempts.in_state(:new).last || current_client.verification_attempts.new
  end

  def redirect_if_cant_update_attempt
    if current_client.identity_decision_made? || current_client.verification_attempts.reviewing.exists?
      redirect_to ctc_portal_root_path
    end
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
