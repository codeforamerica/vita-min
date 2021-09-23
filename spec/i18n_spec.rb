# frozen_string_literal: true

require 'i18n/tasks'

RSpec.describe I18n do
  let(:i18n) { I18n::Tasks::BaseTask.new }

  it "does not have missing/unused keys or inconsistent interpolations" do
    # This is all in one test since the I18n task computes some data which can be re-used by different validations.
    expect(
      i18n.non_normalized_paths
    ).to be_empty, "Translation files need to be normalized, run `i18n-tasks normalize` to fix them."
    expect(
      i18n.unused_keys
    ).to be_empty, "#{i18n.unused_keys.leaves.count} unused i18n keys, run `i18n-tasks health' to show them"
    expect(
      i18n.missing_keys
    ).to be_empty, "#{i18n.missing_keys.leaves.count} i18n keys are missing from a language, run `i18n-tasks health' to show them"
    expect(
      i18n.inconsistent_interpolations
    ).to be_empty, "#{i18n.inconsistent_interpolations.leaves.count} i18n keys have inconsistent interpolations, run `i18n-tasks health` to show them"
  end
end
