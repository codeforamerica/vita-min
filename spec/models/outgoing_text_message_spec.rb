# == Schema Information
#
# Table name: outgoing_text_messages
#
#  id           :bigint           not null, primary key
#  body         :string           not null
#  sent_at      :datetime         not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  case_file_id :bigint           not null
#  user_id      :bigint           not null
#
# Indexes
#
#  index_outgoing_text_messages_on_case_file_id  (case_file_id)
#  index_outgoing_text_messages_on_user_id       (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (case_file_id => case_files.id)
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe OutgoingTextMessage, type: :model do
  describe "required fields" do
    context "without required fields" do
      let(:message) { OutgoingTextMessage.new }

      it "is not valid and adds an error to each field" do
        expect(message).not_to be_valid
        expect(message.errors).to include :user
        expect(message.errors).to include :case_file
        expect(message.errors).to include :sent_at
        expect(message.errors).to include :body
      end
    end

    context "with all required fields" do
      let(:message) do
        OutgoingTextMessage.new(
          user: create(:user),
          case_file: create(:case_file),
          body: "hi",
          sent_at: DateTime.now
        )
      end

      it "is valid and does not have errors" do
        expect(message).to be_valid
        expect(message.errors).to be_blank
      end
    end
  end
end
