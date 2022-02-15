# == Schema Information
#
# Table name: system_notes
#
#  id         :bigint           not null, primary key
#  body       :text
#  data       :jsonb
#  type       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  client_id  :bigint           not null
#  user_id    :bigint
#
# Indexes
#
#  index_system_notes_on_client_id  (client_id)
#  index_system_notes_on_user_id    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

describe SystemNote::AssignmentChange do
  describe ".generate!" do
    let(:intake) { create :intake, :with_contact_info }
    let(:tax_return) { create :tax_return, client: Client.new(intake: intake), year: 2019 }
    let(:current_user) { create :user, name: "Example User" }
    let(:user_to_assign) { create :user, name: "Alice" }

    context "with a recent change to tax return assignment" do
      before do
        tax_return.update(assigned_user: user_to_assign)
      end

      it "creates a system note" do
        expect {
          described_class.generate!(initiated_by: current_user, tax_return: tax_return)
        }.to change(described_class, :count).by 1
      end

      it "describes the change" do
        described_class.generate!(initiated_by: current_user, tax_return: tax_return)
        expect(described_class.last.client).to eq(tax_return.client)
        expect(described_class.last.body).to eq("#{current_user.name_with_role} assigned 2019 return to #{user_to_assign.name_with_role}.")
      end
    end

    context "when the tax return assignment is updated to the same user as before" do
      let(:user) { create :admin_user }
      let(:tax_return) { create :tax_return, assigned_user: user, year: 2019 }
      before do
        tax_return.update(assigned_user: user)
      end

      it "does not create a note" do
        expect(described_class.generate!(initiated_by: current_user, tax_return: tax_return)).to be_nil
      end
    end

    context "when the tax return assignment changes to nil" do
      let(:user) { create :admin_user }
      let(:tax_return) { create :tax_return, assigned_user: user, year: 2019 }
      before do
        tax_return.update(assigned_user: nil)
      end

      it "creates a note indicating it was unassigned" do
        expect {
          described_class.generate!(initiated_by: current_user, tax_return: tax_return)
        }.to change(SystemNote, :count).by 1
        expect(SystemNote.last.body).to eq "#{current_user.name_with_role} removed assignment from 2019 return."
      end
    end
  end

end
