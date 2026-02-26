import Foundation
import Swinject

final class DependencyContainer {
    static let shared = DependencyContainer()
    private let container = Container()

    private init() {
        registerNetworking()
        registerRepositories()
        registerSharedState()
        registerRouteManager()
        registerViewModels()
    }

    func resolve<T>(_ type: T.Type) -> T {
        container.resolve(type)!
    }

    // MARK: - Registrations

    private func registerNetworking() {
        container.register(Networking.self) { _ in
            NetworkService()
        }.inObjectScope(.container)
    }

    private func registerRepositories() {
        container.register(TokensRepo.self) { r in
            TokensRepository(networking: r.resolve(Networking.self)!)
        }.inObjectScope(.container)

        container.register(ChatRepo.self) { r in
            ChatRepository(networking: r.resolve(Networking.self)!)
        }.inObjectScope(.container)
    }

    private func registerSharedState() {
        container.register(SharedState.self) { _ in
            SharedState()
        }.inObjectScope(.container)
    }

    private func registerRouteManager() {
        container.register(RouteManager.self) { r in
            RouteManager(sharedState: r.resolve(SharedState.self)!)
        }.inObjectScope(.container)
    }

    private func registerViewModels() {
        container.register(HomeViewModel.self) { r in
            HomeViewModel(
                sharedState: r.resolve(SharedState.self)!,
                tokensRepo: r.resolve(TokensRepo.self)!
            )
        }

        container.register(ChatSetupViewModel.self) { r in
            ChatSetupViewModel(
                sharedState: r.resolve(SharedState.self)!,
                chatRepo: r.resolve(ChatRepo.self)!,
                routeManager: r.resolve(RouteManager.self)!
            )
        }

        container.register(CallSetupViewModel.self) { r in
            CallSetupViewModel(
                sharedState: r.resolve(SharedState.self)!,
                routeManager: r.resolve(RouteManager.self)!
            )
        }

        container.register(ChatViewModel.self) { r in
            ChatViewModel(
                sharedState: r.resolve(SharedState.self)!,
                routeManager: r.resolve(RouteManager.self)!
            )
        }

        container.register(CallingViewModel.self) { r in
            CallingViewModel(
                sharedState: r.resolve(SharedState.self)!,
                routeManager: r.resolve(RouteManager.self)!
            )
        }
    }
}
