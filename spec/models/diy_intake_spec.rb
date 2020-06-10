# == Schema Information
#
# Table name: diy_intakes
#
#  id                 :bigint           not null, primary key
#  email_address      :string
#  locale             :string
#  preferred_name     :string
#  referrer           :string
#  source             :string
#  state_of_residence :string
#  token              :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  requester_id       :bigint
#  ticket_id          :bigint
#  visitor_id         :string
#
# Indexes
#
#  index_diy_intakes_on_token  (token) UNIQUE
#
require 'rails_helper'

describe DiyIntake do
  describe 'validations' do
    it { should validate_presence_of(:preferred_name) }
    it { should validate_presence_of(:state_of_residence) }
  end

  describe 'token issuance' do
    let(:diy_intake) { DiyIntake.new(preferred_name: "Someone Special", state_of_residence: "NC") }

    it 'generates a token' do
      token = diy_intake.issue_token()
      expect(token).not_to be_nil
      expect(token.length).to be >= 10
    end

    it 'assigns a token before persisting' do
      expect(diy_intake.token).to be_nil
      diy_intake.save!
      expect(diy_intake.token).not_to be_nil
    end

    it 'ignores tokens submitted before persisting' do
      diy_intake.token = "NONSENSE"
      diy_intake.save!
      expect(diy_intake.token).not_to eq("NONSENSE")
    end

    it 'ignores updates to tokens after creation' do
      diy_intake.save!
      diy_intake.token = "NONSENSE"
      diy_intake.save!
      expect(diy_intake.reload.token).not_to eq("NONSENSE")
    end
  end
end
