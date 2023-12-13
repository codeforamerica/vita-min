# == Schema Information
#
# Table name: state_ids
#
#  id                  :bigint           not null, primary key
#  expiration_date     :date
#  first_three_doc_num :string
#  id_number           :string
#  id_type             :integer          default("unfilled"), not null
#  issue_date          :date
#  non_expiring        :boolean          default(FALSE)
#  state               :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
require "rails_helper"

describe StateId do
  let!(:state_id) {
    create :state_id,
           id_type: "driver_license",
           id_number: "123456789",
           expiration_date: Date.parse("March 12, 2028"),
           issue_date: Date.parse("March 12, 2020"),
           first_three_doc_num: "ABC",
           state: "NY"
  }
  describe "before_save" do
    context "when id_type is changed to no_id" do
      it "clears the other fields that have to do with id details" do
        expect {
          state_id.update(id_type: "no_id")
        }.to change(state_id, :id_number).to(nil)
         .and change(state_id, :expiration_date).to(nil)
         .and change(state_id, :issue_date).to(nil)
         .and change(state_id, :first_three_doc_num).to(nil)
         .and change(state_id, :state).to(nil)
      end
    end
  end
end
