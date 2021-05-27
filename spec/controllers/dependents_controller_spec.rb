require "rails_helper"

RSpec.describe DependentsController do
  let(:intake) { create :intake }
  before { allow(MixpanelService).to receive(:send_event) }

  describe "#next_path" do
    before { sign_in intake.client }

    it "returns a link to dependent care questions" do
      expect(subject.next_path).to include dependent_care_questions_path
    end
  end

  describe "#index" do
    it_behaves_like :a_get_action_for_authenticated_clients_only, action: :index
    it_behaves_like :a_get_action_redirects_for_show_still_needs_help_clients, action: :index

    context "with an authenticated client" do
      before { sign_in intake.client }

      context "with existing dependents" do
        render_views
        let!(:dependent_one) { create :dependent, first_name: "Kylie", last_name: "Kiwi", birth_date: Date.new(2012, 4, 21), intake: intake}
        let!(:dependent_two) { create :dependent, first_name: "Kelly", last_name: "Kiwi", birth_date: Date.new(2012, 4, 21), intake: intake}

        it "renders information about each dependent" do
          get :index

          expect(response.body).to include "Kylie Kiwi 4/21/2012"
          expect(response.body).to include "Kelly Kiwi 4/21/2012"
        end
      end
    end
  end

  describe "#create" do
    let(:params) do
      {
        dependent: {
          first_name: "Kylie",
          last_name: "Kiwi",
          birth_date_month: "6",
          birth_date_day: "15",
          birth_date_year: "2015",
          relationship: "Nibling",
          months_in_home: "12",
          was_student: "no",
          on_visa: "no",
          north_american_resident: "yes",
          disabled: "no",
          was_married: "no"
        }
      }
    end

    it_behaves_like :a_post_action_for_authenticated_clients_only, action: :create

    context "with an authenticated client" do
      before { sign_in intake.client }

      it "creates a new dependent linked to the current intake and redirects to the index" do
        expect do
          post :create, params: params
        end.to change(Dependent, :count).by 1

        expect(response).to redirect_to(dependents_path)

        dependent = Dependent.last
        expect(dependent.intake).to eq intake
        expect(dependent.first_name).to eq "Kylie"
        expect(dependent.last_name).to eq "Kiwi"
        expect(dependent.birth_date).to eq Date.new(2015, 6, 15)
        expect(dependent.relationship).to eq "Nibling"
        expect(dependent.months_in_home).to eq 12
        expect(dependent.was_student).to eq "no"
        expect(dependent.on_visa).to eq "no"
        expect(dependent.north_american_resident).to eq "yes"
        expect(dependent.disabled).to eq "no"
        expect(dependent.was_married).to eq "no"
      end

      it "sends analytics to mixpanel" do
        post :create, params: params

        expect(MixpanelService).to have_received(:send_event).with(hash_including(
          event_name: "dependent_added",
          data: {
            dependent_age_at_end_of_tax_year: "4",
            dependent_under_6: "yes",
            dependent_months_in_home: "12",
            dependent_was_student: "no",
            dependent_on_visa: "no",
            dependent_north_american_resident: "yes",
            dependent_disabled: "no",
            dependent_was_married: "no",
          }
        ))
      end

      context "with invalid params" do
        render_views

        let(:params) do
          {
            dependent: {
              first_name: "Kylie",
              birth_date_month: "12",
              birth_date_day: "2",
              birth_date_year: "",
              relationship: "Nibling",
              months_in_home: "12",
              was_student: "no",
              on_visa: "no",
              north_american_resident: "yes",
              disabled: "no",
              was_married: "no"
            }
          }
        end

        it "renders new with validation errors" do
          expect do
            post :create, params: params
          end.not_to change(Dependent, :count)

          expect(response).to render_template(:new)

          expect(response.body).to include "Please enter a valid date."
          expect(response.body).to include "Please enter a last name."
        end

        it "sends validation errors to mixpanel" do
          post :create, params: params

          expect(MixpanelService).to have_received(:send_event).with(hash_including(
            event_name: "validation_error",
            data: {
              invalid_birth_date: true,
              invalid_last_name: true,
            }
          ))
        end
      end
    end
  end

  describe "#edit" do
    let(:client) { intake.client }
    let!(:dependent) do
      create :dependent,
             first_name: "Mary",
             last_name: "Mango",
             birth_date: Date.new(2017, 4, 21),
             relationship: "Kid",
             intake: intake
    end
    let(:params) { { id: dependent.id } }

    it_behaves_like :a_get_action_for_authenticated_clients_only, action: :edit
    it_behaves_like :a_get_action_redirects_for_show_still_needs_help_clients, action: :edit

    context "with an authenticated client" do
      render_views

      before { sign_in client }

      it "renders information about the existing dependent and renders a delete button" do
        get :edit, params: params

        expect(response.body).to include("Mary")
        expect(response.body).to include("Mango")
        expect(response.body).to include("Kid")
        expect(response.body).to include("Remove this person")
      end
    end
  end

  describe "#update" do
    let!(:dependent) do
      create :dependent,
             first_name: "Mary",
             last_name: "Mango",
             birth_date: Date.new(2017, 4, 21),
             relationship: "Kid",
             intake: intake
    end
    let(:params) do
      {
        id: dependent.id,
        dependent: {
          first_name: "Kylie",
          last_name: "Kiwi",
          birth_date_month: "6",
          birth_date_day: "15",
          birth_date_year: "2015",
          relationship: "Nibling",
          months_in_home: "12",
          was_student: "no",
          on_visa: "no",
          north_american_resident: "yes",
          disabled: "no",
          was_married: "no"
        }
      }
    end

    it_behaves_like :a_post_action_for_authenticated_clients_only, action: :update


    context "with an authenticated client" do
      before { sign_in intake.client }

      it "updates the dependent and redirects to the index" do
        post :update, params: params

        expect(response).to redirect_to(dependents_path)

        dependent.reload
        expect(dependent.first_name).to eq "Kylie"
        expect(dependent.last_name).to eq "Kiwi"
        expect(dependent.birth_date).to eq Date.new(2015, 6, 15)
        expect(dependent.relationship).to eq "Nibling"
        expect(dependent.months_in_home).to eq 12
        expect(dependent.was_student).to eq "no"
        expect(dependent.on_visa).to eq "no"
        expect(dependent.north_american_resident).to eq "yes"
        expect(dependent.disabled).to eq "no"
        expect(dependent.was_married).to eq "no"
      end

      it "sends analytics to mixpanel" do
        post :update, params: params

        expect(MixpanelService).to have_received(:send_event).with(hash_including(
          event_name: "dependent_updated",
          data: {
            dependent_age_at_end_of_tax_year: "4",
            dependent_under_6: "yes",
            dependent_months_in_home: "12",
            dependent_was_student: "no",
            dependent_on_visa: "no",
            dependent_north_american_resident: "yes",
            dependent_disabled: "no",
            dependent_was_married: "no",
          }
        ))
      end

      context "with invalid params" do
        render_views

        let(:params) do
          {
            id: dependent.id,
            dependent: {
              first_name: "Kylie",
              last_name: "",
              birth_date_month: "16",
              birth_date_day: "2",
              birth_date_year: "2015",
              relationship: "Nibling",
              months_in_home: "12",
              was_student: "no",
              on_visa: "no",
              north_american_resident: "yes",
              disabled: "no",
              was_married: "no"
            }
          }
        end

        it "renders edit with validation errors" do
          expect do
            post :update, params: params
          end.not_to change(Dependent, :count)

          expect(response).to render_template(:edit)

          expect(response.body).to include "Please enter a valid date."
          expect(response.body).to include "Please enter a last name."
        end

        it "sends validation errors to mixpanel" do
          post :create, params: params

          expect(MixpanelService).to have_received(:send_event).with(hash_including(
            event_name: "validation_error",
            data: {
              invalid_birth_date: true,
              invalid_last_name: true,
            }
          ))
        end
      end
    end
  end

  describe "#destroy" do
    let!(:dependent) do
      create :dependent,
             first_name: "Mary",
             last_name: "Mango",
             birth_date: Date.new(2017, 4, 21),
             relationship: "Kid",
             intake: intake
    end
    let(:params) { { id: dependent.id } }

    it_behaves_like :a_post_action_for_authenticated_clients_only, action: :destroy

    context "with an authenticated client" do
      before { sign_in intake.client }

      it "deletes the dependent and adds a flash message and redirects to dependents path" do
        expect do
          delete :destroy, params: params
        end.to change(Dependent, :count).by(-1)

        expect(response).to redirect_to dependents_path
        expect(flash[:notice]).to eq "Removed Mary Mango."
      end

      it "sends analytics to mixpanel" do
        delete :destroy, params: params

        expect(MixpanelService).to have_received(:send_event).with(hash_including(event_name: "dependent_removed"))
      end
    end
  end
end
