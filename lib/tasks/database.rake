require 'pg'

namespace :db do
  desc "Create the database"
  task :create do
    config = Rails.application.config.database_configuration[Rails.env]
    begin
      admin_conn = PG.connect(
        user: config["username"],
        password: config["password"],
        host: config["host"] || "localhost",
        port: config["port"] || 5432
      )
      admin_conn.exec("CREATE DATABASE \"#{config["database"]}\"")
      puts "Database #{config["database"]} created successfully"
    rescue PG::DuplicateDatabase
      puts "Database #{config["database"]} already exists"
    rescue PG::ConnectionBad => e
      puts "Connection failed: #{e.message}"
      raise
    ensure
      admin_conn&.close
    end
  end

  desc "Drop the database"
  task :drop do
    config = Rails.application.config.database_configuration[Rails.env]
    begin
      admin_conn = PG.connect(
        user: config["username"],
        password: config["password"],
        host: config["host"] || "localhost",
        port: config["port"] || 5432
      )
      admin_conn.exec("DROP DATABASE IF EXISTS \"#{config["database"]}\"")
      puts "Database #{config["database"]} dropped successfully"
    ensure
      admin_conn&.close
    end
  end

  desc "Run migrations"
  task :migrate do
    config = Rails.application.config.database_configuration[Rails.env]
    conn = PG.connect(
      dbname: config["database"],
      user: config["username"],
      password: config["password"],
      host: config["host"] || "localhost",
      port: config["port"] || 5432
    )

    # Criar schema_migrations se não existir
    conn.exec("CREATE TABLE IF NOT EXISTS schema_migrations (version VARCHAR(255) PRIMARY KEY)")

    # Listar migrations já aplicadas
    applied_versions = conn.exec("SELECT version FROM schema_migrations").values.flatten
    puts "Applied migrations: #{applied_versions}"

    # Carregar e executar migrations
    migration_files = Dir[Rails.root.join("db/migrate/*.rb")].sort
    migration_files.each do |file|
      version = File.basename(file, ".rb").split("_").first
      if applied_versions.include?(version)
        puts "Skipping already applied migration: #{File.basename(file)}"
        next
      end

      puts "Applying migration: #{File.basename(file)}"
      require file
      migration_class = File.basename(file, ".rb").split("_")[1..-1].join("_").camelize.constantize
      migration_class.new.up
      conn.exec_params("INSERT INTO schema_migrations (version) VALUES ($1)", [version])
      puts "Migrated #{File.basename(file)}"
    end
  ensure
    conn&.close
  end

  desc "Rollback the last migration"
  task :rollback do
    config = Rails.application.config.database_configuration[Rails.env]
    conn = PG.connect(
      dbname: config["database"],
      user: config["username"],
      password: config["password"],
      host: config["host"] || "localhost",
      port: config["port"] || 5432
    )

    if conn.exec("SELECT * FROM pg_tables WHERE tablename = 'schema_migrations'").ntuples > 0
      last_version = conn.exec("SELECT version FROM schema_migrations ORDER BY version DESC LIMIT 1")[0]["version"]
      migration_file = Dir[Rails.root.join("db/migrate/#{last_version}*.rb")].first
      if migration_file
        require migration_file
        migration_class = File.basename(migration_file, ".rb").split("_")[1..-1].join("_").camelize.constantize
        migration_class.new.down
        conn.exec_params("DELETE FROM schema_migrations WHERE version = $1", [last_version])
        puts "Rolled back #{File.basename(migration_file)}"
      end
    end
  ensure
    conn&.close
  end
end
