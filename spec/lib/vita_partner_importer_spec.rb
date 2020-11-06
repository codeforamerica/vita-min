require 'rails_helper'

RSpec.describe VitaPartnerImporter do
  describe "#upsert_vita_partners" do
    let(:zendesk_group_id) { "360000000000" }
    let(:fake_partners_yaml) do
      {
        "vita_partners" => [
          {
            "name" => "Tax Help Colorado",
            "zendesk_instance_domain" => "eitc",
            "zendesk_group_id" => zendesk_group_id,
            "display_name" => "Tax Help Colorado",
            "source_parameters" => ["test-source"],
            "states" => ["CO"],
            "logo_path" => "",
            "weekly_capacity_limit" => 500,
            "accepts_overflow" => true,
          }
        ],
      }
    end

    before do
      allow(YAML).to receive(:load_file)
        .with(VitaPartnerImporter::VITA_PARTNERS_YAML)
        .and_return(fake_partners_yaml)
    end

    after do
      SourceParameter.destroy_all
      VitaPartner.destroy_all
    end

    context "with a new YAML entry (creating new record)" do
      it "inserts a new partner with all the attributes" do
        expect do
          VitaPartnerImporter.upsert_vita_partners
        end.to change(VitaPartner, :count).by(1)

        created = VitaPartner.last
        expect(created.name).to eq("Tax Help Colorado")
        expect(created.zendesk_group_id).to eq(zendesk_group_id)
        expect(created.source_parameters.length).to eq(1)
        expect(created.source_parameters.first.code).to eq("test-source")
        expect(created.states.length).to eq(1)
        expect(created.states.first.abbreviation).to eq("CO")
        expect(created.weekly_capacity_limit).to eq(500)
        expect(created.accepts_overflow).to be(true)
      end

      context "with only the essential attributes" do
        let(:fake_partners_yaml) do
          { "vita_partners" => [{
              "name" => "Tax Help Colorado",
              "zendesk_instance_domain" => "eitc",
              "zendesk_group_id" => zendesk_group_id,
          }] }
        end

        it "sets the expected default values" do
          VitaPartnerImporter.upsert_vita_partners

          created = VitaPartner.find_by(zendesk_group_id: "360000000000")
          expect(created.weekly_capacity_limit).to eq(VitaPartner::DEFAULT_CAPACITY_LIMIT)
        end
      end
    end

    context "when a partner exists with that group ID (updating record)" do
      context "when a field has changed" do
        let!(:existing_partner) do
          create(:vita_partner, name: "Old Name", zendesk_group_id: zendesk_group_id)
        end

        it "updates the existing partner" do
          expect do
            VitaPartnerImporter.upsert_vita_partners
          end.to change { existing_partner.reload.name }
            .from("Old Name").to("Tax Help Colorado")
        end
      end

      context "when a field is deleted from a partner" do
        let!(:existing_partner) do
          create(
            :vita_partner,
            name: "Fake Name",
            display_name: "Fake Display Name",
            zendesk_instance_domain: "eitc",
            zendesk_group_id: "1234567890",
            accepts_overflow: true,
            logo_path: "partner-logos/ia.png",
            weekly_capacity_limit: 1,
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
          VitaPartnerImporter.upsert_vita_partners
          updated_partner = existing_partner.reload
          expect(updated_partner.accepts_overflow).to be(nil)
          expect(updated_partner.logo_path).to be_nil
          expect(updated_partner.display_name).to be_nil
          expect(updated_partner.weekly_capacity_limit).to eq(300) # Default from VitaPartner::DEFAULT_CAPACITY_LIMIT
        end
      end

      context "when a source code and state are removed" do
        before do
          partner = create(
            :vita_partner,
            name: "Fake Name",
            zendesk_instance_domain: "eitc",
            zendesk_group_id: zendesk_group_id,
            states: [create(:state)],
          )
          create :source_parameter, code: "hello", vita_partner: partner
        end

        let(:fake_partners_yaml) do
          {
              "vita_partners" => [
                {
                  "name" => "Tax Help Colorado",
                  "zendesk_instance_domain" => "eitc",
                  "zendesk_group_id" => zendesk_group_id,
                  "display_name" => "Tax Help Colorado",
                  "logo_path" => "",
                  "weekly_capacity_limit" => 500
                }
              ]
          }
        end

        it "removes the relationship with the partner" do
          VitaPartnerImporter.upsert_vita_partners

          modified_partner = VitaPartner.find_by(zendesk_group_id: zendesk_group_id)
          expect(modified_partner.source_parameters.count).to eq 0
          expect(modified_partner.states.count).to eq 0
        end
      end
    end

    context "when a YAML entry is deleted" do
      before do
        partner = create(
          :vita_partner,
          name: "Fake Name",
          zendesk_instance_domain: "eitc",
          zendesk_group_id: zendesk_group_id,
          weekly_capacity_limit: 1,
          states: [create(:state, abbreviation: "XYZ")],
          logo_path: "partner-logos/ia.png",
        )
        create :source_parameter, code: "hello", vita_partner: partner
      end

      let(:fake_partners_yaml) do
        { "vita_partners" => [] }
      end

      it "keeps the entry in the database, removes routing-related data, and marks it archived" do
        VitaPartnerImporter.upsert_vita_partners

        archived_partner = VitaPartner.find_by(zendesk_group_id: zendesk_group_id)
        # Keep essential data
        expect(archived_partner.name).to eq("Fake Name")
        expect(archived_partner.zendesk_instance_domain).to eq("eitc")
        expect(archived_partner.zendesk_group_id).to eq(zendesk_group_id)
        # Keep logo_path & weekly_capacity_limit; no reason to remove them
        expect(archived_partner.weekly_capacity_limit).to eq(1)
        expect(archived_partner.logo_path).to eq("partner-logos/ia.png")
        # Remove routing-related data
        expect(archived_partner.source_parameters.count).to eq 0
        expect(archived_partner.states.count).to eq 0
        # Mark archived
        expect(archived_partner.archived).to be(true)
      end
    end
  end
end
