require "rails_helper"

describe Ctc::Questions::EitcIncomeOffboardingController do
  let(:intake) { create :ctc_intake, had_disqualifying_non_w2_income: had_disqualifying_non_w2_income, client: build(:client, tax_returns: [build(:tax_return, filing_status: filing_status, year: TaxReturn.current_tax_year)]) }
  let(:wages_amount) { 1 }
  let(:filing_status) { "single" }
  let(:had_disqualifying_non_w2_income) { "no" }

  describe ".show?" do
    context 'eitc environment variable is disabled' do
      it 'is false' do
        expect(described_class.show?(intake)).to eq false
      end
    end

    context 'eitc environment variable is enabled' do
      before do
        Flipper.enable :eitc
        create :w2, intake: intake, wages_amount: wages_amount
      end

      context 'had_disqualifying_non_w2_income is yes' do
        let(:had_disqualifying_non_w2_income) { "yes" }

        it 'is true' do
          expect(described_class.show?(intake)).to eq true
        end
      end

      context 'had_disqualifying_non_w2_income is no' do
        let(:had_disqualifying_non_w2_income) { "no" }

        context 'single' do
          let(:filing_status) { "single" }

          context 'w2 income less than or equal to 11,610' do
            let(:wages_amount) { 11_610 }

            it 'is false' do
              expect(described_class.show?(intake)).to eq false
            end
          end

          context 'w2 income greater than 11,610' do
            let(:wages_amount) { 11_611 }

            it 'is true' do
              expect(described_class.show?(intake)).to eq true
            end
          end
        end

        context 'married_filing_jointly' do
          let(:filing_status) { "married_filing_jointly" }

          context 'w2 income less than or equal to 17,550' do
            let(:wages_amount) { 17_550 }

            it 'is false' do
              expect(described_class.show?(intake)).to eq false
            end
          end

          context 'w2 income greater than 17,550' do
            let(:wages_amount) { 17_551 }

            it 'is true' do
              expect(described_class.show?(intake)).to eq true
            end
          end
        end
      end
    end
  end
end
