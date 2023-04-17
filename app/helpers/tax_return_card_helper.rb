module TaxReturnCardHelper
  def tax_return_status_to_fields(tax_return)
    if tax_return.current_state == 'intake_reviewing'
      {
        help_text: "Your tax team is waiting for an initial review with you.",
        percent_complete: 60,

      }
    else
      {
        help_text: "We are waiting for a final signature from you.",
        percent_complete: 95,
        call_to_action_text: "Please add your final signature to your tax return",
        button_text: "Add final signature",
        button_url: portal_tax_return_authorize_signature_path(tax_return_id: tax_return.id),
      }
    end
  end
end
