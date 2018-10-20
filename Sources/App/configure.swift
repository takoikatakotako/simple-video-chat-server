import Vapor
import Leaf
import MySQL
import FluentMySQL

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(LeafProvider())
    try services.register(MySQLProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    /// Use Leaf for rendering views
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
    
    // Configure a MySQL database
    let mysql = MySQLDatabase(config: MySQLDatabaseConfig(
        hostname: "host.name.sample",
        port: 3306,
        username: "username",
        password: "password",
        database: "database"))
    
    /// Register the configured MySQL database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: mysql, as: .mysql)
    services.register(databases)
    
    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Room.self, database: .mysql)
    services.register(migrations)

}
