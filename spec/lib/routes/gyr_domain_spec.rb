require 'rails_helper'

describe Routes::GyrDomain do
  let(:getctc) { instance_double(ActionDispatch::Request, host: "www.getctc.org") }
  let(:root_demo) { instance_double(ActionDispatch::Request, host: "demo.getyourrefund.org") }
  let(:root_localhost) { instance_double(ActionDispatch::Request, host: "localhost") }
  let(:root_staging_www) { instance_double(ActionDispatch::Request, host: "www.staging.getyourrefund.org") }

  let(:subject) { Routes::GyrDomain.new }

  describe "#matches?" do
    it 'returns true if the request host has an approved domain that is not the legacy getctc.org domain' do
      expect(subject.matches?(getctc)).to be_falsey
      expect(subject.matches?(root_demo)).to be_truthy
      expect(subject.matches?(root_localhost)).to be_truthy
      expect(subject.matches?(root_staging_www)).to be_truthy
    end
  end
end
