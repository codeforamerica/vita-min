class RemoveAssistanceChatColumnOnTriage < ActiveRecord::Migration[6.1]
  def change
    remove_column :triages, :assistance_chat, :string
  end
end
