module RoleHelper
  def user_role(user)
    [
      *(I18n.t("general.admin") if user.role_type == AdminRole::TYPE),
      *(I18n.t("general.organization_lead") if user.role_type == OrganizationLeadRole::TYPE),
      *(I18n.t("general.coalition_lead") if user.role_type == CoalitionLeadRole::TYPE),
      *(I18n.t("general.site_coordinator") if user.role_type == SiteCoordinatorRole::TYPE),
      *(I18n.t("general.client_success") if user.role_type == ClientSuccessRole::TYPE),
      *(I18n.t("general.greeter") if user.role_type == GreeterRole::TYPE),
    ].join(", ")
  end

  def user_group(user)
    if user.role_type == OrganizationLeadRole::TYPE
      user.role.organization.name
    elsif user.role_type == CoalitionLeadRole::TYPE
      user.role.coalition.name
    elsif user.role_type == SiteCoordinatorRole::TYPE
      user.role.site.name
    end
  end
end
