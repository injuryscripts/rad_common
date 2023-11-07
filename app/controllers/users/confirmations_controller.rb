module Users
  class ConfirmationsController < Devise::ConfirmationsController
    def show
      super
      Notifications::NewUserSignedUpNotification.main.notify!(resource) if resource.errors.empty?
      resource.accept_invitation! if resource.invitation_accepted_at.nil?
    end
  end
end
