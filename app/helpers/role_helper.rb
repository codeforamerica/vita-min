module RoleHelper
  def user_role(user)
    [
      *(I18n.t("general.admin") if user.role_type == AdminRole::TYPE),
      *(I18n.t("general.client_support") if user.is_client_support),
      *(I18n.t("general.organization_lead") if user.role_type == OrganizationLeadRole::TYPE),
      *(I18n.t("general.coalition_lead") if user.role_type == CoalitionLeadRole::TYPE)
    ].join(", ")
  end

  def user_group(user)
    if user.role_type == OrganizationLeadRole::TYPE
      user.role.organization.name
    elsif user.role_type == CoalitionLeadRole::TYPE
      user.role.coalition.name
    end
  end
end
