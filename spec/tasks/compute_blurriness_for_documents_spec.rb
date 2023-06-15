# frozen_string_literal: true

require "rails_helper"

describe "compute_blurriness_for_documents:batch_proces" do
  include_context "rake"

  it "changes no documents with existing scores"
  it "adds scores for documents with no scores"
  it "does not compute scores for non-compatible documents"
end

describe "compute_blurriness_for_documents:report" do
  include_context "rake"

  it "only includes compatible documents"
  it "provides URLs for reported documents"
  it "provides scoring for reported documents"
end