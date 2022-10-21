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
end
