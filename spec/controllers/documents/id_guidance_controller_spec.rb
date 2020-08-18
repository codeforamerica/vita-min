require "rails_helper"

RSpec.describe Documents::IdGuidanceController do
  it_behaves_like :a_ticketed_controller, :edit
end

