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
  # This line does not do what i would like it to do :(
  # was hoping to get a @vita_partners that matched the current user's organization (to be used in vita_partner_helper)
  # load_and_authorize_resource :vita_partner, through: :user
  before_action :require_valid_invitation_token, only: [:edit, :update]

  # maybe this is the way instead?
  # def new
  #   @vita_partners = current_user.accessible_organizations
  #   super
  # end

  def create
    super do |invited_user|
      # set default values
      invited_user.update(role: invited_user.role || "agent")
    end
  end

  private

  # Override superclass method for default params for newly created invites, allowing us to add attributes
  def invite_params
    vita_partner_id = params.require(:user).require(:vita_partner_id)
    vita_partner = VitaPartner.find(vita_partner_id)
    if current_ability.can?(:manage, vita_partner)
      params.require(:user).permit(:name, :email, :vita_partner_id)
    end
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
