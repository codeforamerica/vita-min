require "rails_helper"

RSpec.describe Hub::OrganizationForm do
  subject { described_class.new(organization, params) }

  let(:organization) { build(:organization, coalition: coalition) }
  let(:params) { {} }
  let(:coalition) { nil }

  describe "validations" do
    it "requires name" do
      expect(subject).not_to be_valid
      expect(subject.errors.attribute_names).to include(:name)
    end

    context "when is_independent=yes" do
      let(:params) { { is_independent: "yes" }}

      it "requires name and states" do
        expect(subject).not_to be_valid
        expect(subject.errors.attribute_names).to match_array([:name, :states])
      end
    end

    context "when is_independent=no" do
      let(:params) { { is_independent: "no" }}

      it "requires name and coalition ID" do
        expect(subject).not_to be_valid
        expect(subject.errors.attribute_names).to match_array([:name, :coalition_id])
      end
    end
  end

  describe "#initialize" do
    context "with an unpersisted org" do
      context "when params specify is_independent is true" do
        let(:params) { { is_independent: "yes" } }

        it "sets is_independent to yes" do
          expect(subject.is_independent).to eq("yes")
        end
      end

      context "when params do not specify is_independent" do
        it "sets is_independent to no" do
          expect(subject.is_independent).to eq("no")
        end
      end
    end

    context "with a persisted org" do
      before do
        organization.save!
      end

      context "when params specify is_independent" do
        context "when the model has a coalition but the params specify is_independent yes" do
          let(:coalition) { build(:coalition) }
          let(:params) { { is_independent: "yes" } }

          it "sets is_independent to yes" do
            expect(subject.is_independent).to eq("yes")
          end
        end

        context "when the model does not have a coalition but the params specify is_independent no" do
          let(:params) { { is_independent: "no" } }

          it "sets is_independent to no" do
            expect(subject.is_independent).to eq("no")
          end
        end
      end

     context "when params do not specify is_independent" do
        context "when it is part of a coalition" do
          let(:coalition) { build(:coalition) }

          it "sets is_independent to no" do
            expect(subject.is_independent).to eq("no")
          end
        end

        context "when it is not part of a coalition" do
          it "sets is_independent to yes" do
            expect(subject.is_independent).to eq("yes")
          end
        end
      end
    end
  end

  describe "#save" do
    before do
      allow(UpdateStateRoutingTargetsService).to receive(:update)
    end

    let(:params) do
      {
        name: "New Name",
        timezone: "America/Juneau",
        capacity_limit: 9001,
        allows_greeters: true,
        accepts_itin_applicants: true
      }.merge(extra_params)
    end
    let(:extra_params) { {} }

    it "saves name, timezone, capacity_limit, allows_greeters" do
      subject.save
      expect(organization.name).to eq("New Name")
      expect(organization.timezone).to eq("America/Juneau")
      expect(organization.capacity_limit).to eq(9001)
      expect(organization.allows_greeters).to eq true
      expect(organization.accepts_itin_applicants).to eq true
    end

    context "when is_independent is yes" do
      context "when a coalition is submitted" do
        let(:extra_params) { { is_independent: "yes", coalition_id: create(:coalition, name: "Koala Koalition").id } }

        it "sets the organization's coalition to nil anyway" do
          subject.save
          expect(organization.coalition).to be_nil
        end
      end

      context "when states are submitted" do
        let(:extra_params) { { is_independent: "yes", states: "OH,CA" } }

        it "updates states" do
          subject.save
          expect(UpdateStateRoutingTargetsService).to have_received(:update).with(Organization.last, %w[OH CA])
        end
      end
    end

    context "when is_independent is no" do
      context "when a coalition is submitted" do
        let(:extra_params) { { is_independent: "no", states: "OH,CA", coalition_id: create(:coalition, name: "Koala Koalition").id } }

        it "updates the organization's coalition" do
          subject.save
          expect(organization.coalition.name).to eq("Koala Koalition")
        end

        it "removes any existing states" do
          subject.save
          expect(UpdateStateRoutingTargetsService).to have_received(:update).with(organization, [])
        end
      end
    end
  end
end
