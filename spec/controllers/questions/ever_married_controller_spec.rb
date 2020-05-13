require "rails_helper"

RSpec.describe Questions::EverMarriedController do
  it_behaves_like "a ticketed controller", :edit
end