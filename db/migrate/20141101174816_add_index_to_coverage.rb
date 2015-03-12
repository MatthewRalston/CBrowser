class AddIndexToCoverage < ActiveRecord::Migration
  def up
    add_index :coverages, :base
  end
  def down
    remove_index :coverages, :base
  end
end
