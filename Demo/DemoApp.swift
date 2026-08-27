import SwiftUI
import ArchitectureToolSurface
import ArchitectureToolSurfaceUI

/// The host application for `ArchitectureToolSurface`.
///
/// The app deliberately owns one thing the library refuses to own: the context
/// budget. `SurfaceConfiguration` is a value the host supplies rather than a
/// default baked into the package, because the number of tokens an agent may
/// spend on tool schemas belongs to whoever is paying for the context window.
/// A library that picks it silently will pick it wrong for somebody.
///
/// This is also the compiled-in fallback in the sense the package means: it is
/// a designed state, not an accident. If a deployment supplies no
/// configuration, this is what runs, and it is written down here where a
/// reviewer can see it — not remotely settable, not inferred.
@main
struct DemoApp: App {

    /// Sized against the stand-in for Xcode 27's `mcpbridge`, which the fixture
    /// models as consuming 5,400 tokens across twelve tool schemas. 8,000 total
    /// leaves 2,600 for this server, which is enough for both essentials plus
    /// both situational tools once the two colliding names are qualified.
    ///
    /// Lower it and the console shows the surface refusing rather than
    /// degrading — which is the point of the panel.
    static let hostConfiguration = SurfaceConfiguration(
        contextBudget: TokenCount(8_000),
        responseBudget: TokenCount(4_000),
        collisionPrefix: "arch"
    )

    var body: some Scene {
        WindowGroup {
            ArchitectureConsoleView(configuration: Self.hostConfiguration)
        }
    }
}
