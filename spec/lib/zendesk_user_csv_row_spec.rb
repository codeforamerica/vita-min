require "rails_helper"

RSpec.describe ZendeskUserCSVRow do
  describe ".from_row" do
    let(:valid_row) do
      CSV::Row.new(
        ["User First Name", "User Last Name", "User Email", "User Role", "Site Access"],
        ["Foggy", "Sunflower", "foggy@example.com", "Admin", "[FOGGY] Site Access"]
      )
    end

    context "given a valid row" do
      it "returns an object with the correct properties" do
        result = ZendeskUserCSVRow.from_row(valid_row)
        expect(result).to have_attributes(
          first_name: "Foggy",
          last_name: "Sunflower",
          email: "foggy@example.com",
          role: "Admin",
          site_access: "[FOGGY] Site Access",
        )
      end

      it "returns a valid object" do
        result = ZendeskUserCSVRow.from_row(valid_row)
        expect(result).to be_valid
      end
    end
  end

  describe ".to_row" do
    let(:attributes) do
      {
        first_name: "Foggy",
        last_name: "Sunflower",
        email: "foggy@example.com",
        role: "Admin",
        site_access: "[FOGGY] Site Access",
      }
    end

    it "returns the expected CSV::Row" do
      expect(ZendeskUserCSVRow.to_row(**attributes)).to eq(
        CSV::Row.new(
          ["User First Name", "User Last Name", "User Email", "User Role", "Site Access"],
          ["Foggy", "Sunflower", "foggy@example.com", "Admin", "[FOGGY] Site Access"]
        )
      )
    end
  end
end
