require "rails_helper"

RSpec.describe Questions::TriageController do
  context "#edit" do
    controller do
      def form_class
        Class.new(TriageForm) do
          def valid?; true; end
        end
      end
    end

    before do
      routes.draw {
        get "edit" => "questions/triage#edit"
      }
    end

    context "when a triage is in the session" do
      let(:triage) { create(:triage) }
      before do
        session[:triage_id] = triage.id
      end

      it "shows the sign-in link" do
        get :edit
        expect(assigns[:show_client_sign_in_link]).to be_truthy
      end

      it "exposes the current_triage" do
        expect(subject.current_triage).to eq(triage)
      end
    end

    context "when a triage is not in the session" do
      it "redirects to the first triage page" do
        get :edit
        expect(response).to(redirect_to(Questions::TriageIncomeLevelController.to_path_helper))
      end
    end
  end

  context "#update" do
    before do
      session[:triage_id] = create(:triage).id
    end

    context "with invalid params" do
      controller do
        def form_class
          Class.new(TriageForm) do
            def valid?; false; end
          end
        end
      end

      before do
        routes.draw {
          post "update" => "questions/triage#update"
        }
      end

      it "renders with errors" do
        expect {
          post :update, params: {}
        }.not_to change(Triage, :count)
        expect(response).to render_template(:edit)
      end
    end
  end
end
