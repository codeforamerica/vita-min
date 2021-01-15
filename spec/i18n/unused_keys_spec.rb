require 'i18n/tasks'

RSpec.describe I18n do
  let(:i18n) { I18n::Tasks::BaseTask.new }

  let(:unused_keys) { i18n.unused_keys }

  it 'does not have unused keys' do
    expect(unused_keys).to be_empty,
                         "#{unused_keys.leaves.count} unused i18n keys, run `i18n-tasks unused' to show them"
  end
end
