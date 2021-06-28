class AddCtcRefundDeliveryMethodToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :ctc_refund_delivery_method, :integer
  end
end
