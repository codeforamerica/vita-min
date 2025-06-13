class UserPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def profile?
    user.present?
  end

  %i[destroy? update_role? show?].each do |name|
    define_method name do
      can_manage?
    end
  end

  def edit_role?
    update_role?
  end

  %i[update? unlock? suspend? resend_invitation?].each do |name|
    define_method name do
      can_manage? || site_coordinators_peer?
    end
  end

  def unsuspend?
    suspend?
  end

  private

  def record_is_current_user?
    user.id == record.id
  end

  def in_accessible_scope?
    user.accessible_users.exists?(record.id)
  end

  def can_manage?
    user.admin? || user.org_lead? || record_is_current_user?
  end

  def site_coordinators_peer?
    return false unless user.site_coordinator?

    user_ids = User.where(role: SiteCoordinatorRole.assignable_to_sites(user.role.sites)).or(
      User.where(role: TeamMemberRole.assignable_to_sites(user.role.sites))
    ).pluck(:id)
    user_ids.include?(record.id)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(id: user.accessible_users.ids + [user.id])
    end
  end
end

# # Anyone can manage their name & email address (roles are handled separately)
# can :manage, User, id: user.id
#
# # Anyone can read info about users that they can access
# can :read, User, id: user.accessible_users.pluck(:id)
#
# Organization leads can view and edit users who are organization leads, site coordinators, and team members in their coalition
# can :manage, User, id: user.accessible_users.pluck(:id) if user.org_lead?
#
# # if user.site_coordinator?
# can [:suspend, :unsuspend, :update, :unlock, :resend_invitation], User, id: User.where(role: SiteCoordinatorRole.assignable_to_sites(user.role.sites)).pluck(:id)
# can [:suspend, :unsuspend, :update, :unlock, :resend_invitation], User, id: User.where(role: TeamMemberRole.assignable_to_sites(user.role.sites)).pluck(:id)