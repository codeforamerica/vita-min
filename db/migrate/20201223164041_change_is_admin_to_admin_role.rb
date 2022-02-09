class ChangeIsAdminToAdminRole < ActiveRecord::Migration[6.0]
  def change
    # This migration used to query for User.where("is_admin = true"), set is_admin to false, and create an AdminRole.
    # It's already done that.
  end
end
