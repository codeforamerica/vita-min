module TaxReturnAssignableUsersHelper
  def assignable_user_options(assignable_users)
    assignable_users.pluck(:id, :role_type, :name).map do |id, role_type, name|
      ["#{name} (#{role_name_from_role_type(role_type)})", id]
    end
  end
end
