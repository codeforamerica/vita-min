class AddAddlRefundFieldsToIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :intakes, :refund_direct_deposit, :integer
    add_column :intakes, :refund_check_by_mail, :integer
    add_column :intakes, :refund_other, :string
  end
end
