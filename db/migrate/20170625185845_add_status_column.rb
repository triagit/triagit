class AddStatusColumn < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :status, :integer, limit: 2, null: false, default: Constants::STATUS_ACTIVE
    add_index :accounts, :status

    add_column :repos, :status, :integer, limit: 2, null: false, default: Constants::STATUS_ACTIVE
    add_index :repos, :status

    add_column :events, :status, :integer, limit: 2, null: false, default: Constants::STATUS_ACTIVE
    add_index :events, :status

    add_column :users, :status, :integer, limit: 2, null: false, default: Constants::STATUS_ACTIVE
    add_index :users, :status
  end
end
