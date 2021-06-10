# == Schema Information
#
# Table name: efile_submissions
#
#  id            :bigint           not null, primary key
#  tax_return_id :bigint
#
# Indexes
#
#  index_efile_submissions_on_tax_return_id  (tax_return_id)
#
require "rails_helper"

describe EfileSubmission do
  context 'a newly created submission' do
    it 'has an initial current_state of new' do
      expect(EfileSubmission.create(tax_return: create(:tax_return)).current_state).to eq "new"
    end
  end
end
