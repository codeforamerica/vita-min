# == Schema Information
#
# Table name: greeter_organization_join_records
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  greeter_role_id :bigint           not null
#  vita_partner_id :bigint           not null
#
# Indexes
#
#  index_greeter_organization_join_records_on_greeter_role_id  (greeter_role_id)
#  index_greeter_organization_join_records_on_vita_partner_id  (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (greeter_role_id => greeter_roles.id)
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
require 'rails_helper'

RSpec.describe GreeterOrganizationJoinRecord, type: :model do
  describe "required fields" do
    let(:greeter_role) { GreeterRole.create }

    context "given a greeter role" do
      context "with no organization" do
        it "is not valid" do
          expect(described_class.new(greeter_role: greeter_role)).not_to be_valid
        end
      end

      context "with an organization" do
        it "is valid" do
          expect(described_class.new(organization: create(:organization), greeter_role: greeter_role)).to be_valid
        end
      end

      context "with a site" do
        it "is not valid" do
          expect(described_class.new(organization: create(:site), greeter_role: greeter_role)).not_to be_valid
        end
      end
    end
  end
end

