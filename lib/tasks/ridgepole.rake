namespace :ridgepole do
  desc 'Create a Schemafile file that is portable against any DB supported by Ridgepole'
  task :export, :rails_env do
    sh [
      'ridgepole --export -o db/Schemafile',
      '-c config/database.yml',
      "--ignore-tables '#{ignore_tables}'",
    ].join(' ')
  end

  desc 'Apply a Schemafile file into the database'
  task :apply, :rails_env do
    sh [
      'ridgepole --apply -f db/Schemafile',
      '-c config/database.yml',
      "--ignore-tables '#{ignore_tables}'",
    ].join(' ')
  end

  def ignore_tables
    ActiveRecord::SchemaDumper.ignore_tables.map(&:source).join(',')
  end
end

Rake.application.lookup('db:migrate').clear
desc 'Migrate the database by Ridgepole'
task 'db:migrate' do
  Rake::Task['ridgepole:apply'].invoke

  if Rails.env.development?
    Rake::Task['ridgepole:export'].invoke
    Annotate::Migration.update_annotations
  end
end
