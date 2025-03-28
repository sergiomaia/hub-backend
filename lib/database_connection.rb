# lib/database_connection.rb
require 'pg'
require 'connection_pool'
require 'sorbet-runtime'

module DatabaseConnection
  extend T::Sig

  POOL_SIZE = 5
  POOL_TIMEOUT = 5

  # Definir o pool como uma constante tipada corretamente
  CONNECTION_POOL = T.let(
    ConnectionPool.new(size: POOL_SIZE, timeout: POOL_TIMEOUT) do
      PG.connect(
        dbname: Rails.configuration.database_configuration[Rails.env]["database"],
        user: Rails.configuration.database_configuration[Rails.env]["username"],
        password: Rails.configuration.database_configuration[Rails.env]["password"],
        host: Rails.configuration.database_configuration[Rails.env]["host"] || "localhost",
        port: Rails.configuration.database_configuration[Rails.env]["port"] || 5432
      )
    end,
    ConnectionPool # Usamos apenas a classe como tipo base; não há suporte nativo para ConnectionPool[T] no runtime
  )

  sig { params(query: String, params: T::Array[T.untyped]).returns(PG::Result) }
  def self.execute(query, params = [])
    CONNECTION_POOL.with do |conn|
      conn.exec_params(query, params)
    end
  end

  sig { void }
  def self.shutdown
    CONNECTION_POOL.shutdown { |conn| conn.close }
  end
end
