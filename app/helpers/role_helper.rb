module RoleHelper
  def user_role(user)
    case user.role_type
    when AdminRole::TYPE
      I18n.t("general.admin")
    when OrganizationLeadRole::TYPE
      I18n.t("general.organization_lead")
    when CoalitionLeadRole::TYPE
      I18n.t("general.coalition_lead")
    when SiteCoordinatorRole::TYPE
      I18n.t("general.site_coordinator")
    when ClientSuccessRole::TYPE
      I18n.t("general.client_success")
    when GreeterRole::TYPE
      I18n.t("general.greeter")
    when TeamMemberRole::TYPE
      I18n.t("general.team_member")
    end
  end

  def user_group(user)
    if user.role_type == OrganizationLeadRole::TYPE
      user.role.organization.name
    elsif user.role_type == CoalitionLeadRole::TYPE
      user.role.coalition.name
    elsif user.role_type == SiteCoordinatorRole::TYPE || user.role_type == TeamMemberRole::TYPE
      user.role.site.name
    end
  end
end
