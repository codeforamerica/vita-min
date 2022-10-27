require "rails_helper"

describe 'Ctc::Questions::IncomeQualifierController' do

  context 'when client selects yes' do
    # not sure how to test for client clicking on 'yes' button
    it 'sends client to income page' do
      # how to test for the correct page here?
    end
  end

  context 'when client selects no' do
    # not sure how to test for client clicking on 'no' button
    it 'redirects to use-gyr' do
      expect(response).to redirect_to questions_use_gyr_path
    end
  end

end