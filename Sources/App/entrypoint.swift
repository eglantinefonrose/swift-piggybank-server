import Vapor
import Dispatch
import Logging

/// This extension is temporary and can be removed once Vapor gets this support.
private extension Vapor.Application {
    static let baseExecutionQueue = DispatchQueue(label: "vapor.codes.entrypoint")
    
    func runFromAsyncMainEntrypoint() async throws {
        try await withCheckedThrowingContinuation { continuation in
            Vapor.Application.baseExecutionQueue.async { [self] in
                do {
                    try self.run()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

@main
enum Entrypoint {
    
    static func main() async throws {
        
//        // Vérifiez s'il y a suffisamment d'arguments
//        guard CommandLine.argc == 2 else {
//            print("\n   PiggyBankServer usage: \(CommandLine.arguments[0]) <serverPortNumber>\n")
//            return
//        }
//        // Récupérez l'argument entier depuis la ligne de commande
//        guard let serverPortNumber = Int(CommandLine.arguments[1]) else {
//            print("L'argument 'serverPortNumber' doit être un entier valide.")
//            return
//        }
        
        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env)
        let app = Application(env)
        
        // Make the server listen on all IP addresses of the machine
        app.http.server.configuration.hostname = "0.0.0.0";
        app.http.server.configuration.port = 8080;

        defer { app.shutdown() }
        
        do {
            try await configure(app)
        } catch {
            app.logger.report(error: error)
            throw error
        }
        try await app.runFromAsyncMainEntrypoint()

    }
    
}
