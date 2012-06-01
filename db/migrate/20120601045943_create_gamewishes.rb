class CreateGamewishes < ActiveRecord::Migration
  def up
    create_table :gamewishes, :id => false do |t|
      t.integer :game_id
      t.integer :user_id

      t.timestamps
    end
  end
  def down
  	drop_table :gamewishes
  end
end
