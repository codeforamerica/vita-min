require 'rails_helper'

describe Ctc::Questions::NonW2IncomeController do
  describe '#show' do
    let(:intake) { create :ctc_intake, :claiming_eitc, client: build(:client, tax_returns: [build(:ctc_tax_return, filing_status: filing_status)]) }
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

      context 'has a qualifying dependent' do
        let!(:dependent) { create :qualifying_child, intake: intake }
        let(:filing_status) { "single" }
        let(:wages_amount) { 10_001 }

        it 'is false' do
          expect(described_class.show?(intake, subject)).to eq false
        end
      end

      context 'single' do
        let(:filing_status) { "single" }

        context 'w2 income between 10,000 and 11,609' do
          let(:wages_amount) { 10_001 }

          it 'is true' do
            expect(described_class.show?(intake, subject)).to eq true
          end
        end

        context 'w2 income less than 10,000' do
          let(:wages_amount) { 9999 }

          it 'is false' do
            expect(described_class.show?(intake, subject)).to eq false
          end
        end

        context 'w2 income greater than 11,609' do
          let(:wages_amount) { 11_610 }

          it 'is false' do
            expect(described_class.show?(intake, subject)).to eq false
          end
        end
      end

      context 'married_filing_jointly' do
        let(:filing_status) { "married_filing_jointly" }

        context 'w2 income between 15,000 and 17,549' do
          let(:wages_amount) { 15_001 }

          it 'is true' do
            expect(described_class.show?(intake, subject)).to eq true
          end
        end

        context 'w2 income less than 15,000' do
          let(:wages_amount) { 14_999 }

          it 'is false' do
            expect(described_class.show?(intake, subject)).to eq false
          end
        end

        context 'w2 income greater than 17,549' do
          let(:wages_amount) { 17_550 }

          it 'is false' do
            expect(described_class.show?(intake, subject)).to eq false
          end
        end
      end
    end
  end
end
