module Admin
  class CleanupJob < ApplicationJob
    queue_as :default

    def perform(*args)
      # Remove events older than 30 days
      Event.where("created_at < ?", 30.days.ago).delete_all
    end
  end
end
