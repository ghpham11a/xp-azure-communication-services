import Foundation

@Observable
class HomeViewModel {
    let sharedState: SharedState
    private let tokensRepo: TokensRepo

    init(sharedState: SharedState, tokensRepo: TokensRepo) {
        self.sharedState = sharedState
        self.tokensRepo = tokensRepo
    }

    func connect(displayName: String) {
        Task { @MainActor in
            sharedState.isLoading = true
            sharedState.error = nil

            do {
                let response = try await tokensRepo.createToken(displayName: displayName)
                let user = AcsUser(
                    userId: response.userId,
                    token: response.token,
                    displayName: displayName
                )
                sharedState.connect(user: user)
            } catch {
                sharedState.error = error.localizedDescription
            }

            sharedState.isLoading = false
        }
    }
}
