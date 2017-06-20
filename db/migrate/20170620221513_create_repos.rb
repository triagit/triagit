class CreateRepos < ActiveRecord::Migration[5.1]
  def change
    create_table :repos do |t|
      t.references :account, foreign_key: true
      t.string :name
      t.string :ref
      t.text :payload
      t.text :rules

      t.timestamps
    end
  end
end
