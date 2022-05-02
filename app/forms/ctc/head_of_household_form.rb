module Ctc
  class HeadOfHouseholdForm < QuestionsForm
    set_attributes_for :temporary_fields, :claim_hoh, :do_not_claim_hoh

    def save
      if claim_hoh
        @intake.default_tax_return.update!(filing_status: :head_of_household)
      else
        @intake.default_tax_return.update!(filing_status: :single)
      end
    end
  end
end