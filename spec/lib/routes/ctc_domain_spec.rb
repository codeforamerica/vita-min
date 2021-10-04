require 'rails_helper'

describe Routes::CtcDomain do
  let(:ctc_localhost) { instance_double(ActionDispatch::Request, host: "ctc.localhost") }
  let(:ctc_heroku) { instance_double(ActionDispatch::Request, host: "ctc-vita-min-pr-42.herokuapp.com") }
  let(:ctc_prod) { instance_double(ActionDispatch::Request, host: "www.getctc.org") }
  let(:root_demo) { instance_double(ActionDispatch::Request, host: "demo.getyourrefund.org") }
  let(:root_localhost) { instance_double(ActionDispatch::Request, host: "localhost") }

  let(:subject) { Routes::CtcDomain.new }

  describe "#matches?" do
    it 'returns true if the request host is a ctc domain' do
      expect(subject.matches?(ctc_localhost)).to be_truthy
      expect(subject.matches?(ctc_heroku)).to be_truthy
      expect(subject.matches?(ctc_prod)).to be_truthy
      expect(subject.matches?(root_demo)).to be_falsey
      expect(subject.matches?(root_localhost)).to be_falsey
    end
  end
end
