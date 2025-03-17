class AddNjValidatedW2IdsColumn < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_nj_intakes, :confirmed_w2_ids, :integer, array: true, default: []
  end
end
