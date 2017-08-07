module Github
  class TriageRepoJob < ApplicationJob
    queue_as :default

    def perform(*args)
      unless args.present? && args[0].is_a?(Repo) && args[0].service == Constants::GITHUB
        return logger.error 'Invalid argument passed', args: args
      end
      repo = args[0]
      logger.info 'Triaging repo', repo: repo.ref
      CloseOutdatedIssuesJob.perform_later repo
    end
  end
end
