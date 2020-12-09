module RoleHelper
  def user_roles(user)
    [
        *(I18n.t("general.admin") if user.is_admin),
        *(I18n.t("general.client_support") if user.is_client_support)
    ].join(", ")
  end
end