# == Schema Information
#
# Table name: account_users
#
#  id         :uuid             not null, primary key
#  account_id :uuid
#  user_id    :uuid
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_account_users_on_account_id              (account_id)
#  index_account_users_on_user_id                 (user_id)
#  index_account_users_on_user_id_and_account_id  (user_id,account_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (user_id => users.id)
#

require 'test_helper'

class AccountUserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
