class SavingsOptionsForm < QuestionsForm
  set_attributes_for :intake, :savings_purchase_bond, :savings_split_refund, :refund_other

  def save
    savings_bond = attributes_for(:intake)[:savings_purchase_bond]
    split_refund = attributes_for(:intake)[:savings_split_refund]
    refund_other = savings_bond == 'yes' ? 'Purchase US Savings Bond' : ''

    intake.update(savings_purchase_bond: savings_bond)
    intake.update(savings_split_refund: split_refund)
    intake.update(refund_other: refund_other)
  end
end

