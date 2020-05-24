# == Schema Information
#
# Table name: users
#
#  id                        :bigint           not null, primary key
#  active                    :boolean
#  email                     :string
#  encrypted_access_token    :string
#  encrypted_access_token_iv :string
#  name                      :string
#  provider                  :string
#  role                      :string
#  suspended                 :boolean
#  ticket_restriction        :string
#  two_factor_auth_enabled   :boolean
#  uid                       :string
#  verified                  :boolean
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  zendesk_user_id           :bigint
#
require "rails_helper"

RSpec.describe User, type: :model do
  describe ".from_zendesk_oauth" do
    let(:auth) do
      OmniAuth::AuthHash.new({
        provider: "zendesk",
        uid: 89178938838417938,
        credentials: {
          token: "a87dsgf87aghs"
        },
        info: {
          id: 89178938838417938,
          name: "Tom Tomato",
          email: "ttomato@itsafruit.orange",
          role: "admin",
          ticket_restriction: nil,
          two_factor_auth_enabled: true,
          active: true,
          suspended: false,
          verified: true
        }
      })
    end 
    
    context "with an existing user" do
      let!(:existing_user) { create :user, name: "Tim Tomato", uid: "89178938838417938", provider: "zendesk" }
      
      it "updates all the wonderful fields on the model" do
        expect do
          result = described_class.from_zendesk_oauth(auth)
          expect(result).to eq existing_user
        end.not_to change(User, :count)
        
        user = existing_user.reload
        expect(user.name).to eq "Tom Tomato"
        expect(user.access_token).to eq "a87dsgf87aghs"
      end
    end
    
    context "without an existing user" do
      it "creates a user with all the wonderful fields" do
        expect do
          result = described_class.from_zendesk_oauth(auth)
          expect(result).to be_a User
        end.to change(User, :count).by(1)
        
        user = User.last
        expect(user.access_token).to eq "a87dsgf87aghs"
        expect(user.uid).to eq "89178938838417938"
        expect(user.provider).to eq "zendesk"
        expect(user.name).to eq "Tom Tomato"
        expect(user.email).to eq "ttomato@itsafruit.orange"
        expect(user.role).to eq "admin"
        expect(user.ticket_restriction).to eq nil
        expect(user.two_factor_auth_enabled).to eq true
        expect(user.active).to eq true
        expect(user.suspended).to eq false
        expect(user.verified).to eq true
      end
    end
  end
end
