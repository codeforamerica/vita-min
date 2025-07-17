class RefundPaymentForm < QuestionsForm
  set_attributes_for :intake,
                     :refund_payment_method,
                     :refund_direct_deposit,
                     :refund_check_by_mail,
                     :savings_purchase_bond,
                     :savings_split_refund,
                     :refund_other,
                     :refund_other_cb

  def save
    payment_method = attributes_for(:intake)[:refund_payment_method]
    payment_method = "unfilled" unless payment_method.present?

    # While the single field `refund_payment_method` is used for the intake flow, we
    # use separate fields for the Hub so that form elements (in the erb file) can
    # each refer to a distinct field. So we assign values to those fields here.
    savings_bond = attributes_for(:intake)[:savings_purchase_bond] || 'no'
    split_refund = attributes_for(:intake)[:savings_split_refund] || 'no'
    refund_other = savings_bond == 'yes' ? 'Purchase US Savings Bond' : ''
    refund_other_cb = savings_bond

    intake.update(
      refund_payment_method: payment_method,
      refund_direct_deposit: payment_method == 'direct_deposit' ? 'yes' : 'no',
      refund_check_by_mail: payment_method == 'direct_deposit' ? 'no' : 'yes',
      savings_purchase_bond: savings_bond,
      savings_split_refund: split_refund,
      refund_other: refund_other,
      refund_other_cb: refund_other_cb
    )
  end
end
