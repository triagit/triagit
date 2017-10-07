module Github
  class AccountTriageJob < ApplicationJob
    queue_as :default

    def perform(*args)
      unless args.present? && args[0].is_a?(Account) && args[0].service == Constants::GITHUB
        return logger.error 'Invalid argument passed', args: args
      end
      account = args[0]
      logger.info self.class.name, account: account.ref
      account.repos.active.find_in_batches do |batch|
        batch.each do |repo|
          RepoTriageJob.perform_later repo
        end
      end
    end
  end
end