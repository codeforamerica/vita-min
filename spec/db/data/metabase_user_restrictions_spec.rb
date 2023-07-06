require "rails_helper"

describe "RestrictiveAccessForMetabaseUser" do
  before do
    Rails.application.load_tasks
    Rake::Task['analytics:drop_views'].invoke
    Rake::Task['analytics:create_views'].invoke
  end

  context "when attempting intentional behavior" do
    it "can select tables from the analytics table" do
      expect {
        ActiveRecord::Base.connection.execute("
set role metabase;
select count(*) from analytics.team_role_members (vita_partner_id, id);
")
      }.not_to raise_exception(ActiveRecord::StatementInvalid, /permission denied/)

    end
  end

  context "when attempting unintentional behavior" do
    it "can't create new indicies" do
      expect {
        ActiveRecord::Base.connection.execute("
set role metabase;
create index no_way_vita_idx on analytics.team_role_members (vita_partner_id, id);
      ")
      }.to raise_exception(ActiveRecord::StatementInvalid, /permission denied/)
    end

    it "can't create new tables" do
      expect {
        ActiveRecord::Base.connection.execute("
set role metabase;
create table analytics.phony_table (number INTEGER, name TEXT);
      ")
      }.to raise_exception(ActiveRecord::StatementInvalid, /permission denied/)
    end
  end
end