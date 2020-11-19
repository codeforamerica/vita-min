require "rails_helper"

# Rspec.describe MessageSending do
#
#   before do
#     class FakesController < ApplicationController
#       include MessageSending
#     end
#   end
#   after { Object.send :remove_const, :FakesController }
#   let(:subject) { FakesController.new }
#
#   describe 'my_method_to_test' do
#     before { sign_in user}
#     it { expect(subject.my_method_to_test).to eq('expected result') }
#   end
#
# end

RSpec.describe MessageSending, type: :controller do
  let(:intake) { create :intake, email_address: "client@example.com", sms_phone_number: "+14155551212"}
  let!(:client) { intake.client }
  let!(:user) { create :user }

  controller(ApplicationController) do
    include MessageSending

    def email
      client = Client.last
      send_email(client, body: "hello")
    end
  end

  before do
    routes.draw {
      post 'email' => 'anonymous#email'
    }
    sign_in user
  end

  describe "#send_email" do
    it "broadcasts the email to client channel" do
      post :email
      outgoing_email = OutgoingEmail.last
      expect(ClientChannel).to have_received(:broadcast_contact_record).with(outgoing_email)
    end
  end
end