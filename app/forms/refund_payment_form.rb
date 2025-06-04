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
    intake.update(refund_payment_method: payment_method)

    if payment_method == 'direct_deposit'
      intake.update(refund_direct_deposit: 'yes')
      intake.update(refund_check_by_mail: 'no')
    else
      intake.update(refund_direct_deposit: 'no')
      intake.update(refund_check_by_mail: 'yes')
    end

    savings_bond = attributes_for(:intake)[:savings_purchase_bond] || 'no'
    split_refund = attributes_for(:intake)[:savings_split_refund] || 'no'
    refund_other = savings_bond == 'yes' ? 'Purchase US Savings Bond' : ''
    refund_other_cb = savings_bond

    intake.update(savings_purchase_bond: savings_bond)
    intake.update(savings_split_refund: split_refund)
    intake.update(refund_other: refund_other)
    intake.update(refund_other_cb: refund_other_cb)
  end
end
