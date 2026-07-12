import Observation

@MainActor
@Observable
public final class SplashViewModel {
    public private(set) var uiState = SplashUIState()
    public private(set) var effect: SplashEffect = .none

    public init() {}

    public func start() {
        uiState.isAnimating = true
        effect = .animationStarted
    }

    public func clearEffect() {
        effect = .none
    }
}
