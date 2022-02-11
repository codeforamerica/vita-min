require "rails_helper"

describe ChildTaxCreditCalculator do
  let(:tax_return) {
    tr = create :tax_return, year: 2021,  client: create(:client, intake: create(:ctc_intake))
    tr.intake.dependents.update_all(soft_deleted_at: Time.now)
    tr
  }

  let!(:dependent_older_than_6){ create :qualifying_child, birth_date: Date.parse('1-1-2021') - 10.years, intake: tax_return.intake }
  let!(:dependent_exactly_6){ create :qualifying_child, birth_date: Date.parse('1-1-2021') - 6.years, intake: tax_return.intake }
  let!(:dependent_younger_than_6){ create :qualifying_child, birth_date: Date.parse('1-1-2021') - 4.years, intake: tax_return.intake }
  let!(:dependent_younger_than_6_deleted){ create :qualifying_child, birth_date: Date.parse('1-1-2021') - 4.years, intake: tax_return.intake, soft_deleted_at: Time.now }
  let!(:uncle_not_eligible){ create :qualifying_relative, relationship: "uncle", birth_date: Date.parse('1-1-2021') - 4.years, intake: tax_return.intake }

  describe ".total_advance_payment" do
    it "returns the correct payment amount based on dependent counts" do
      tax_return.reload # Reload so we can rely on the dependents default scope to hide the soft_deleted one
      expected_payment = 4800
      total_payment_amount = described_class.total_advance_payment(tax_return)

      expect(total_payment_amount).to eq(expected_payment)
    end
  end

end
