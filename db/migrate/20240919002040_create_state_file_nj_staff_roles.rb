class CreateStateFileNjStaffRoles < ActiveRecord::Migration[7.1]
  def change
    create_table :state_file_nj_staff_roles do |t|

      t.timestamps
    end
  end
end
