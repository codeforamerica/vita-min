module RoleHelper
  def user_roles(user)
    [
        *(I18n.t("general.admin") if user.is_admin),
        *(I18n.t("general.beta_tester") if user.is_beta_tester),
    ].join(", ")
  end
end