class InvitationsController < ApplicationController
  include AccessControllable

  before_action :require_sign_in
  authorize_resource :user

  layout "hub"

  def index
    @unaccepted_invitations = invited_by_current_user.order(name: :asc)
  end

  def resend_invitation
    user = invited_by_current_user.find_by(id: params[:user_id])
    flash[:notice] = if user&.invite!(current_user)
                       "Invitation re-sent to #{user.email}"
                     else
                       "Could not resend invitation."
                     end

    redirect_back(fallback_location: invitations_path)
  end

  private

  def invited_by_current_user
    User.where(id: DeviseInvitable::Invitation.pending.provisioning.where(invitable_type: "User", invited_by: current_user).select(:invitable_id))
  end
end