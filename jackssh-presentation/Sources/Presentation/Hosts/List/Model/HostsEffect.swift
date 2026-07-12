import Foundation

public enum HostsEffect: Equatable {
    case none
    case hostDeleted(UUID)
    case showError(String)
}
