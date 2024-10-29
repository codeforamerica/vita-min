class AddModelBox14ToStateFileW2 < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_w2s, :box_14_stpickup, :decimal, precision: 12, scale: 2
  end
end
