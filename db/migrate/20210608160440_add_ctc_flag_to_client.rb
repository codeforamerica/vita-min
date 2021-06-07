class AddCtcFlagToClient < ActiveRecord::Migration[6.0]
  def change
    add_column :clients, :is_ctc, :boolean, default: false
  end
end
