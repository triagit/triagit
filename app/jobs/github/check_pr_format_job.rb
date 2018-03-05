module Github
  class CheckPrFormatJob < ApplicationJob
    queue_as :default

    def perform(args)
      rule = Rule.new(args)
      rule.execute if rule.valid?
    end

    class Rule
      include ActiveModel::Model
      include SemanticLogger::Loggable
      attr_accessor :event, :rule_name

      # https://developer.github.com/v3/activity/events/types/#pullrequestevent
      WEBHOOK_EVENT_NAME = 'pull_request'
      WEBHOOK_EVENT_ACTIONS = ['opened', 'edited', 'reopened']

      validates :event, :rule_name, :rule, presence: true
      validate :validate_event

      def validate_event
        unless event.name == WEBHOOK_EVENT_NAME and WEBHOOK_EVENT_ACTIONS.include?(event.payload[:action])
          errors.add :event, "Not applicable"
        end
      end

      def execute
        title = event.payload[:pull_request][:title]
        title_patterns = [ rule[:options][:match_title] ].flatten.compact
        title_matches = title_patterns.all? { |p| Regexp.new(p, "im").match?(title) }
        title_matches ? self.positive : self.negative
      end

      def positive
        if option_label.present?
          LabelActionJob.perform_later repo: repo, rule_name: rule_name,
            issue_or_pr: pr_number, action: "delete", label: option_label
        end
        if option_comment.present?
          CommentActionJob.perform_later repo: repo, rule_name: rule_name,
            issue_or_pr: pr_number, action: "delete"
        end
      end

      def negative
        if option_label.present?
          LabelActionJob.perform_later repo: repo, rule_name: rule_name,
            issue_or_pr: pr_number, action: "add", label: option_label
        end
        if option_comment.present?
          CommentActionJob.perform_later repo: repo, rule_name: rule_name,
            issue_or_pr: pr_number, action: "add_or_update", comment: option_comment
        end
      end

      def repo
        event.repo
      end

      def rule
        @rule ||= event.repo.rules[:rules].find{ |r| r[:name] == rule_name }
      end

      def pr_number
        event.payload[:pull_request][:number]
      end

      def option_label
        rule[:options][:apply_label]
      end

      def option_comment
        rule[:options][:add_comment]
      end
    end
  end
end
