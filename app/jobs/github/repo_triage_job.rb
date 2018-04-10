module Github
  class RepoTriageJob < ApplicationJob
    queue_as :default

    def perform(*args)
      unless args.present? && args[0].is_a?(Repo) && args[0].service == Constants::GITHUB
        return logger.error 'Invalid argument passed', args: args
      end
      repo = args[0]
      logger.info "Triaging repo", repo: repo.ref

      rules = repo.rules || []
      rules[:rules].each do |rule|
        process_rule(repo, rule)
      end
    end

    def process_rule(repo, rule)
      case rule[:rule]
      when "close_outdated_issues"
        RepoCloseOutdatedIssuesJob.perform_later repo, rule[:name]
      when "close_outdated_pr"
        RepoCloseOutdatedPrsJob.perform_later repo, rule[:name]
      else
        # TODO: Ignore PR checks and other "known" rules that are not scheduled
      end
    end
  end
end
