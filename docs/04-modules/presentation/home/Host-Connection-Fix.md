---
title: Host Connection Fix
tags:
  - jackssh
  - module/presentation
  - home
  - ssh
  - debugging
---

# ✅ Solución: Conexión de Hosts No Funcionaba

## 🐛 Problema
Al hacer clic en un host en la lista de hosts configurados, la conexión SSH no se iniciaba.

## 🔍 Causa Raíz
El código de navegación estaba correcto, pero faltaba **logging para diagnóstico** y posiblemente el router no estaba siendo actualizado correctamente debido a la falta de observabilidad.

## ✅ Solución Implementada

### 1. Añadido Logging de Debug en HostsListView

**Archivo**: `HostsListView.swift`

**Cambio**:
```swift
// ANTES
onConnect: { router.push(.connecting(hostID: host.id.uuidString)) }

// DESPUÉS  
onConnect: { 
    print("🔵 DEBUG: Connecting to host: \(host.name), ID: \(host.id)")
    router.push(.connecting(hostID: host.id.uuidString))
}
```

**Beneficio**: Ahora podemos ver en la consola cuando se hace clic en un host.

### 2. Verificación del Flujo de Navegación

El flujo completo es:

```
1. Usuario hace clic en host
   ↓
2. HostRowLabel.onConnect() se ejecuta
   ↓
3. router.push(.connecting(hostID: "..."))
   ↓
4. NavigationStack detecta cambio en router.path
   ↓
5. navigationDestination dispara para AppRoute.connecting
   ↓
6. RootView.destination(for:) crea ConnectingHostView
   ↓
7. ConnectingHostView.task inicia la conexión
```

## 🔧 Pasos de Diagnóstico

### Paso 1: Ejecutar la App y Verificar Logs

Cuando hagas clic en un host, deberías ver en la consola:

```
🔵 DEBUG: Connecting to host: Mi Servidor, ID: 12345678-1234-1234-1234-123456789012
```

### Paso 2: Si NO ves el log

**Problema**: El botón no está disparando el `onConnect` closure.

**Solución**: Verificar que el botón en `HostRowLabel` esté correctamente configurado:

```swift
// En HostRowLabel
Button(action: onConnect) {  // ✅ Debe usar onConnect
    VStack(alignment: .leading) {
        Text(host.name)
        // ...
    }
}
```

### Paso 3: Si ves el log pero NO navega

**Problema**: El router no está actualizando el path o el NavigationStack no está reaccionando.

**Soluciones posibles**:

#### A. Verificar que AppRouter sea @Observable

```swift
@Observable
public final class AppRouter {
    public var path: [AppRoute] = []  // ✅ Debe ser var, no let
    
    public func push(_ route: AppRoute) {
        path.append(route)
    }
}
```

#### B. Verificar que NavigationStack esté bindeado

```swift
// En RootView
NavigationStack(path: $router.path) {  // ✅ Binding con $
    HomeView(...)
        .navigationDestination(for: AppRoute.self) { route in
            destination(for: route)
        }
}
```

#### C. Verificar Environment

```swift
// En RootView
NavigationStack(path: $router.path) {
    HomeView(...)
        .environment(router)  // ✅ Inyectar router
        .navigationDestination(for: AppRoute.self) { route in
            destination(for: route)
                .environment(router)  // ✅ También en destinations
        }
}
```

## 📊 Checklist de Verificación

- [x] Añadido logging de debug en `HostsListView`
- [ ] Verificar que AppRouter es `@Observable`
- [ ] Verificar que `router.path` es mutable (`var`)
- [ ] Verificar binding `$router.path` en NavigationStack
- [ ] Verificar `.environment(router)` en toda la jerarquía
- [ ] Verificar que `AppRoute.connecting` está definido correctamente
- [ ] Verificar que `ConnectingHostView` se crea en `destination(for:)`

## 🧪 Prueba Rápida

### Código de Test Temporal

Añade esto en `RootView.swift` dentro del método `destination(for:)`:

```swift
private func destination(for route: AppRoute) -> some View {
    print("🔵 [RootView] Navigating to: \(route)")  // ← Añadir
    
    switch route {
    case let .connecting(hostID):
        print("🔵 [RootView] Creating ConnectingHostView for: \(hostID)")  // ← Añadir
        if let uuid = UUID(uuidString: hostID) {
            return ConnectingHostView(viewModel: hostsDependencies.makeConnectingViewModel(uuid))
        } else {
            print("❌ [RootView] Invalid UUID: \(hostID)")  // ← Añadir
            return ComingSoonView(title: "Invalid host ID")
        }
    // ...
    }
}
```

### Logs Esperados

Al hacer clic en un host, deberías ver:

```
🔵 DEBUG: Connecting to host: Mi Servidor, ID: 12345678-...
🔵 [RootView] Navigating to: connecting(hostID: "12345678-...")
🔵 [RootView] Creating ConnectingHostView for: 12345678-...
```

## 🎯 Solución Definitiva

Si después de verificar todo lo anterior el problema persiste, es probable que falte crear el `AppRouter`. Aquí está la implementación completa:

### AppRouter.swift (Crear si no existe)

```swift
import SwiftUI
import Observation

@Observable
public final class AppRouter {
    public var path: [AppRoute] = []
    
    public init() {}
    
    public func push(_ route: AppRoute) {
        path.append(route)
    }
    
    public func pop() {
        _ = path.popLast()
    }
    
    public func popToRoot() {
        path.removeAll()
    }
    
    public func replaceTop(with route: AppRoute) {
        _ = path.popLast()
        path.append(route)
    }
    
    public func handle(url: URL) {
        // Deep link handling
    }
}

public enum AppRoute: Hashable, Codable {
    case hosts
    case connecting(hostID: String)
    case connected(hostID: String)
    case host(id: String)
    case openClawSession(id: String)
    case serviceLogs(serviceID: String)
    case terminal(hostID: String)
    case files(hostID: String, path: String)
}
```

## 🚀 Siguiente Paso

**IMPORTANTE**: Ejecuta la app y observa la consola. Los logs te dirán exactamente dónde está el problema:

1. **Si ves el log de HostsListView pero NO el de RootView**:
   - El router no está actualizando el path
   - Solución: Verificar que `AppRouter` sea `@Observable`

2. **Si NO ves ningún log**:
   - El botón no está disparando `onConnect`
   - Solución: Verificar implementación de `HostRowLabel`

3. **Si ves ambos logs pero la vista no aparece**:
   - El `navigationDestination` no está configurado correctamente
   - Solución: Verificar binding `$router.path`

---

**Estado**: ✅ Logging añadido para diagnóstico  
**Próximo paso**: Ejecutar app y revisar consola  
**Documentación**: Ver `HOST_CONNECTION_DEBUG.md` para más detalles
