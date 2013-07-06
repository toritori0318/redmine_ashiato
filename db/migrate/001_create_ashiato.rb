class CreateAshiato < ActiveRecord::Migration
  def self.up
    create_table :ashiato do |t|
      t.column :ashiato_type, :string, :null => false
      t.column :ashiato_id, :integer, :null => false
      t.column :updated_on, :timestamp, :null => false
      t.column :user_id, :integer, :default => 0, :null => false
    end
  end

  def self.down
    drop_table :ashiato
  end
end

