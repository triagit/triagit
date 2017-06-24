# == Schema Information
#
# Table name: repos
#
#  id         :integer          not null, primary key
#  account_id :integer
#  name       :string
#  ref        :string
#  payload    :text
#  rules      :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_repos_on_account_id  (account_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#

class Repo < ApplicationRecord
  belongs_to :account
end
