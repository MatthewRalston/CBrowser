# lib/tasks/db.rake

namespace :db do

  desc "Dumps the database to db/APP_NAME.dump"
  task :backup => :environment do
    cmd = nil
    with_config do |app, host, db, user|
      puts("App:#{app}\nHost:#{host}\nDB:#{db}\nUser:#{user}")
      cmd = "mysqldump -u #{user} -p #{db} | gzip > #{Rails.root}/db/CBrowser.dump.gz"
      #cmd = "pg_dump --username #{user} --verbose --no-owner --no-acl --format=c #{db} > #{Rails.root}/db/#{app}.dump"
    end
    puts cmd
    exec cmd
  end
  
  desc "Restores the database dump at db/APP_NAME.dump."
  task :restore => :environment do
    cmd = nil
    with_config do |app, host, db, user|
      cmd = "mysql -u #{user} -p #{db} < #{Rails.root}/db/CBrowser.dump"
      #cmd = "pg_restore --verbose --host #{host} --username #{user} --clean --no-owner --no-acl --dbname #{db} #{Rails.root}/db/#{app}.dump"
    end
    Rake::Task["db:drop"].invoke
    Rake::Task["db:create"].invoke
    puts cmd
    exec cmd
  end

  desc "Imports data from :file into :table"
  task :import, [:file,:tabl] => :environment do |t,args|
    require 'csv'
    CSV.foreach(args[:file]) do |record|
      args[:tabl].constantize.create({"chr"=>record[0],"base"=>record[1],"stress"=>record[2],"time"=>record[3],"rep"=>record[4],"strand"=>record[5],"cov"=>record[6],"tex"=>record[7]})
    end
  end

private

def with_config
yield Rails.application.class.parent_name.underscore,
ActiveRecord::Base.connection_config[:host],
ActiveRecord::Base.connection_config[:database],
ActiveRecord::Base.connection_config[:username]
#ActiveRecord::Base.connection_config[:password]
end

end
