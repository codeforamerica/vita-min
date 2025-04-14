class AddPriorYearPaymentsToIdIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_id_intakes, :prior_year_refund_payments_amount, :decimal, precision: 12, scale: 2
    add_column :state_file_id_intakes, :paid_prior_year_refund_payments, :integer, default: 0, null: false
  end
end
