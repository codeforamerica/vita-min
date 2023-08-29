require 'rails_helper'

RSpec.feature 'Flow visualizations' do
  describe 'GYR' do
    it 'shows all the pages' do
      visit flow_path(id: :gyr)

      expect(page).to have_content(Navigation::GyrQuestionNavigation::FLOW.first.name)
      expect(page).to have_content(Navigation::GyrQuestionNavigation::FLOW.last.name)
    end
  end

  describe 'CTC' do
    it 'shows all the pages' do
      visit flow_path(id: :ctc)

      expect(page).to have_content(Navigation::CtcQuestionNavigation::FLOW.first.name)
      expect(page).to have_content(Navigation::CtcQuestionNavigation::FLOW.last.name)
    end
  end
end
