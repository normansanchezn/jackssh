import Domain

public enum HostEditorEffect: Equatable {
    case none
    case saved(Domain.Host)
    case showError(String)
}
