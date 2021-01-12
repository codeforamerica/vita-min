class InvitationsController < ApplicationController
  include AccessControllable

  before_action :require_sign_in
  load_and_authorize_resource :user, only: :resend, parent: false

  layout "admin"

  def index
    @unaccepted_invitations = User.where(invited_by: current_user, invitation_accepted_at: nil)
  end

  def resend
    if @user.invitation_accepted_at.present?
      flash[:warning] = I18n.t("invitations.resend.cannot_because_accepted")
    else
      @user.invite!
      flash[:notice] = I18n.t("devise.invitations.send_instructions", email: @user.email)
    end
    redirect_to invitations_path
  end
end
