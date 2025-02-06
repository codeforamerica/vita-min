class AddRefundOtherCbToIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :intakes, :refund_other_cb, :integer, default: 0, null: false
  end
end
