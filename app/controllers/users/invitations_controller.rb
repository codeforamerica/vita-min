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
  before_action :load_and_authorize_groups, only: [:new, :create]
  before_action :load_and_authorize_role, only: [:create]

  authorize_resource :user, only: [:new, :create]
  before_action :require_valid_invitation_token, only: [:edit, :update]

  def create
    if user_already_exists?
      flash[:alert] = "Cannot invite #{invite_params[:email]} - user already exists."
      redirect_to invitations_path and return
    end

    super
  end

  private

  def user_already_exists?
    User.find_by(email: invite_params[:email]).present?
  end

  def load_and_authorize_groups
    @vita_partners = current_user.accessible_vita_partners
    @coalitions = current_user.accessible_coalitions
  end

  def load_and_authorize_role
    @role =
      case params.dig(:user, :role)
      when OrganizationLeadRole::TYPE
        OrganizationLeadRole.new(organization: @vita_partners.find(params.require(:organization_id)))
      when CoalitionLeadRole::TYPE
        CoalitionLeadRole.new(coalition: @coalitions.find(params.require(:coalition_id)))
      when AdminRole::TYPE
        AdminRole.new
      when SiteCoordinatorRole::TYPE
        SiteCoordinatorRole.new(site: @vita_partners.find(params.require(:site_id)))
      when ClientSuccessRole::TYPE
        ClientSuccessRole.new
      when GreeterRole::TYPE
        GreeterRole.new(
          organizations: @vita_partners.organizations.where(allows_greeters: true),
        )
      when TeamMemberRole::TYPE
        TeamMemberRole.new(site: @vita_partners.sites.find(params.require(:site_id)))
      end

    authorize!(:create, @role)
  end

  # Override superclass method for default params for newly created invites, allowing us to add attributes
  def invite_params
    params.require(:user).permit(:name, :email).merge(role: @role)
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
    hub_user_profile_path
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
