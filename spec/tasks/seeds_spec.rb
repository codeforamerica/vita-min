require 'rails_helper'

describe 'db:seed' do
  it 'runs without error' do
    Rake::Task.define_task(:environment)
    Rake.application.rake_require "active_record/railties/databases"
    Rake::Task['db:seed'].invoke
  end
end
