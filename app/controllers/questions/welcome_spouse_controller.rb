module Questions
  class WelcomeSpouseController < OverviewController
    def self.show?(intake)
      intake.users.count > 1
    end
  end
end