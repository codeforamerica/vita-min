require 'rails_helper'

describe 'creating database views' do
  it 'runs without error' do
    Rails.application.load_tasks
    Rake::Task['analytics:drop_views'].invoke
    Rake::Task['analytics:create_views'].invoke
  end
end
