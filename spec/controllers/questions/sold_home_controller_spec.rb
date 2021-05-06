require "rails_helper"

RSpec.describe Questions::SoldHomeController do
  describe ".show?" do
    it_behaves_like :a_show_method_dependent_on_ever_owned_home
  end
end

