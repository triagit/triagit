module Github
  class WebhookJob < ApplicationJob
    queue_as :default

    def perform(*args)
      unless args.present? && args[0].is_a?(Event) && args[0].repo.service == Constants::GITHUB
        return logger.error 'Invalid argument passed', args: args
      end
      event = args[0]
      rules = event.repo.rules
      rules[:rules].each do |rule|
        process_rule(event, rule)
      end
    end

    def process_rule(event, rule)
      # TODO: Calling every check for every event is expensive, because it leads to queue over-use
      # We can make this better later, keeping it simple for now as there is only one PR check
      case rule[:rule]
      when "pr_format"
        CheckPrFormatJob.perform_later event, rule[:name]
      end
    end
  end
end
