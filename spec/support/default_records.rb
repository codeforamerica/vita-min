RSpec.configure do |config|
  config.before(:each) do |example|
    if example.metadata[:requires_default_vita_partners]
      Organization.find_or_create_by!(name: "GYR National Organization", allows_greeters: true)
      ctc_org = Organization.find_or_create_by!(name: "GetCTC.org", allows_greeters: false)
      Site.find_or_create_by!(name: "GetCTC.org (Site)", parent_organization: ctc_org)
    end
  end
end
