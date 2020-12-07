class RenameResponseNeededToAttentionNeeded < ActiveRecord::Migration[6.0]
  def change
    rename_column :clients, :response_needed_since, :attention_needed_since
  end
end
