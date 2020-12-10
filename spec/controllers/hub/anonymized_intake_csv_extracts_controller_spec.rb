require "rails_helper"

RSpec.describe Hub::AnonymizedIntakeCsvExtractsController do

  describe "#index" do
    it_behaves_like :a_get_action_for_admins_only, action: :index

    context "with an authenticated user" do
      before { sign_in create(:admin_user) }

      context "viewing the table list" do
        render_views
        let!(:extract) { AnonymizedIntakeCsvService.new.store_csv }

        it "renders a table with extract filenames" do
          get :index

          expect(assigns[:extracts]).to include(extract)
          filename = extract.upload.attachment.filename.to_s
          expect(response.body).to match(filename)
        end
      end
    end
  end

  describe "#show" do
    let(:extract) { AnonymizedIntakeCsvService.new.store_csv }
    let(:params) { { id: extract.id } }

    it_behaves_like :a_get_action_for_admins_only, action: :show

    context "with an authenticated user" do
      let(:csv_transient_url) { "https://gyr-demo.s3.amazonaws.com/data.csv?sig=whatever&expires=whatever" }

      before do
        sign_in create(:admin_user)
        allow(subject).to receive(:transient_storage_url).and_return(csv_transient_url)
      end

      it "sends the csv file as a download attachment" do
        get :show, params: { id: extract.id }

        expect(response).to redirect_to(csv_transient_url)
        expect(subject).to have_received(:transient_storage_url).with(extract.upload.blob, disposition: "attachment")
      end
    end
  end
end

