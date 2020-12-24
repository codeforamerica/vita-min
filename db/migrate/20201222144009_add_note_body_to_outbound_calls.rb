class AddNoteBodyToOutboundCalls < ActiveRecord::Migration[6.0]
  def change
    add_column :outbound_calls, :note, :text
    remove_column :outbound_calls, :completed_at
  end
end
