FactoryBot.define do
  factory :system_message do
    send_to { :all_users }
    association :user
    message { Faker::Movies::StarWars.quote }
    message_type { 'sms' }
  end
end
