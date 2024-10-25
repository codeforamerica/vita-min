require 'rails_helper'

describe Efile::Nj::NjSenior do
  describe ".is_over_65" do
    context "when birth_date not present" do
      it "returns false" do
        # TODO
      end
    end

    context "when birth_date over 65 years ago" do
      it "returns true" do
        # TODO
      end
    end

    context "when birth_date under 65 years ago" do
      it "returns false" do
        # TODO
      end
    end
  end
end
