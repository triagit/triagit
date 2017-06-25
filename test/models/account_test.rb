# == Schema Information
#
# Table name: accounts
#
#  id         :uuid             not null, primary key
#  token      :string           not null
#  name       :string           not null
#  service    :string(2)        not null
#  plan       :string(4)        not null
#  ref        :string           not null
#  payload    :text             not null
#  rules      :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_accounts_on_service          (service)
#  index_accounts_on_service_and_ref  (service,ref) UNIQUE
#

require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
