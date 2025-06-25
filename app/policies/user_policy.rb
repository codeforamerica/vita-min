class UserPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def create?
    admin_or_manager_or_lead? || site_coordinator?
  end

  def show?
    same_user? || in_accessible_scope?
  end
  alias read? show?

  def update?
    admin? || client_success? || lead_or_coordinator_for_record?
  end
  alias edit? update?

  def destroy?
    admin?
  end

  def unlock?
    update?
  end

  def suspend?
    site_coordinator_for_record? || admin?
  end
  alias unsuspend? suspend?

  def resend_invitation?
    admin?
  end

  def profile?
    same_user?
  end

  def edit_role?
    user.present?
  end

  def update_role?
    user.present?
  end

  class Scope < Scope
    def resolve
      scope.where(id: user.accessible_users.select(:id))
    end
  end

  private

  def admin? = user.admin?

  def client_success? = user.client_success?

  def coalition_lead? = user.coalition_lead?

  def org_lead? = user.org_lead?

  def site_coordinator? = user.site_coordinator?

  def greeter? = user.greeter?

  def team_member = user.team_member?

  def admin_or_manager_or_lead?
    admin? || client_success? || coalition_lead? || org_lead?
  end

  def same_user?
    user.id == record.id
  end

  def in_accessible_scope?
    user.accessible_users.exists?(record.id)
  end

  def lead_or_coordinator_for_record?
    coalition_lead_for_record? || org_lead_for_record? || site_coordinator_for_record?
  end

  def coalition_lead_for_record?
    coalition_lead? && user.accessible_users.exists?(record.id)
  end

  def org_lead_for_record?
    org_lead? && user.accessible_users.exists?(record.id)
  end

  def site_coordinator_for_record?
    return false unless site_coordinator?
    user_ids = User.where(role: SiteCoordinatorRole.assignable_to_sites(user.role.sites)).or(
      User.where(role: TeamMemberRole.assignable_to_sites(user.role.sites))
    ).pluck(:id)
    user_ids.include?(record.id)
  end
end
