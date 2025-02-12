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

    context "when non_expiring" do
      it " clears expiration_date" do
        state_id.non_expiring = true
        expect {
          state_id.update(id_type: "no_id")
        }.to change(state_id, :expiration_date).to(nil)
      end
    end

    context "when a long dash is in the id number" do
      it "removes the dash" do
        state_id.update(id_number: "MD —123–456")
        expect(state_id.id_number).to eq("MD 123456")
      end
    end

    context "when a long dash is in the id number" do
      it "removes the long dash but leaves the normal dash" do
        state_id.update(id_number: "MD-—123–456")
        expect(state_id.id_number).to eq("MD-123456")
      end
    end
  end
end
