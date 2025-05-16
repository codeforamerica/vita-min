class RolePolicy < ApplicationPolicy
  def create?
    user.admin? || user.coalition_lead? ||
      user.org_lead? || user.site_coordinator?
  end
end
