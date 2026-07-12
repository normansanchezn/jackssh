public enum AuthFlowEffect: Equatable {
    case none
    case stepChanged(AuthFlowUIState.Step)
}
