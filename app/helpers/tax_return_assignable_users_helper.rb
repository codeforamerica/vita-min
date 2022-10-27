module TaxReturnAssignableUsersHelper
  def assignable_user_options(assignable_users)
    assignable_users.pluck(:id, :role_type, :name, Arel.sql('suspended_at IS NOT NULL as suspended')).map do |id, role_type, name, suspended|
      name = suspended ? I18n.t("hub.suspended_user_name", name: name) : name
      role = (role_type || "").gsub("Role", "").underscore.humanize.titlecase
      ["#{name} (#{role})", id]
    end
  end
end
