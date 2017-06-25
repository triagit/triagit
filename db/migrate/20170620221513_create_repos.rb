class CreateRepos < ActiveRecord::Migration[5.1]
  def change
    create_table :repos, id: :uuid do |t|
      t.references :account, foreign_key: true, type: :uuid
      t.string :name, null: false
      t.string :service, limit: 2, null: false
      t.string :ref, null: false
      t.text :payload, null: false
      t.text :rules

      t.timestamps
    end
    add_index :repos, :service
    add_index :repos, [:service, :ref], unique: true
  end
end
