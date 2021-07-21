require 'rails_helper'

RSpec.feature 'Flow visualizations' do
  before do
    allow(Rails.application.config).to receive(:ctc_domains).and_return({test: "test.host"})
  end

  describe 'GYR' do
    it 'shows all the pages' do
      visit flow_path(id: :gyr)

      expect(page).to have_content(QuestionNavigation::FLOW.first.name)
      expect(page).to have_content(QuestionNavigation::FLOW.last.name)
    end
  end

  describe 'CTC' do
    it 'shows all the pages' do
      visit flow_path(id: :ctc)

      expect(page).to have_content(CtcQuestionNavigation::FLOW.first.name)
      expect(page).to have_content(CtcQuestionNavigation::FLOW.last.name)
    end
  end
end
