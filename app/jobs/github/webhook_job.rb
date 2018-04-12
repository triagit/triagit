module Github
  class WebhookJob < ApplicationJob
    queue_as :default

    def perform(*args)
      unless args.present? && args[0].is_a?(Event) && args[0].repo.service == Constants::GITHUB
        return logger.error 'Invalid argument passed', args: args
      end
      event = args[0]
      rules = event.repo.rules
      (rules[:rules] || []).each do |rule|
        process_rule(event, rule)
      end
      RepoSyncJob.perform_later event.repo if must_sync?(event)
    end

    def must_sync?(event)
      return event.name == 'push' && event.payload[:ref] == "refs/heads/master" &&
        event.payload[:commits].any? do |c|
          c[:added].include?(".github/triagit.yaml") ||
          c[:modified].include?(".github/triagit.yaml")
        end

    end

    def process_rule(event, rule)
      # TODO: Calling every check for every event is expensive, because it leads to queue over-use
      # We can make this better later, keeping it simple for now as there is only one PR check
      case rule[:rule]
      when "pr_format"
        CheckPrFormatJob.perform_later event: event, rule_name: rule[:name]
      when "pr_size_check"
        CheckPrSizeJob.perform_later event: event, rule_name: rule[:name]
      end
    end
  end
end
