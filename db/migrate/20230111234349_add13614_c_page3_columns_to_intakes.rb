class Add13614CPage3ColumnsToIntakes < ActiveRecord::Migration[7.0]
  def change
    add_column :intakes, :presidential_campaign_fund_donation, :integer, default: 0, null: false
    add_column :intakes, :had_disaster_loss_where, :string
    add_column :intakes, :register_to_vote, :integer, default: 0, null: false
  end
end
