require "rails_helper"

describe "partner source routing" do
  let(:code) { "example" }
  let(:vita_partner) { create :vita_partner }
  before do
    create(:source_parameter, code: "example", vita_partner: vita_partner)
  end

  it "converts the source in the url to a parameter" do
    expect(get: "/#{code}").to route_to(
      controller: "public_pages",
        action: "source_routing",
        source: code,
    )
  end

  it "routes the source case insensitive in the url to a parameter" do
    mangled_code = "eXAMpLe"
    expect(get: "/#{mangled_code}").to route_to(
      controller: "public_pages",
        action: "source_routing",
        source: mangled_code,
    )
  end

  it "routes correctly with locale" do
    expect(get: "/es/#{code}").to route_to(
      controller: "public_pages",
        action: "source_routing",
        locale: "es",
        source: code,
    )
  end

  it "accepts arbitrary source parameters that contain only slug-like characters" do
    expect(get: "/4Rb1_trar-y").to route_to(
      controller: "public_pages",
      action: "source_routing",
      source: "4Rb1_trar-y",
     )
  end

  it "rejects arbitrary paths that contain non-slug-like characters" do
    expect(get: "/4Rb!_trar-y").not_to be_routable
  end
end
