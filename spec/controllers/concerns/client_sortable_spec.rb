require "rails_helper"

RSpec.describe ClientSortable, type: :controller do
  # this is a concern spec, so it only needs some portions of a controller
  # - it needs current_user for one particular method
  # - it needs params
  # - it assumes that @clients is already set.
  let(:clients_query_double){ double }
  let(:intakes_query_double){ double }
  let(:cookies) { double }
  controller(ApplicationController) do
    include ClientSortable

    private

    def filter_cookie_name
      "some_filter_cookie_name"
    end
  end

  before do
    allow(controller).to receive(:cookies).and_return(cookies)
    allow(cookies).to receive(:delete)
    allow(cookies).to receive(:[]=)
    allow(cookies).to receive(:[])

    allow(subject).to receive(:params).and_return params
    subject.instance_variable_set(:@clients, clients_query_double)
    allow(clients_query_double).to receive(:after_consent).and_return clients_query_double
    allow(clients_query_double).to receive(:or).and_return clients_query_double
    allow(clients_query_double).to receive(:in_intake).and_return clients_query_double
    allow(clients_query_double).to receive(:delegated_order).and_return clients_query_double
    allow(clients_query_double).to receive(:where).and_return clients_query_double
    allow(clients_query_double).to receive(:not).and_return clients_query_double
    allow(Intake).to receive(:search).and_return intakes_query_double
  end

  describe "#filtered_and_sorted_clients" do
    context "when bulk_edit param is present" do
      context "if a bulk edit cannot be found" do
        let(:params) do
          { bulk_edit: "x" }
        end
        it "returns unscoped clients" do
          expect(subject.filtered_and_sorted_clients).to eq clients_query_double
          expect(clients_query_double).not_to have_received(:where)
        end
      end

      context "with additional filter params" do
        let(:params) do
          {
            bulk_edit: "1",
            search: "que"
          }
        end
        it "ignores additional params and does not set them as filters" do
          expect(subject.filtered_and_sorted_clients).to eq clients_query_double
          expect(Intake).not_to have_received(:search).with "que"
          expect(assigns(:filters)).to include({ saved_search: true })
          other_filters = assigns(:filters).except(:saved_search).values
          expect(other_filters.uniq).to eq [nil]
        end
      end

      context "with a bulk edit of record type Client" do
        let(:bulk_edit) { BulkEdit.generate!(user: (create :user), failed_ids: [1, 2, 3], successful_ids: [4, 5, 6], record_type: Client)}
        context "without an only param" do
          let(:params) do
            { bulk_edit: bulk_edit.id }
          end
          it "queries for all client record ids" do
            expect(subject.filtered_and_sorted_clients).to eq clients_query_double
            expect(clients_query_double).to have_received(:where).with({ id: [4, 5, 6, 1, 2, 3] })
          end
        end

        context "with an only successful param" do
          let(:params) do
            { bulk_edit: bulk_edit.id,
              only: "successful"
            }
          end
          it "queries for only the successful ids" do
            expect(subject.filtered_and_sorted_clients).to eq clients_query_double
            expect(clients_query_double).to have_received(:where).with({ id: [4, 5, 6] })
          end
        end

        context "with an only failed param" do
          let(:params) do
            {
              bulk_edit: bulk_edit.id,
              only: "failed"
            }
          end
          it "queries for only failed client ids" do
            expect(subject.filtered_and_sorted_clients).to eq clients_query_double
            expect(clients_query_double).to have_received(:where).with({ id: [1, 2, 3] })
          end
        end
      end


      context "when bulk_edit record_type is TaxReturn" do
        let(:bulk_edit) { BulkEdit.generate!(user: (create :user), failed_ids: [1, 2, 3], successful_ids: [4, 5, 6], record_type: TaxReturn)}

        context "without an only param" do
          let(:params) do
            { bulk_edit: bulk_edit.id }
          end
          it "queries for all client record ids" do
            expect(subject.filtered_and_sorted_clients).to eq clients_query_double
            expect(clients_query_double).to have_received(:where).with({ tax_returns: { id: [4, 5, 6, 1, 2, 3] } })
          end
        end

        context "with an only successful param" do
          let(:params) do
            {
              bulk_edit: bulk_edit.id,
              only: "successful"
            }
          end

          it "queries for only successful client record ids" do
            expect(subject.filtered_and_sorted_clients).to eq clients_query_double
            expect(clients_query_double).to have_received(:where).with({ tax_returns: { id: [4, 5, 6] } })
          end
        end

        context "with an only failed param" do
          let(:params) do
            {
              bulk_edit: bulk_edit.id,
              only: "failed"
            }
          end
          it "queries for only failed client ids" do
            expect(subject.filtered_and_sorted_clients).to eq clients_query_double
            expect(clients_query_double).to have_received(:where).with({ tax_returns: { id: [1, 2, 3] } })
          end
        end
      end
    end
    
    context "when user is a greeter" do
      let(:params) do
        {}
      end
      let(:user_double) { double(User) }
      before do
        allow(subject).to receive(:current_user).and_return(user_double)
        allow(user_double).to receive(:to_i)
        allow(user_double).to receive(:greeter?).and_return(true)
      end

      it "limits to intake statuses only" do
        expect(subject.filtered_and_sorted_clients).to eq clients_query_double

        expect(clients_query_double).to have_received(:in_intake)
        expect(clients_query_double).to have_received(:or).with(Client.joins(:tax_returns).where({ tax_returns: { assigned_user: user_double } }).distinct)
      end
    end

    context "with a 'search' param" do
      let(:params) do
        { search: "que" }
      end

      it "creates a search query for intakes and queries clients for those intakes" do
        expect(subject.filtered_and_sorted_clients).to eq clients_query_double
        expect(Intake).to have_received(:search).with "que"
        expect(clients_query_double).to have_received(:where).with(intake: intakes_query_double)
      end
    end

    context "with a 'search' param and additional filters" do
      let(:params) do
        {
          search: "query",
          status: "intake_ready"
        }
      end

      it "creates a query for the search and scopes by other provided queries" do
        expect(subject.filtered_and_sorted_clients).to eq clients_query_double
        expect(clients_query_double).to have_received(:where).with({ tax_returns: { status: params[:status].to_sym } })
        expect(clients_query_double).to have_received(:where).with(intake: intakes_query_double)
      end
    end

    context "with a vita partner id" do
      let(:vita_partner) { create :vita_partner }
      let(:params) {
        {
          vita_partner_id: vita_partner.id
        }
      }


      it "creates a query for the search and scopes to vita partner" do
        expect(subject.filtered_and_sorted_clients).to eq clients_query_double
        expect(clients_query_double).to have_received(:where).with('vita_partners.id = :id OR vita_partners.parent_organization_id = :id', id: vita_partner.id)
      end
    end

    context "with a provided language" do
      let(:params) {
        {
            language: "de"
        }
      }

      it "creates a query for the search and scopes to vita partner" do
        expect(subject.filtered_and_sorted_clients).to eq clients_query_double
        expect(clients_query_double).to have_received(:where).with('intakes.locale = :language OR intakes.preferred_interview_language = :language', language: "de")
      end
    end

    context "with service type selected" do
      context "online_intake" do
        let(:params) {
          {
              service_type: "online_intake"
          }
        }

        it "creates a query for the search and scopes to vita partner" do
          expect(subject.filtered_and_sorted_clients).to eq clients_query_double
          expect(clients_query_double).to have_received(:where).with({ tax_returns: { service_type: "online_intake" } })
        end
      end

      context "drop_off" do
        let(:params) {
          {
            service_type: "drop_off"
          }
        }
        it "creates a query for the search and scopes to vita partner" do
          expect(subject.filtered_and_sorted_clients).to eq clients_query_double
          expect(clients_query_double).to have_received(:where).with({ tax_returns: { service_type: "drop_off" } })
        end
      end
    end

    context "with a selected assigned user id" do
      let(:user) { create :user }
      let(:params) {
        {
            assigned_user_id: user.id
        }
      }

      it "creates a query that includes the call to limit to assigned user" do
        expect(subject.filtered_and_sorted_clients).to eq clients_query_double
        expect(clients_query_double).to have_received(:where).with({ tax_returns: { assigned_user: [user.id] } })
      end
    end

    context "with a selected assigned user id AND assigned to me selected" do
      let(:user) { create :user }
      let(:current_user) { create :user }
      let(:params) {
        {
            assigned_user_id: user.id,
            assigned_to_me: true
        }
      }
      before do
        allow(subject).to receive(:current_user).and_return(current_user)
      end

      it "creates a query that includes a call to limit to assigned to current user AND some other user" do
        expect(subject.filtered_and_sorted_clients).to eq clients_query_double
        expect(clients_query_double).to have_received(:where).with({ tax_returns: { assigned_user: [current_user.id, user.id] } })
      end
    end
    
    context "with a clear param" do
      let(:params) do
        {
            clear: true,
            assigned_user_id: 1
        }
      end

      before do
        allow(cookies).to receive(:delete)
        allow(cookies).to receive(:[]).with(anything)
      end

      it "removes the filter cookie" do
        subject.filtered_and_sorted_clients
        expect(cookies).to have_received(:delete).with("some_filter_cookie_name")
      end
    end

    context "searching for phone numbers" do
      before { subject.filtered_and_sorted_clients }

      context "with a simple phone number digit-only search" do
        let(:params) { { search: "4155551212" } }

        it "normalizes the number before passing it to Intake#search" do
          expect(Intake).to have_received(:search).with "+14155551212"
        end
      end

      context "with a phone number in a common local format" do
        let(:params) { { search: "(415) 555-1212" } }

        it "normalizes the number before passing it to Intake#search" do
          expect(Intake).to have_received(:search).with "+14155551212"
        end
      end

      context "with a phone number in an unofficial but commonly entered format" do
        let(:params) { { search: "415.555.1212" } }

        it "normalizes the number before passing it to Intake#search" do
          expect(Intake).to have_received(:search).with "+14155551212"
        end
      end

      context "with the last seven digits of a phone number" do
        let(:params) { { search: "555-1212" } }

        it "passes the number to search with no normalization" do
          expect(Intake).to have_received(:search).with "555-1212"
        end
      end

      context "with a phone number and another field in the search query" do
        let(:params) do
          { search: "colleen 415555(1212)" }
        end

        it "normalizes the number before passing it to Intake#search" do
          expect(Intake).to have_received(:search).with "colleen +14155551212"
        end
      end
    end
  end

  describe "#has_search_and_sort_params?" do
    context "when containing a sort or search param" do
      context "search" do
        let(:params) { { search: "que" } }
        it "returns true" do
          expect(subject.has_search_and_sort_params?).to eq true
        end
      end

      context "status" do
        let(:params) { { search: "prep_ready_for_prep" } }
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

      context "needs_response" do
        let(:params) { { needs_response: true } }
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

      context "vita_partner_id" do
        let(:params) { { vita_partner_id: 1 } }
        it "returns true" do
          expect(subject.has_search_and_sort_params?).to eq true
        end
      end
    end

    context "without a search or sort param" do
      let(:params) { { something: 'hello' } }
      it "returns false" do
        expect(subject.has_search_and_sort_params?).to eq false
      end
    end
  end
end
