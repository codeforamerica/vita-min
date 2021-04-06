# == Schema Information
#
# Table name: greeter_roles
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe GreeterRole, type: :model do
  describe "required fields" do
    context "without an organization or coalition" do
      it "is valid" do
        expect(described_class.new).to be_valid
      end
    end
  end
end
