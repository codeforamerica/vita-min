class UserPolicy < ApplicationPolicy

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(id: user.accessible_users.ids + [user.id])
    end
  end

  # Collection Actions, these are scoped
  def index? = user.present?

  # Member Actions
  def profile? = record_is_current_user?
  def destroy? = can_manage?
  def update_role? = can_manage?
  def edit_role? = update_role?

  %i[unlock? suspend? resend_invitation?].each do |name|
    define_method name do
      can_manage? || site_coordinators_access?
    end
  end

  def update? = can_update?
  def unsuspend? = suspend?

  private

  def record_is_current_user?
    user.id == record.id
  end

  def in_accessible_scope?
    user.accessible_users.where(id: record.id).exists?
  end

  def can_manage?
    # Admins and Org-leads can manage accessible users
    (user.admin? || user.org_lead?) && in_accessible_scope?
  end

  def can_update?
    # Anyone can manage their own user details (roles are handled separately)
    record_is_current_user? || can_manage? || site_coordinators_access?
  end

  def site_coordinators_access?
    return false unless user.site_coordinator?

    current_user_sites = user.role.sites
    site_coordinator_ids = User.where(role: SiteCoordinatorRole.assignable_to_sites(current_user_sites)).select(:id)
    team_member_ids = User.where(role: TeamMemberRole.assignable_to_sites(current_user_sites)).select(:id)

    # site coordinator or team member users that belong to user's sites
    accessible_users = User.where(id: site_coordinator_ids).or(User.where(id: team_member_ids))

    accessible_users.where(id: record.id).exists?
  end
end