# frozen_string_literal: true
require 'rails_helper'

RSpec.describe StateFile::TermsAndConditionsForm do
  let(:intake) { create :state_file_ny_intake }

  describe '#valid?' do
    describe 'consented_to_terms_and_conditions' do
      context 'without a consented_to_terms_and_conditions' do
        it 'returns false and adds an error' do
          form = described_class.new(intake, { consented_to_terms_and_conditions: 'unfilled' })

          expect(form).not_to be_valid
          expect(form.errors).to include(:consented_to_terms_and_conditions)
        end
      end

      context 'when consented_to_terms_and_conditions is filled' do
        it 'accepts consented_to_terms_and_conditions as valid' do
          form = described_class.new(intake, { consented_to_terms_and_conditions: 'yes' })

          expect(form).to be_valid
        end
      end
    end
  end
end
