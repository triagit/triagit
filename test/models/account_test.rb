# == Schema Information
#
# Table name: accounts
#
#  id         :integer          not null, primary key
#  token      :string
#  name       :string
#  service    :string
#  plan       :string
#  ref        :string
#  payload    :text
#  rules      :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
