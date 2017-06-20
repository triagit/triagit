class CreateEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :events do |t|
      t.references :repo, foreign_key: true
      t.string :name
      t.string :ref
      t.text :payload

      t.timestamps
    end
  end
end
