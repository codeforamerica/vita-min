class InvitationsController < ApplicationController
  include AccessControllable

  before_action :require_sign_in
  before_action :require_beta_tester

  layout "admin"

  def index
    @unaccepted_invitations = User.where(invited_by: current_user, invitation_accepted_at: nil)
  end
end