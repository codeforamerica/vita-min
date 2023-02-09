class AddNumberOfRetriesToOutgoingTextMessages < ActiveRecord::Migration[7.0]
  def change
    add_column :outgoing_text_messages, :number_of_retries, :integer, default: 0
  end
end
