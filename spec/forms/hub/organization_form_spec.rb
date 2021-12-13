require "rails_helper"

RSpec.describe Hub::OrganizationForm do
  subject { described_class.new(organization, params) }

  let(:organization) { build(:organization, coalition: coalition) }
  let(:params) { {} }
  let(:coalition) { nil }

  describe "#independent_org" do
    context "with an unpersisted org" do
      context "when params specify is_independent is true" do
        let(:params) { { is_independent: true } }

        it "returns true" do
          expect(subject.is_independent).to be_truthy
        end
      end

      context "when params do not specify is_independent" do
        it "returns false" do
          expect(subject.is_independent).to be_falsey
        end
      end
    end

    context "with a persisted org" do
      before do
        organization.save!
      end

      context "when params specify is_independent" do
        context "when the model has a coalition but the params specify is_independent=true" do
          let(:coalition) { build(:coalition) }
          let(:params) { { is_independent: true } }

          it "returns true" do
            expect(subject.is_independent).to be_truthy
          end
        end

        context "when the model does not have a coalition but the params specify is_independent=false" do
          let(:params) { { is_independent: false } }

          it "returns false" do
            expect(subject.is_independent).to be_falsey
          end
        end
      end

     context "when params do not specify is_independent" do
        context "when it is part of a coalition" do
          let(:coalition) { build(:coalition) }

          it "returns false" do
            expect(subject.is_independent).to be_falsey
          end
        end

        context "when it is not part of a coalition" do
          it "returns true" do
            expect(subject.is_independent).to be_truthy
          end
        end
      end
    end
  end

  describe "validations" do
    it "requires name" do
      expect(subject).not_to be_valid
      expect(subject.errors).to include(:name)
    end
  end

  describe "#save" do
    let(:params) { { name: "New Name", timezone: "America/Juneau", capacity_limit: 9001, allows_greeters: "yes" }.merge(extra_params) }
    let(:extra_params) { {} }

    it "saves name, timezone, capacity_limit, allows_greeters" do
      subject.save
      expect(organization.name).to eq("New Name")
      expect(organization.timezone).to eq("America/Juneau")
      expect(organization.capacity_limit).to eq(9001)
      expect(organization.allows_greeters).to be_truthy
    end

    context "when is_independent is true" do
      context "when a coalition is submitted" do
        let(:extra_params) { { is_independent: true, coalition_id: create(:coalition, name: "Koala Koalition").id } }

        it "sets the organization's coalition to nil anyway" do
          subject.save
          expect(organization.coalition).to be_nil
        end
      end
    end

    context "when is_independent is false" do
      context "when a coalition is submitted" do
        let(:extra_params) { { is_independent: false, coalition_id: create(:coalition, name: "Koala Koalition").id } }

        it "updates the organization's coalition" do
          subject.save
          expect(organization.coalition.name).to eq("Koala Koalition")
        end
      end
    end
  end
end
