module TaxReturnAssignableUsersHelper
  def assignable_user_options(assignable_users)
    assignable_users.pluck(:id, :role_type, :name, Arel.sql('suspended_at IS NOT NULL as suspended')).map do |id, role_type, name, suspended|
      ["#{name}#{suspended ? " (Suspended)" : ""} (#{role_name_from_role_type(role_type)})", id]
    end
  end
end
