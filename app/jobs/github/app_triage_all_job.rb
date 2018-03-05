module Github
  class AppTriageAllJob < ApplicationJob
    queue_as :default

    def perform(*args)
      # TODO: Handle pagination of large data
      Account.active.github.find_in_batches do |batch|
        batch.each do |account|
          AccountTriageJob.perform_later account
        end
      end
    end
  end
end
