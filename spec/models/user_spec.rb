require "rails_helper"

RSpec.describe User, type: :model do
  describe ".from_omniauth" do
    context "with valid data from omniauth" do
      let(:auth) do
        OmniAuth::AuthHash.new({
          provider: "idme",
          uid: "123545",
          info: {
            email: "gary.gardengnome@example.green"
          }
        })
      end

      context "with an existing user record that matches provider and uid" do
        let!(:user) { create :user, provider: auth.provider, uid: auth.uid }

        it "does not create a new record" do
          expect {
            described_class.from_omniauth(auth)
          }.not_to change(User, :count)
        end
      end

      context "with no matching records" do
        it "creates a new record with the auth attributes" do
          expect {
            described_class.from_omniauth(auth)
          }.to change(User, :count).by(1)

          user = User.last

          expect(user.provider).to eq "idme"
          expect(user.uid).to eq "123545"
          expect(user.email).to eq "gary.gardengnome@example.green"
        end
      end
    end
  end
end
