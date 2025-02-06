class SavingsOptionsForm < QuestionsForm
  set_attributes_for :intake, :savings_purchase_bond, :savings_split_refund, :refund_other, :refund_other_cb

  def save
    savings_bond = attributes_for(:intake)[:savings_purchase_bond]
    split_refund = attributes_for(:intake)[:savings_split_refund]
    refund_other = savings_bond == 'yes' ? 'Purchase US Savings Bond' : ''
    refund_other_cb = savings_bond

    intake.update(savings_purchase_bond: savings_bond)
    intake.update(savings_split_refund: split_refund)
    intake.update(refund_other: refund_other)
    intake.update(refund_other_cb: refund_other_cb)
  end
end

