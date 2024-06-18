require "rails_helper"

RSpec.describe ClientSortable, type: :controller do
  let(:cookies) { double }

  controller(ApplicationController) do
    include ClientSortable

    private

    def filter_cookie_name
      "some_filter_cookie_name"
    end
  end

  before do
    allow(controller).to receive(:cookies).and_return(cookies)
    allow(cookies).to receive(:delete)
    allow(cookies).to receive(:[]=)
    allow(cookies).to receive(:[])

    allow(subject).to receive(:params).and_return params
  end

  context "with a clear param" do
    let(:params) do
      {
        clear: true,
        assigned_user_id: 1
      }
    end

    before do
      allow(cookies).to receive(:delete)
      allow(cookies).to receive(:[]).with(anything)
    end

    it "removes the filter cookie" do
      subject.send(:setup_sortable_client)
      expect(cookies).to have_received(:delete).with("some_filter_cookie_name")
    end
  end

  context "#vita_partners_for_tagify" do
    let(:orgs) do
      [
        Organization.create(name: "Org A"),
        Organization.create(name: "Org B")
      ]
    end
    before do
      controller.instance_variable_set("@vita_partners", orgs)
    end

    context "with no filters" do
      let(:params) { {} }
      it "returns a blank string" do
        subject.send(:setup_sortable_client)
        expect(subject.send(:vita_partners_for_tagify)).to be_nil
      end
    end

    context "with filters in the new format" do
      let(:params) do
        {
          vita_partners: orgs.map(&:id).to_json
        }
      end
      it "returns a filters in tagify format" do
        subject.send(:setup_sortable_client)
        expected = orgs.map do |org|
          {id: org.id, name: org.name, parentName: nil, value: org.id}
        end.to_json
        expect(subject.send(:vita_partners_for_tagify)).to eq expected
      end
    end

    context "with filters in tagify format" do
      let(:vita_partners) do
        orgs.map do |org|
          {id: org.id, name: org.name, parentName: nil, value: org.id}
        end.to_json
      end
      let(:params) do
        { vita_partners: vita_partners }
      end
      it "returns filters in tagify format" do
        subject.send(:setup_sortable_client)
        expect(subject.send(:vita_partners_for_tagify)).to eq vita_partners
      end
    end
  end
end
