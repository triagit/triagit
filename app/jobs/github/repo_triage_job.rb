module Github
  class RepoTriageJob < ApplicationJob
    queue_as :default

    def perform(*args)
      unless args.present? && args[0].is_a?(Repo) && args[0].service == Constants::GITHUB
        return logger.error 'Invalid argument passed', args: args
      end
      repo = args[0]
      logger.info self.class.name, repo: repo.ref
      RepoCloseOutdatedIssuesJob.perform_later repo
    end
  end
end
