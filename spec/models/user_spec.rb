# == Schema Information
#
# Table name: users
#
#  id         :bigint           not null, primary key
#  email      :string
#  provider   :string
#  uid        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

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
        it "initializes a new record with the auth attributes without saving" do
          user = nil

          expect {
            user = described_class.from_omniauth(auth)
          }.not_to change(User, :count)


          expect(user.provider).to eq "idme"
          expect(user.uid).to eq "123545"
          expect(user.email).to eq "gary.gardengnome@example.green"
        end
      end
    end
  end
end
