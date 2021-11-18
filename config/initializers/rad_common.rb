require "#{Gem::Specification.find_by_name('rad_common').gem_dir}/lib/core_extensions/active_record"\
        '/base/schema_validations'

ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym 'SMS'
  inflect.acronym 'PDF'
  inflect.acronym 'CRM'
  inflect.acronym 'CSV'
end

ActiveRecord::Base.prepend CoreExtensions::ActiveRecord::Base::SchemaValidations

Rails.application.config.rad_common = Rails.application.config_for(:rad_common)

Rails.application.config.assets.precompile += %w[rad_common/radbear_mailer.css rad_common/radbear_mailer_reset.css]

Rails.application.routes.default_url_options[:host] = Rails.configuration.rad_common.host_name

raise 'Missing admin_email in credentials' if Rails.application.credentials.admin_email.blank?
raise 'Missing from_email in credentials' if Rails.application.credentials.from_email.blank?

if Rails.configuration.rad_common.authy_enabled && Rails.application.credentials.authy_api_key.blank?
  raise 'Missing authy_api_key in credentials with authy_enabled = true'
end

if Rails.application.credentials.aws.blank? || Rails.application.credentials.aws[:s_3].blank?
  # this can be fixed in Rails 6.1 to not have to always have them present
  # https://bigbinary.com/blog/rails-6-1-allows-per-environment-configuration-support-for-active-storage
  raise 'Missing AWS S3 credentials'
end

if Rails.env.staging?
  class ChangeStagingEmailSubject
    def self.delivering_email(mail)
      mail.subject = "[STAGING] #{mail.subject}"
    end
  end

  ActionMailer::Base.register_interceptor(ChangeStagingEmailSubject)
end

Devise.setup do |config|
  config.mailer = 'RadbearDeviseMailer'
end

Audited.current_user_method = :true_user

Rails.configuration.to_prepare do
  ActiveStorage::Attachment.audited associated_with: :record
end

AuthTrail.geocode = false

module Kaminari
  # monkey patch to fix paging on engine routes
  # https://github.com/radicalbear/rad_common/pull/211/files
  # https://github.com/kaminari/kaminari/issues/457

  module Helpers
    class Tag
      def page_url_for(page)
        (@options[:routes_proxy] || @template).url_for @params.merge(@param_name => (page <= 1 ? nil : page))
      end
    end
  end
end
