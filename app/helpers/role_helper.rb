module RoleHelper
  def user_role(user)
    [
        *(I18n.t("general.admin") if user.role_type == "AdminRole"),
        *(I18n.t("general.client_support") if user.is_client_support),
        *(I18n.t('general.organization_lead') if user.role_type == "OrganizationLeadRole")
    ].join(", ")
  end

  def user_org(user)
    user.role.organization.name if user.role_type == "OrganizationLeadRole"
  end
end
