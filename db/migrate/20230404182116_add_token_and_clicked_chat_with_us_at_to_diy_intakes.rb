class AddTokenAndClickedChatWithUsAtToDiyIntakes < ActiveRecord::Migration[7.0]
  def change
    add_column :diy_intakes, :token, :string
    add_column :diy_intakes, :clicked_chat_with_us_at, :datetime
  end
end
