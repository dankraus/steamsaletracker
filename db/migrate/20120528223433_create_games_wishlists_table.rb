class CreateGamesUsersTable < ActiveRecord::Migration
  def up
  	create_table :games_users, :id => false do |t|
      t.integer :game_id
      t.integer :user_id
    end
  end

  def down
  end
end
