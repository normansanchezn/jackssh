---
title: Welcome Architecture
tags:
  - jackssh
  - module/presentation
  - auth
  - welcome
  - mvvm
---

//
//  WelcomeArchitecture.md
//  jackssh-presentation
//
//  Created by Norman Sánchez on 12/07/26.
//

# Arquitectura de WelcomeView

Esta pantalla sigue el patrón **MVVM (Model-View-ViewModel)** con separación clara de responsabilidades.

## 📁 Estructura de Archivos

```
Welcome/
├── WelcomeView.swift         // Vista (UI)
├── WelcomeViewModel.swift    // ViewModel (Lógica)
├── WelcomeUIState.swift      // Estado Observable
└── WelcomeEffect.swift       // Efectos/Eventos One-Shot
```

## 🏗️ Componentes

### 1. **WelcomeView** (Vista)
- **Responsabilidad**: Presentación y UI
- **Características**:
  - Define la estructura visual
  - Inyecta el ViewModel usando `@StateObject`
  - Maneja efectos one-shot con `onChange`
  - Delega acciones al ViewModel

### 2. **WelcomeViewModel** (ViewModel)
- **Responsabilidad**: Lógica de negocio y coordinación
- **Características**:
  - Conforma `ObservableObject`
  - Expone `uiState` para estado observable
  - Expone `effect` para eventos one-shot
  - Métodos públicos para acciones del usuario (`onSignInTapped`, `onSignUpTapped`)
  - Manejo centralizado de errores
  - Permite inyección de dependencias (casos de uso, repositorios)

### 3. **WelcomeUIState** (Estado)
- **Responsabilidad**: Estado reactivo de la UI
- **Características**:
  - Conforma `ObservableObject`
  - Todas las propiedades son `@Published`
  - Representa el estado actual de la pantalla
  - Incluye: loading, error, datos de UI

### 4. **WelcomeEffect** (Efectos)
- **Responsabilidad**: Eventos one-shot
- **Características**:
  - Enum que representa acciones puntuales
  - No persiste en el estado
  - Se consume y limpia inmediatamente
  - Ejemplos: navegación, mostrar alertas

## 🔄 Flujo de Datos

```
Usuario toca botón
    ↓
WelcomeView llama viewModel.onSignInTapped()
    ↓
WelcomeViewModel ejecuta lógica
    ↓
ViewModel actualiza uiState (estado persistente)
    ↓
ViewModel emite effect (evento one-shot)
    ↓
WelcomeView reacciona al effect con onChange
    ↓
WelcomeView ejecuta navegación
    ↓
WelcomeView limpia el effect
```

## ✅ Ventajas de esta Arquitectura

1. **Separación de responsabilidades**: Cada componente tiene un propósito claro
2. **Testeable**: ViewModel puede testearse sin UI
3. **Reutilizable**: UIState y Effect pueden compartirse
4. **Escalable**: Fácil agregar nuevas funcionalidades
5. **Mantenible**: Código organizado y predecible
6. **Type-safe**: Uso de enums para efectos

## 🧪 Testing

```swift
@Test("Sign in actualiza el estado correctamente")
func testSignInUpdatesState() async throws {
    let viewModel = WelcomeViewModel()
    
    // Given
    #expect(viewModel.uiState.isLoading == false)
    
    // When
    viewModel.onSignInTapped()
    
    // Then - El estado cambia temporalmente
    // Espera a que complete
    try? await Task.sleep(nanoseconds: 200_000_000)
    
    #expect(viewModel.effect == .navigateToSignIn)
}
```

## 🎯 Próximos Pasos / Mejoras

1. **Inyección de Dependencias**: Agregar un protocolo para casos de uso
2. **Error Handling**: Implementar un AlertManager reutilizable
3. **Analytics**: Agregar tracking de eventos
4. **Localization**: Mejorar el manejo de strings localizadas
5. **Loading States**: Estados de loading más granulares

## 📝 Ejemplo de Uso

```swift
// En tu app o navegador principal
WelcomeView(
    viewModel: WelcomeViewModel(),
    onSignIn: {
        // Navegar a pantalla de sign in
        router.navigate(to: .signIn)
    },
    onSignUp: {
        // Navegar a pantalla de sign up
        router.navigate(to: .signUp)
    }
)
```

## 🔧 Personalización

Para agregar nueva funcionalidad:

1. **Nuevo estado** → Agregar property a `WelcomeUIState`
2. **Nuevo efecto** → Agregar case a `WelcomeEffect`
3. **Nueva acción** → Agregar método público a `WelcomeViewModel`
4. **Nuevo elemento UI** → Modificar `_WelcomeContent`

---

Esta arquitectura es escalable y puede replicarse para otras pantallas de la app.
