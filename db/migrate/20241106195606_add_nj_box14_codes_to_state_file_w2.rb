class AddNjBox14CodesToStateFileW2 < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_w2s, :box14_ui_wf_swf, :decimal, precision: 12, scale: 2
    add_column :state_file_w2s, :box14_ui_hc_wd, :decimal, precision: 12, scale: 2
    add_column :state_file_w2s, :box14_fli, :decimal, precision: 12, scale: 2
  end
end
