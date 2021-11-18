class InvitationsController < ApplicationController
  include AccessControllable

  before_action :require_sign_in
  authorize_resource :user

  layout "hub"

  def index
    @unaccepted_invitations = User.where(invited_by: current_user, invitation_accepted_at: nil).order(name: :asc)
  end

  def resend_invitation
    user = User.find_by(id: params[:user_id], invited_by: current_user)
    flash[:notice] = if user&.invite!(current_user)
                       "Invitation re-sent to #{user.email}"
                     else
                       "Could not resend invitation."
                     end

    redirect_back(fallback_location: invitations_path)
  end
end