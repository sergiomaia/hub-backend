# db/migrate/20250328140000_create_authentications.rb
require_relative '../../lib/database_connection'

class CreateAuthentications
  def up
    execute <<-SQL
      CREATE TABLE authentications (
        user_id INTEGER PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
        password_digest VARCHAR(255) NOT NULL,
        created_at TIMESTAMP NOT NULL DEFAULT NOW(),
        updated_at TIMESTAMP NOT NULL DEFAULT NOW()
      );
    SQL
  end

  def down
    execute <<-SQL
      DROP TABLE authentications;
    SQL
  end

  private

  def execute(sql)
    DatabaseConnection.execute(sql)
  end
end
