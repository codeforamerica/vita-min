class InvitationsController < ApplicationController
  include AccessControllable

  before_action :require_sign_in
  load_and_authorize_resource :user, only: :resend

  layout "admin"

  def index
    @unaccepted_invitations = User.where(invited_by: current_user, invitation_accepted_at: nil)
  end

  def resend
    @user.invite!
  end
end