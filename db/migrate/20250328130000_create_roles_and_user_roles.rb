require_relative '../../lib/database_connection'

class CreateRolesAndUserRoles
  def up
    execute <<-SQL
      CREATE TABLE roles (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        key VARCHAR(255) NOT NULL UNIQUE,
        created_at TIMESTAMP NOT NULL DEFAULT NOW(),
        updated_at TIMESTAMP NOT NULL DEFAULT NOW()
      );
    SQL

    execute <<-SQL
      CREATE TABLE user_roles (
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        role_id INTEGER NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
        PRIMARY KEY (user_id, role_id),
        created_at TIMESTAMP NOT NULL DEFAULT NOW()
      );
    SQL

    execute <<-SQL
      INSERT INTO roles (name, key) VALUES
        ('Candidate', 'candidate'),
        ('Recruiter', 'recruiter'),
        ('Analyst', 'analyst'),
        ('Admin', 'admin'),
        ('Super Admin', 'super_admin')
      ON CONFLICT (key) DO NOTHING;
    SQL
  end

  def down
    execute <<-SQL
      DROP TABLE user_roles;
    SQL

    execute <<-SQL
      DROP TABLE roles;
    SQL
  end

  private

  def execute(sql)
    DatabaseConnection.execute(sql)
  end
end
