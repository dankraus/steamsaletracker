class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string :name
      t.decimal :price
      t.decimal :last_price
      t.timestamp :price_last_checked_at
      t.string :steam_url

      t.timestamps
    end
  end
end
