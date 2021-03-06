# frozen_string_literal: true

module Decidim
  # This command updates the user's notifictions settings.
  class UpdateNotificationsSettings < Rectify::Command
    # Updates a user's notifications settings.
    #
    # user - The user to be updated.
    # form - The form with the data.
    def initialize(user, form)
      @user = user
      @form = form
    end

    def call
      return broadcast(:invalid) unless @form.valid?

      update_notifications_settings
      @user.save!

      broadcast(:ok, @user)
    end

    private

    def update_notifications_settings
      @user.comments_notifications = @form.comments_notifications
      @user.replies_notifications = @form.replies_notifications
      @user.newsletter_notifications = @form.newsletter_notifications
    end
  end
end
