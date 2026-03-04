require "rails_helper"

RSpec.describe ClientSorter do
  let(:user_role) { build :team_member_role, sites: [create(:site)] }
  let(:user) { create :user, role: user_role }
  let(:subject) { described_class.new(Client.all, user, params, {}) }

  before do
    allow(subject).to receive(:current_user).and_return(user)
  end


  describe "#filtered_and_sorted_clients" do
    context "when user is a greeter" do
      let!(:assigned_tax_return) { create :gyr_tax_return, :prep_ready_for_prep, assigned_user: user }
      let(:user_role) { build(:greeter_role) }
      let(:params) do
        {}
      end

      context "there are greetable clients" do
        let!(:greetable_tax_return) { create :gyr_tax_return, :intake_ready }

        it "limits to greetable clients and assigned clients" do
          result = subject.filtered_and_sorted_clients.to_a
          expect(result).to match_array([assigned_tax_return.client, greetable_tax_return.client])
        end
      end

      context "there are not greetable clients" do
        it "limits to assigned clients only" do
          result = subject.filtered_and_sorted_clients.to_a
          expect(result).to match_array([assigned_tax_return.client])
        end
      end
    end

    context "default sort order" do
      let(:user_role) { build :admin_role}
      let(:params) { {} }
      let!(:client_1) { create :client, last_outgoing_communication_at: 2.days.ago, filterable_product_year: Rails.configuration.product_year }
      let!(:client_2) { create :client, last_outgoing_communication_at: 5.days.ago, filterable_product_year: Rails.configuration.product_year }
      let!(:client_3) { create :client, last_outgoing_communication_at: 3.days.ago, filterable_product_year: Rails.configuration.product_year }

      it "sorts clients by last_outgoing_communication_at" do
        expect(subject.filtered_and_sorted_clients).to eq ([client_2, client_3, client_1])
      end
    end

    context "with a 'search' param" do
      let(:user_role) { build :admin_role }
      let(:params) { { search: "que" } }

      let!(:matching_client) do
        create(:client, filterable_product_year: Rails.configuration.product_year)
      end

      let!(:nonmatching_client) do
        create(:client, filterable_product_year: Rails.configuration.product_year)
      end

      let!(:matching_intake) do
        create(
          :intake,
          client: matching_client,
          primary_last_name: "Quezada",
          visitor_id: "v1",
          product_year: Rails.configuration.product_year
        )
      end

      let!(:nonmatching_intake) do
        create(
          :intake,
          client: nonmatching_client,
          primary_last_name: "Smith",
          visitor_id: "v2",
          product_year: Rails.configuration.product_year
        )
      end

      before do
        create(:gyr_tax_return, :intake_ready, client: matching_client)
        create(:gyr_tax_return, :intake_ready, client: nonmatching_client)

        past = 1.second.ago.to_fs(:db)
        Intake.where(id: [matching_intake.id, nonmatching_intake.id])
              .update_all("needs_to_flush_searchable_data_set_at = '#{past}'")

        SearchIndexer.refresh_search_index(limit: 10_000)
      end

      it "returns only the matching client" do
        expect(subject.filtered_and_sorted_clients.to_a).to match_array([matching_client])
      end
    end

    context "with a vita partner" do
      let(:user_role) { build :admin_role }
      let(:vita_partner) { create :organization }
      let(:params) do
        {
          vita_partners: [{ id: vita_partner.id, name: vita_partner.name, value: vita_partner.id }].to_json
        }
      end

      let!(:matching_client) { create(:client, vita_partner: vita_partner) }
      let!(:other_client)    { create(:client) }

      let!(:matching_intake) do
        create(:intake,
               client: matching_client,
               product_year: Rails.configuration.product_year,
               visitor_id: "v1"
        )
      end

      let!(:other_intake) do
        create(:intake,
               client: other_client,
               product_year: Rails.configuration.product_year,
               visitor_id: "v2"
        )
      end

      before do
        create(:gyr_tax_return, :intake_ready, client: matching_client)
        create(:gyr_tax_return, :intake_ready, client: other_client)

        SearchIndexer.refresh_filterable_properties([matching_client.id, other_client.id])
      end

      it "returns clients scoped to the selected vita partner" do
        expect(subject.filtered_and_sorted_clients.to_a).to match_array([matching_client])
      end

      context "more than one vita partner is selected" do
        let!(:site) { create :site, parent_organization: vita_partner }

        let(:params) do
          {
            vita_partners: [
              { id: vita_partner.id, name: vita_partner.name, value: vita_partner.id },
              { id: site.id, name: site.name, value: site.id }
            ].to_json
          }
        end

        let!(:site_client) { create(:client, vita_partner: site) }

        let!(:site_intake) do
          create(:intake,
                 client: site_client,
                 product_year: Rails.configuration.product_year,
                 visitor_id: "v3"
          )
        end

        before do
          create(:gyr_tax_return, :intake_ready, client: site_client)
          SearchIndexer.refresh_filterable_properties([site_client.id])
        end

        it "returns clients scoped to any selected vita partner" do
          expect(subject.filtered_and_sorted_clients.to_a)
            .to match_array([matching_client, site_client])
        end
      end
    end

    context "with service type selected" do
      let(:user_role) { build :admin_role }

      let!(:online_client) { create(:client) }
      let!(:dropoff_client) { create(:client) }

      let!(:online_intake) do
        create(:intake,
               client: online_client,
               product_year: Rails.configuration.product_year,
               visitor_id: "v-online"
        )
      end

      let!(:dropoff_intake) do
        create(:intake,
               client: dropoff_client,
               product_year: Rails.configuration.product_year,
               visitor_id: "v-dropoff"
        )
      end

      before do
        create(:gyr_tax_return, :intake_ready, client: online_client, service_type: "online_intake")
        create(:gyr_tax_return, :intake_ready, client: dropoff_client, service_type: "drop_off")

        SearchIndexer.refresh_filterable_properties([online_client.id, dropoff_client.id])
      end

      context "online_intake" do
        let(:params) { { service_type: "online_intake" } }

        it "returns only clients whose filterable tax return properties include online_intake" do
          expect(subject.filtered_and_sorted_clients.to_a).to match_array([online_client])
        end
      end

      context "drop_off" do
        let(:params) { { service_type: "drop_off" } }

        it "returns only clients whose filterable tax return properties include drop_off" do
          expect(subject.filtered_and_sorted_clients.to_a).to match_array([dropoff_client])
        end
      end
    end

    context "with a selected assigned user id" do
      let(:user_role) { build :admin_role }
      let(:user) { create :user }
      let(:params) { { assigned_user_id: user.id } }
      let(:subject) { described_class.new(Client.all, user, params, {}) }

      let!(:assigned_client) { create(:client) }
      let!(:unassigned_client) { create(:client) }

      before do
        assigned_client.update!(consented_to_service_at: Time.current)
        unassigned_client.update!(consented_to_service_at: Time.current)

        create(:intake, client: assigned_client, product_year: Rails.configuration.product_year, visitor_id: "v-assigned")
        create(:intake, client: unassigned_client, product_year: Rails.configuration.product_year, visitor_id: "v-unassigned")

        create(:gyr_tax_return, :intake_ready, client: assigned_client, assigned_user_id: user.id)
        create(:gyr_tax_return, :intake_ready, client: unassigned_client, assigned_user_id: nil)

        SearchIndexer.refresh_filterable_properties([assigned_client.id, unassigned_client.id])
      end

      it "returns clients with tax returns assigned to the selected user" do
        expect(subject.filtered_and_sorted_clients.to_a).to match_array([assigned_client])
      end
    end

    context "with a selected assigned user id" do
      let(:user_role) { build :admin_role }
      let(:user) { create :user }
      let(:params) { { assigned_user_id: user.id } }
      let(:subject) { described_class.new(Client.all, user, params, {}) }

      let!(:assigned_client) { create(:client) }
      let!(:unassigned_client) { create(:client) }

      before do
        assigned_client.update!(consented_to_service_at: Time.current)
        unassigned_client.update!(consented_to_service_at: Time.current)

        create(:intake, client: assigned_client, product_year: Rails.configuration.product_year, visitor_id: "v-assigned")
        create(:intake, client: unassigned_client, product_year: Rails.configuration.product_year, visitor_id: "v-unassigned")

        create(:gyr_tax_return, :intake_ready, client: assigned_client, assigned_user_id: user.id)
        create(:gyr_tax_return, :intake_ready, client: unassigned_client, assigned_user_id: nil)

        SearchIndexer.refresh_filterable_properties([assigned_client.id, unassigned_client.id])
      end

      it "returns clients with tax returns assigned to the selected user" do
        expect(subject.filtered_and_sorted_clients.to_a).to match_array([assigned_client])
      end
    end

    context "searching for phone numbers" do
      let(:user_role) { build :admin_role }
      let(:user) { create :user }
      let(:subject) { described_class.new(Client.all, user, params, {}) }

      context "with a simple phone number digit-only search" do
        let(:params) { { search: "4155551212" } }

        it "normalizes the number" do
          expect(subject.filters[:search]).to eq("+14155551212")
        end
      end

      context "with a phone number in a common local format" do
        let(:params) { { search: "(415) 555-1212" } }

        it "normalizes the number" do
          expect(subject.filters[:search]).to eq("+14155551212")
        end
      end

      context "with a phone number in an unofficial but commonly entered format" do
        let(:params) { { search: "415.555.1212" } }

        it "normalizes the number" do
          expect(subject.filters[:search]).to eq("+14155551212")
        end
      end

      context "with the last seven digits of a phone number" do
        let(:params) { { search: "555-1212" } }

        it "does not normalize" do
          expect(subject.filters[:search]).to eq("555-1212")
        end
      end

      context "with a phone number and another field in the search query" do
        let(:params) { { search: "colleen 415555(1212)" } }

        it "normalizes just the phone substring" do
          expect(subject.filters[:search]).to eq("colleen +14155551212")
        end
      end

      context "with a phone number in e.164 international format" do
        let(:params) { { search: "colleen +14155551212" } }

        it "leaves it as-is" do
          expect(subject.filters[:search]).to eq("colleen +14155551212")
        end
      end
    end
  end

  describe "#has_search_and_sort_params?" do
    let(:user) { create(:user) }
    let(:subject) { described_class.new(Client.all, user, params, {}) }

    context "when containing a sort or search param" do
      context "search" do
        let(:params) { { search: "que" } }

        it "returns true" do
          expect(subject.has_search_and_sort_params?).to eq true
        end
      end

      context "status" do
        let(:params) { { status: "prep_ready_for_prep" } }

        it "returns true" do
          expect(subject.has_search_and_sort_params?).to eq true
        end
      end

      context "unassigned" do
        let(:params) { { unassigned: true } }

        it "returns true" do
          expect(subject.has_search_and_sort_params?).to eq true
        end
      end

      context "assigned_to_me" do
        let(:params) { { assigned_to_me: true } }

        it "returns true" do
          expect(subject.has_search_and_sort_params?).to eq true
        end
      end

      context "flagged" do
        let(:params) { { flagged: true } }

        it "returns true" do
          expect(subject.has_search_and_sort_params?).to eq true
        end
      end

      context "year" do
        let(:params) { { year: 2019 } }

        it "returns true" do
          expect(subject.has_search_and_sort_params?).to eq true
        end
      end

      context "vita_partners" do
        let(:params) do
          {
            vita_partners: [{ id: 1, name: "Partner name", value: 1 }].to_json
          }
        end

        it "returns true" do
          expect(subject.has_search_and_sort_params?).to eq true
        end
      end
    end

    context "without a search or sort param" do
      let(:params) { { something: "hello" } }

      it "returns false" do
        expect(subject.has_search_and_sort_params?).to eq false
      end
    end
  end
end
