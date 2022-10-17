require 'rails_helper'

describe Ctc::Questions::SimplifiedFilingIncomeOffboardingController do
  describe '#show' do
    let(:intake) { create :ctc_intake, client: build(:client, tax_returns: [build(:tax_return, filing_status: filing_status, year: TaxReturn.current_tax_year)]) }
    let(:filing_status) { "single" }

    context 'eitc environment variable is disabled' do
      it 'is false' do
        expect(described_class.show?(intake, subject)).to eq false
      end
    end

    context 'eitc environment variable is enabled' do
      before do
        Flipper.enable :eitc
        create :w2, intake: intake, wages_amount: wages_amount
      end

      context 'single' do
        let(:filing_status) { "single" }

        context 'w2 income less than 12,550' do
          let(:wages_amount) { 12_549 }

          it 'is false' do
            expect(described_class.show?(intake, subject)).to eq false
          end
        end

        context 'w2 income greater than or equal to 12,550' do
          let(:wages_amount) { 12_550 }

          it 'is true' do
            expect(described_class.show?(intake, subject)).to eq true
          end
        end
      end

      context 'married_filing_jointly' do
        let(:filing_status) { "married_filing_jointly" }

        context 'w2 income less than 25,100' do
          let(:wages_amount) { 25_099 }

          it 'is false' do
            expect(described_class.show?(intake, subject)).to eq false
          end
        end

        context 'w2 income greater or equal to than 25,100' do
          let(:wages_amount) { 25_100 }

          it 'is true' do
            expect(described_class.show?(intake, subject)).to eq true
          end
        end
      end
    end
  end
end
