module Github
  class TriageAllAccountsJob < ApplicationJob
    queue_as :default

    def perform(*_args)
      # TODO: Handle pagination of large data
      logger.info 'TriageAllAccountsJob'
      Account.active.github.find_in_batches do |batch|
        batch.each do |account|
          TriageAccountJob.perform_later account
        end
      end
    end
  end
end
