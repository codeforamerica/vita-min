module RoleHelper
  def user_roles(user)
    [
        *(I18n.t("general.admin") if user.is_admin),
        *(I18n.t("general.client_support") if user.is_client_support),
        *(I18n.t('general.organization_lead') if user.role&.class&.name == "OrganizationLeadRole")
    ].join(", ")
  end

  def user_org(user)
    user.role.organization.name if user.role&.class&.name == "OrganizationLeadRole"
  end
end
