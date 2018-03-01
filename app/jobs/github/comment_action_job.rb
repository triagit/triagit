module Github
  class CommentActionJob < ApplicationJob
    queue_as :default

    def perform(args)
      rule = Rule.new(args)
      rule.validate!
      rule.execute
    end

    class Rule
      ACTIONS = %w(add add_or_update delete)
      EXPIRES_IN = 7.days

      include ActiveModel::Model
      include SemanticLogger::Loggable
      attr_accessor :repo, :rule_name, :issue_or_pr, :action, :comment

      validates :repo, presence: true
      validates :rule_name, presence: true
      validates :issue_or_pr, presence: true
      validates :action, presence: true, inclusion: { in: ACTIONS }
      validates_each :repo do |record, attr, repo|
        record.errors.add(attr, 'must be a Repo') unless repo.is_a?(Repo)
      end

      def execute
        self.send(action) if self.respond_to?(action)
      end

      def add
        comment_id = api_client.add_comment(repo.ref, issue_or_pr, comment).id
        Rails.cache.write cache_key, comment_id, expires_in: EXPIRES_IN
      end

      def update
        comment_id = Rails.cache.read cache_key
        api_client.update_comment repo.ref, comment_id, comment
        Rails.cache.write cache_key, comment_id, expires_in: EXPIRES_IN
      end

      def add_or_update
        if Rails.cache.exist?(cache_key)
          update rescue add
        else
          add
        end
      end

      def delete
        comment_id = Rails.cache.read cache_key
        api_client.delete_comment repo.ref, comment_id
        Rails.cache.delete cache_key
      end

      def api_client
        @api_client ||= GithubClient.instance.new_repo_client(repo)
      end

      def cache_key
        "#{Constants::GITHUB}:#{repo.ref}:#{rule_name}:#{issue_or_pr}:c"
      end
    end
  end
end
