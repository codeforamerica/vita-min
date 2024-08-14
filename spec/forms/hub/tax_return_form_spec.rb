require "rails_helper"

describe Hub::TaxReturnForm do
  describe "#new" do
    subject { described_class.new(client, params) }

    context "with no params" do
      let(:params) { {} }
      let(:tax_return) { create :gyr_tax_return, :intake_in_progress, service_type: service_type }
      let(:client) { tax_return.client }

      context "if existing tax returns were drop off" do
        let(:service_type) { "drop_off" }

        it "initializes with a drop_off value for service_type" do
          expect(subject.service_type).to eq "drop_off"
        end
      end

      context "if existing tax returns were online intake" do
        let(:service_type) { "online_intake" }

        it "initializes with a online_intake value for service_type" do
          expect(subject.service_type).to eq "online_intake"
        end
      end
    end

    context "when explicit service_type is passed as a param" do
      subject { described_class.new(client, MultiTenantService.gyr.filing_years, { service_type: "custom" }) }
      let(:params) { {} }
      let(:tax_return) { create :gyr_tax_return, :intake_in_progress, service_type: "drop_off" }
      let(:client) { tax_return.client }

      it "does not overwrite it" do
        expect(subject.service_type).to eq "custom"
      end
    end
  end

  describe "#save" do
    subject { described_class.new(client, MultiTenantService.gyr.filing_years, params) }

    let(:client) { create :client, intake: (build :intake) }
    let(:user) { create :user }
    let(:params) { {
        service_type: "online_intake",
        year: 2019,
        certification_level: "basic",
        assigned_user_id: user.id,
        current_state: "intake_in_progress"
    } }

    it "initializes with a default drop_off value for service_type if there are tax returns" do
      expect { subject.save }.to change { TaxReturn.count }.by(1)
      tax_return = TaxReturn.last
      expect(tax_return.current_state).to eq "intake_in_progress"
      expect(tax_return.assigned_user).to eq user
      expect(tax_return.certification_level).to eq "basic"
      expect(tax_return.year).to eq 2019
    end
  end
end