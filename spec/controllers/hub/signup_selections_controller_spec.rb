require 'rails_helper'

describe Hub::SignupSelectionsController do
  it_behaves_like :a_get_action_for_admins_only, action: :index

  describe '#create' do
    before do
      sign_in create(:admin_user)
    end

    around do |example|
      @filename = Rails.root.join("tmp", "#{File.basename(__FILE__)}-#{SecureRandom.hex}.csv")
      File.write(@filename, csv_content)
      example.run
      File.unlink(@filename)
    end

    let(:signup1) { create(:signup) }
    let(:signup2) { create(:signup) }

    context "with valid params" do
      let(:csv_content) { <<~CSV
        id
        #{signup1.id}
        #{signup2.id}
        -906
      CSV
      }

      it 'stores an array of CSV data' do
        expect {
          put :create, params: { signup_selection: { upload: fixture_file_upload(@filename), signup_type: :GYR } }
        }.to change(SignupSelection, :count).by(1)
        record = SignupSelection.last
        expect(record.id_array).to match_array [signup1.id, signup2.id]
        expect(record.filename).to eq File.basename(@filename)
      end
    end

    context "with invalid params" do
      context "with an invalid CSV" do
        let(:csv_content) { <<~CSV
          wrong_header
          3
          4
        CSV
        }

        it "shows an error on that field" do
          expect {
            put :create, params: { signup_selection: { upload: fixture_file_upload(@filename), signup_type: :GYR } }
          }.to change(SignupSelection, :count).by(0)
          expect(assigns(:signup_selection).errors).to include :upload
        end
      end
    end
  end
end
