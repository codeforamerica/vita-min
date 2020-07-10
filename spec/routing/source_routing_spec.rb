require "rails_helper"

describe "partner source routing" do
  let(:codes) { SourceParameter.pluck(:code) }

  it "converts the source in the url to a parameter" do
    codes.each do |code|
      expect(get: "/#{code}").to route_to(
        controller: "public_pages",
          action: "home",
          source: code,
      )
    end
  end

  it "routes the source case insensitive in the url to a parameter" do
    codes.each do |code|
      mangled_code = code.chars.map do |c|
        [true, false].sample ? c.downcase : c.upcase
      end.join
      expect(get: "/#{mangled_code}").to route_to(
        controller: "public_pages",
          action: "home",
          source: mangled_code,
      )
    end
  end

  it "routes correctly with locale" do
    code = codes.sample
    expect(get: "/es/#{code}").to route_to(
      controller: "public_pages",
        action: "home",
        locale: "es",
        source: code,
    )
  end

  it "does not route non-existant codes" do
    expect(get: "/wrong-code").not_to be_routable
  end
end
