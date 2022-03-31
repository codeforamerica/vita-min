unless Rails.env.production?
  Seeder.new.run
end

Fraud::Indicators::Timezone.create(name: "America/Chicago", activated_at: DateTime.now)
Fraud::Indicators::Timezone.create(name: "America/Indiana/Indianapolis", activated_at: DateTime.now)
Fraud::Indicators::Timezone.create(name: "America/Indianapolis", activated_at: DateTime.now)
Fraud::Indicators::Timezone.create(name: "Mexico/Tijuana", activated_at: nil)
Fraud::Indicators::Timezone.create(name: "America/New_York", activated_at: DateTime.now)
Fraud::Indicators::Timezone.create(name: "America/Los_Angeles", activated_at: DateTime.now)

