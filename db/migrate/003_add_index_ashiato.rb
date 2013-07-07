class AddIndexAshiato < ActiveRecord::Migration
  def self.up
    add_index :ashiato, :user_id
  end

  def self.down
    remove_index :ashiato, :user_id
  end
end
