class RadSeeder
  attr_accessor :users

  def seed!
    display_log 'seeding base tables'

    SecurityRole.seed_items if SecurityRole.count.zero?
    UserStatus.seed_items if UserStatus.count.zero?

    seed_notification_types
    seed_users
    seed_company

    @users = User.all
  end

  private

    def display_log(message)
      puts message
    end

    def seed_notification_types
      return if NotificationType.count.positive?

      NotificationType.seed_items
    end

    def seed_users
      return unless (Rails.env.development? || Company.staging?) && User.count.zero?

      # TODO: is this needed?
      # User.skip_callback(:save, :after, :notify_user_approved, raise: false)

      display_log 'seeding users'

      seeded_user_config.each do |seeded_user|
        attributes = { email: seeded_user[:email],
                       user_status: user_status,
                       first_name: seeded_user[:first_name],
                       last_name: seeded_user[:last_name],
                       security_roles: user_security_roles(seeded_user) }

        if seeded_user[:trait].present?
          FactoryBot.create seeded_user[:factory], seeded_user[:trait], attributes
        else
          FactoryBot.create seeded_user[:factory], attributes
        end
      end
    end

    def seed_company
      return if Company.count.positive?

      FactoryBot.create :company, email: seeded_user_config.first[:email]
    end

    def seeded_user_config
      seeded_user_json.map(&:symbolize_keys)
    end

    def seeded_user_json
      return JSON.parse(ENV.fetch('SEEDED_USERS')) if Rails.env.production?

      JSON.parse(File.read(Rails.root.join('db/seeded_users.json')))
    end

    def user_security_roles(seeded_user)
      return [] if seeded_user[:security_role].blank?

      [role_by_name(seeded_user[:security_role])]
    end

    def user_role
      role_by_name 'User'
    end

    def admin_user
      first_user_in_role 'Admin'
    end

    def first_user_in_role(name)
      role_by_name(name).users.by_id.first
    end

    def role_by_name(name)
      SecurityRole.find_by!(name: name)
    end

    def random_user
      users.sample
    end

    def user_status
      UserStatus.default_active_status
    end

    def month_begin
      Date.current.beginning_of_month
    end

    def random_date(from_date, to_date)
      Faker::Date.unique.between(from: from_date, to: to_date)
    end
end