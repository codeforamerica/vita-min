require 'rails_helper'

class TestImporter
  class << self
    include VitaPartnerImporter
  end
end

RSpec.describe VitaPartnerImporter do
  describe "#upsert_vita_partners" do
    let(:zendesk_group_id) { "360000000000" }
    let(:fake_partners_yaml) do
      {
        "vita_partners" => [{
          "name" => "Tax Help Colorado",
          "zendesk_instance_domain" => "eitc",
          "zendesk_group_id" => zendesk_group_id,
          "display_name" => "Tax Help Colorado",
          "source_parameters" => ["test-source"],
          "states" => ["CO"],
          "logo_path" => "",
          "weekly_capacity_limit" => 500
        }],
      }
    end

    before do
      allow(YAML).to receive(:load_file).and_call_original
      allow(YAML).to receive(:load_file)
        .with(VitaPartnerImporter::VITA_PARTNERS_YAML)
        .and_return(fake_partners_yaml)
    end

    it "inserts a new partner" do
      expect do
        TestImporter.upsert_vita_partners
      end.to change(VitaPartner, :count).by(1)

      created = VitaPartner.last
      expect(created.name).to eq("Tax Help Colorado")
      expect(created.zendesk_group_id).to eq(zendesk_group_id)
      expect(created.source_parameters.length).to eq(1)
      expect(created.source_parameters.first.code).to eq("test-source")
      expect(created.states.length).to eq(1)
      expect(created.states.first.abbreviation).to eq("CO")
      expect(created.weekly_capacity_limit).to eq(500)
    end

    context "setting defaults on the vita partner model" do
      let(:fake_partners_yaml) do
        {
          "vita_partners" => [{
            "name" => "Tax Help Colorado",
            "zendesk_instance_domain" => "eitc",
            "zendesk_group_id" => zendesk_group_id,
          }],
        }
      end

      it "uses the default value for weekly capacity limit if not set in yml" do
        TestImporter.upsert_vita_partners

        created = VitaPartner.last
        expect(created.weekly_capacity_limit).to eq(VitaPartner::DEFAULT_CAPACITY_LIMIT)
      end
    end

    context "when a partner exists with that group ID" do
      context "when a field has changed" do
        let!(:existing_partner) do
          create(:vita_partner, name: "Old Name", zendesk_group_id: zendesk_group_id)
        end

        it "updates the existing partner" do
          expect do
            TestImporter.upsert_vita_partners
          end.to change { existing_partner.reload.name }
            .from("Old Name").to("Tax Help Colorado")
        end
      end

      context "when a field is deleted from a partner" do
        let!(:existing_partner) do
          create(
            :vita_partner,
            name: "Fake Name",
            zendesk_instance_domain: "eitc",
            zendesk_group_id: "1234567890",
            accepts_overflow: true,
          )
        end

        before do
          fake_partners_yaml["vita_partners"] << {
            "name" => "Fake Name",
            "zendesk_instance_domain" => "eitc",
            "zendesk_group_id" => "1234567890",
          }
        end

        it "updates the corresponding column to nil or default value" do
          expect do
            TestImporter.upsert_vita_partners
          end.to change { existing_partner.reload.accepts_overflow }
            .from(true).to(false)
        end
      end
    end

    context "when changing a group ID for a given partner" do
      let(:old_zendesk_group_id) { "360000000000" }
      let!(:existing_partner) { create(:vita_partner, zendesk_group_id: old_zendesk_group_id) }
      let(:zendesk_group_id) { "360011111111" }

      before do
        create(:source_parameter,
               vita_partner: existing_partner,
               code: "test-source")
      end

      it "creates the new partner and moves over the source parameter" do
        expect do
          TestImporter.upsert_vita_partners
        end.to change(VitaPartner, :count).by(1)

        created = VitaPartner.last
        expect(created.zendesk_group_id).to eq(zendesk_group_id)
        expect(created.source_parameters.length).to eq(1)
        expect(created.source_parameters.first.code).to eq("test-source")

        existing_partner.reload
        expect(existing_partner.zendesk_group_id).to eq(old_zendesk_group_id)
        expect(existing_partner.source_parameters).to be_empty
      end
    end
  end
end
