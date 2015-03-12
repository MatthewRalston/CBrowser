class CreateCoverages < ActiveRecord::Migration
  def up
    create_table :coverages do |t|
      t.string :chr
      t.integer :base
      t.string :stress
      t.string :time
      t.string :rep
      t.string :strand
      t.integer :cov
      t.integer :tex

      t.timestamps
    end
  end
  def down
    drop_table :coverages
  end
end
