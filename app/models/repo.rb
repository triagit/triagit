# == Schema Information
#
# Table name: repos
#
#  id         :uuid             not null, primary key
#  account_id :uuid
#  name       :string           not null
#  service    :string(2)        not null
#  ref        :string           not null
#  payload    :text             not null
#  rules      :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_repos_on_account_id       (account_id)
#  index_repos_on_service          (service)
#  index_repos_on_service_and_ref  (service,ref) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#

class Repo < ApplicationRecord
  belongs_to :account
  serialize :payload, JSONSerializer
end
