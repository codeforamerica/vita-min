require "rails_helper"

RSpec.describe Questions::EverMarriedController do
  it_behaves_like :a_ticketed_controller, :edit
end
