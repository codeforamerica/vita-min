# == Schema Information
#
# Table name: coalitions
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_coalitions_on_name  (name) UNIQUE
#
require "rails_helper"

describe Coalition, type: :model do
  describe "#name" do
    context "with an existing coalition" do
      before { Coalition.create(name: "Koala Koalition")}

      context "when instantiating a second coalition with the same name" do
        it "adds a validation error" do
          coalition = Coalition.new(name: "Koala Koalition")

          expect(coalition).not_to be_valid
          expect(coalition.errors).to include :name
        end
      end
    end
  end
end
