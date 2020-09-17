class Users::InvitationsController < Devise::InvitationsController
  include AccessControllable

  # skip inherited methods
  skip_before_action :authenticate_inviter!
  skip_before_action :has_invitations_left?
  skip_before_action :resource_from_invitation_token

  # use our own access control methods
  before_action :require_sign_in, only: [:new]
  before_action only: [:create] do
    require_sign_in(redirect_after_login: new_user_invitation_path)
  end
  before_action :require_admin, only: [:new, :create]
  before_action :require_valid_invitation_token, only: [:edit, :update]

  private

  # Overwrites default params for newly created invites, allowing us to add attributes
  def invite_params
    params.require(:user).permit(:name, :email).merge(role: "agent")
  end

  # Overwrites default params for accepted invites, allowing us to add attributes
  def update_resource_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :invitation_token)
  end

  # Path after successfully sending an invite
  def after_invite_path_for(_user)
    invitations_path
  end

  # Path after accepting an invite and setting a password
  def after_accept_path_for(_user)
    user_profile_path
  end

  def require_valid_invitation_token
    unless raw_invitation_token.present? && get_user_by_invitation_token
      render :not_found, status: :not_found
    end
  end

  def raw_invitation_token
    return params[:invitation_token] if request.get?
    update_resource_params[:invitation_token]
  end

  def get_user_by_invitation_token
    self.resource = resource_class.find_by_invitation_token(raw_invitation_token, true)
  end
end
