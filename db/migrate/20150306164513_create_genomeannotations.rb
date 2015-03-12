class CreateGenomeannotations < ActiveRecord::Migration
  def up
    create_table :genomeannotations do |t|
      t.string :chr
      t.string :name
      t.string :author
      t.string :feature
      t.integer :start_site
      t.integer :stop_site
      t.string :strand
      t.string :technique
      t.string :journal
      t.date :date
      t.string :extra

      t.timestamps
    end    
  end
  def down
    drop_table :genomeannotations
  end
end
