class ChangeIsAdminToAdminRole < ActiveRecord::Migration[6.0]
  def change
    User.where("is_admin = true").find_each do |user|
      admin_role = AdminRole.create
      user.role.destroy if user.role.present?
      user.update(role: admin_role, is_admin: false)
    end
  end
end
