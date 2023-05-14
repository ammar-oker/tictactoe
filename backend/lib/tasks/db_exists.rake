namespace :db do
  task :exists do
    begin
      Rake::Task['db:schema:dump'].invoke
    rescue ActiveRecord::NoDatabaseError
      exit 1
    end
    exit 0
  end
end
