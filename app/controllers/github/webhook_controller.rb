module Github
  class WebhookController < BaseController
    WEBHOOK_TOKEN = ENV['GITHUB_WEBHOOK_TOKEN']

    def create
      payload = request.raw_post
      return head 403 unless verify_signature(payload)

      repo = Repo.active.find_by(ref: request.params['repository']['full_name'], service: Constants::GITHUB) rescue nil
      return head 400 unless repo

      event = Event.create! name: request.env['HTTP_X_GITHUB_EVENT'], ref: request.env['HTTP_X_GITHUB_DELIVERY'],
        status: Constants::STATUS_ACTIVE, payload: request.params, repo: repo
      Github::WebhookJob.perform_later event
    end

    private

    def verify_signature(payload)
      signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), WEBHOOK_TOKEN, payload)
      Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'] || '')
    end
  end
end
