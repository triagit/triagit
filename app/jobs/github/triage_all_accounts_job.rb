module Github
  class TriageAllAccountsJob < ApplicationJob
    queue_as :default

    def perform(*_args)
      # TODO: Handle pagination of large data
      logger.info 'Starting', self.class.name
      Account.active.github.find_in_batches do |batch|
        batch.each do |account|
          logger.info 'Queuing', account: account
          TriageAccountJob.perform_later account
        end
      end
    end
  end
end
