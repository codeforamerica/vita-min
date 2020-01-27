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
#  intake_id  :bigint           not null
#
# Indexes
#
#  index_users_on_intake_id  (intake_id)
#
# Foreign Keys
#
#  fk_rails_...  (intake_id => intakes.id)
#

require "rails_helper"

RSpec.describe User, type: :model do
  describe "#intake" do
    it "requires an intake" do
      user = build :user, intake: nil
      expect(user).not_to be_valid
      expect(user.errors).to include :intake
    end

    it "should belong to an intake" do
      relation = User.reflect_on_association(:intake).macro
      expect(relation).to eq :belongs_to
    end
  end

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
