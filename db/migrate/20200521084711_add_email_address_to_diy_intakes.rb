class AddEmailAddressToDiyIntakes < ActiveRecord::Migration[6.0]
  def change
    add_column :diy_intakes, :email_address, :string
  end
end
