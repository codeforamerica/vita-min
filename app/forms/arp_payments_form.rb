class ArpPaymentsForm < QuestionsForm
  set_attributes_for :intake,
                     :received_stimulus_payment,
                     :eip1_amount_received,
                     :eip2_amount_received,
                     :eip3_amount_received,
                     :advance_ctc_amount_received,
                     :received_advance_ctc_payment
  validate :eip_amounts_present_or_unsure
  validate :advance_ctc_amount_present_or_unsure

  def save
    intake.assign_attributes(attributes_for(:intake))

    unless received_stimulus_payment == "unsure"
      if stimulus_payments.any? { |sp| sp.to_i > 0 }
        intake.received_stimulus_payment = "yes"
      elsif stimulus_payments.all? { |sp| sp.to_i.zero? }
        intake.received_stimulus_payment = "no"
      end
    end
    unless received_advance_ctc_payment == "unsure"
      intake.received_advance_ctc_payment = advance_ctc_amount_received.to_i.zero? ? "no" : "yes"
    end
    intake.save
  end

  private

  def stimulus_payments
    [eip1_amount_received, eip2_amount_received, eip3_amount_received]
  end

  def eip_amounts_present_or_unsure
    unless received_stimulus_payment == "unsure"
      if stimulus_payments.any?(&:blank?)
        errors.add(:received_stimulus_payment, I18n.t("views.questions.arp_payments.errors.eip"))
      end
    end
  end

  def advance_ctc_amount_present_or_unsure
    if received_advance_ctc_payment != "unsure" && advance_ctc_amount_received.to_i.blank?
      errors.add(:received_advance_ctc_payment, I18n.t("views.questions.arp_payments.errors.advance_child_tax_credit"))
    end
  end
end