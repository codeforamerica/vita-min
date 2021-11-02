require "rails_helper"

describe TransitionNotFilingService do
  describe 'run' do
    context "with a client who has some tax returns in not_filing status" do
      let(:client) { create :client, intake: (create :intake) }

      context "when previous status is intake_in_progress" do
        let(:tax_return) { create :tax_return, :intake_in_progress, client: client }

        before do
          tax_return.transition_to(:file_not_filing)
        end
        it "changes status back to intake in progress" do
          expect(client.tax_returns.map(&:current_state)).to eq ["file_not_filing"]
          described_class.run(client)
          expect(client.tax_returns.map(&:current_state)).to eq ["intake_in_progress"]
        end
      end

      context "when previous status is anything else" do
        let(:tax_return) { create :tax_return, :intake_needs_doc_help, client: client }
        before do
          tax_return.transition_to(:file_not_filing)
        end
        it "does not change status" do
          expect(client.tax_returns.map(&:current_state)).to eq ["file_not_filing"]
          described_class.run(client)
          expect(client.tax_returns.map(&:current_state)).to eq ["file_not_filing"]
        end
      end

      context "when there is no previous state transitions" do
        let!(:tax_return) { create :tax_return, :file_not_filing, client: client }

        it "does not change status" do
          expect(client.tax_returns.map(&:current_state)).to eq ["file_not_filing"]
          described_class.run(client)
          expect(client.tax_returns.map(&:current_state)).to eq ["file_not_filing"]
        end
      end
    end
  end
end