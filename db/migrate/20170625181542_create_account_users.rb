class CreateAccountUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :account_users, id: :uuid do |t|
      t.references :account, foreign_key: true, type: :uuid
      t.references :user, foreign_key: true, type: :uuid

      t.timestamps
    end
    add_index :account_users, [:user_id, :account_id], unique: true
  end
end
