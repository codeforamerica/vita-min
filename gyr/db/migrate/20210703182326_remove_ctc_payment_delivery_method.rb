class RemoveCtcPaymentDeliveryMethod < ActiveRecord::Migration[6.0]
  def change
    remove_column :intakes, :ctc_refund_delivery_method, :integer
  end
end
