require_relative '../../lib/database_connection'

class CreateUsers
  def up
    execute <<-SQL
      CREATE TABLE users (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        document VARCHAR(255) UNIQUE NOT NULL,
        created_at TIMESTAMP NOT NULL DEFAULT NOW(),
        updated_at TIMESTAMP NOT NULL DEFAULT NOW()
      );
    SQL

    execute <<-SQL
      CREATE INDEX idx_users_email ON users (email);
    SQL

    execute <<-SQL
      CREATE INDEX idx_users_document ON users (document);
    SQL
  end

  def down
    execute <<-SQL
      DROP TABLE users;
    SQL
  end

  private

  def execute(sql)
    DatabaseConnection.execute(sql)
  end
end
