require 'rails_helper'

describe 'db:seed' do
  it 'runs without error' do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
    Rake::Task['db:seed'].invoke
  end
end
