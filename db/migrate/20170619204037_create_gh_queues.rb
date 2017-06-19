class CreateGhQueues < ActiveRecord::Migration[5.1]
  def change
    create_table :gh_queues do |t|
      t.string :job
      t.string :ref
      t.text :payload

      t.timestamps
    end
  end
end
