require "rails_helper"

describe CanonicalEmail do
  describe ".get" do
    context "gmail.com domain" do
      it "removes everything after the + and removes ." do
        expect(CanonicalEmail.get("something.something-something+1234@gmail.com")).to eq "somethingsomething-something@gmail.com"
      end
    end

    context "yahoo.com domain" do
      it "removes everything following a hyphen" do
        expect(CanonicalEmail.get("something.something-something+1234@yahoo.com")).to eq "something.something@yahoo.com"
      end
    end
    
    context "hotmail.com, outlook.com, icloud.com, me.com, mac.com" do
      it "removes everything after the +" do
        expect(CanonicalEmail.get("something.something-something+1234@hotmail.com")).to eq "something.something-something@hotmail.com"
        expect(CanonicalEmail.get("something.something-something+1234@outlook.com")).to eq "something.something-something@outlook.com"
        expect(CanonicalEmail.get("something.something-something+1234@icloud.com")).to eq "something.something-something@icloud.com"
        expect(CanonicalEmail.get("something.something-something+1234@me.com")).to eq "something.something-something@me.com"
        expect(CanonicalEmail.get("something.something-something+1234@mac.com")).to eq "something.something-something@mac.com"
      end
    end

    context "any other domain" do
      it "doesnt do anything to it" do
        expect(CanonicalEmail.get("something.something-something+1234@other.com")).to eq "something.something-something+1234@other.com"
      end
    end

    context "when passed argument is nil" do
      it "is nil" do
        expect(CanonicalEmail.get(nil)).to eq nil
      end
    end
  end
end