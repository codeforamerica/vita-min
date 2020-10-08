class Users::InvitationsController < Devise::InvitationsController
  include AccessControllable

  # Devise::InvitationsController from devise-invitable uses some before_actions to validate
  # data being passed in. We skip those and use our before_action methods to customize
  # access control and error messages.
  skip_before_action :authenticate_inviter!
  skip_before_action :has_invitations_left?
  skip_before_action :resource_from_invitation_token

  before_action :require_sign_in, only: [:new]
  before_action only: [:create] do
    # If an anonymous user tries to send an invitation, send them to the invitation page after sign-in.
    require_sign_in(redirect_after_login: new_user_invitation_path)
  end

  authorize_resource :user, only: [:new, :create]
  before_action :require_valid_invitation_token, only: [:edit, :update]

  def edit
    @timezone_options = ActiveSupport::TimeZone.country_zones("us").map { |tz| [tz.name, tz.tzinfo.name] }
    super
  end

  def create
    super do |invited_user|
      # set default values
      invited_user.update(is_beta_tester: true, role: invited_user.role || "agent" )
    end
  end

  private

  # Override superclass method for default params for newly created invites, allowing us to add attributes
  def invite_params
    params.require(:user).permit(:name, :email, :vita_partner_id)
  end

  # Override superclass method for accepted invite params, allowing us to add attributes
  def update_resource_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :invitation_token, :timezone)
  end

  # Path after successfully sending an invite
  def after_invite_path_for(_user)
    invitations_path
  end

  # Path after accepting an invite and setting a password
  def after_accept_path_for(_user)
    user_profile_path
  end

  # replaces #resource_from_invitation_token so we can render a not_found template if the token is bad
  def require_valid_invitation_token
    unless raw_invitation_token.present? && get_user_by_invitation_token
      render :not_found, status: :not_found
    end
  end

  def raw_invitation_token
    # on GET invitation_token is a top-level query param
    return params[:invitation_token] if action_name == "edit"
    update_resource_params[:invitation_token]
  end

  def get_user_by_invitation_token
    self.resource = resource_class.find_by_invitation_token(raw_invitation_token, true)
  end
end
