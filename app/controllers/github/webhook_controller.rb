module Github
  class WebhookController < BaseController
    WEBHOOK_TOKEN = ENV['GITHUB_WEBHOOK_TOKEN']

    def create
      payload = request.raw_post
      return head 403 unless verify_signature(payload)
    end

    private

    def verify_signature(payload)
      signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), WEBHOOK_TOKEN, payload)
      Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'] || '')
    end
  end
end
