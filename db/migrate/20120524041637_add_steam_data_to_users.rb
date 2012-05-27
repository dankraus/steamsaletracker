class AddSteamDataToUsers < ActiveRecord::Migration
  def change
    add_column :users, :steam_id, :integer
    add_column :users, :name, :string
    add_column :users, :persona_name, :string
    add_column :users, :steam_profile_url, :string
    add_column :users, :avatar, :string
    add_column :users, :avatar_medium, :string
    add_column :users, :avatar_full, :string
    add_column :users, :country, :string

    add_index :users, :steam_id, :unique => true
  end
end
