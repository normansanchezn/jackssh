# 🔧 Diagnóstico y Solución: Conexión de Hosts

## 🐛 Problema Reportado
Al hacer clic en un host en la lista de hosts configurados, la conexión no se inicia.

## 🔍 Análisis del Código

### Flujo de Navegación Actual

1. **HostsListView** → Usuario hace clic en un host
2. **HostRowLabel** → Dispara `onConnect` closure
3. **Router** → Llama a `router.push(.connecting(hostID: host.id.uuidString))`
4. **RootView** → Debería navegar a `ConnectingHostView`
5. **ConnectingHostView** → Inicia la conexión SSH

### Código Relevante

#### HostsListView.swift (Líneas 88-93)
```swift
HostRowLabel(
    host: host,
    onConnect: { router.push(.connecting(hostID: host.id.uuidString)) },
    onEdit: { editorTarget = .edit(host) },
    onDelete: { pendingDeletion = host }
)
```

#### HostRowLabel (Líneas 120-170)
```swift
private struct HostRowLabel: View {
    let onConnect: () -> Void
    
    var body: some View {
        // Botón principal (texto del host)
        Button(action: onConnect) {
            VStack(alignment: .leading) {
                Text(host.name)
                // ...
            }
        }
        
        // Botón de flecha
        Button(action: onConnect) {
            Image(systemName: "arrow.right")
                .frame(width: 32, height: 32)
                .background(theme.colors.primary600, in: Circle())
        }
    }
}
```

#### RootView.swift (Líneas 49-56)
```swift
case let .connecting(hostID):
    if let uuid = UUID(uuidString: hostID) {
        ConnectingHostView(viewModel: hostsDependencies.makeConnectingViewModel(uuid))
    } else {
        ComingSoonView(title: "Invalid host ID")
    }
```

## 🎯 Posibles Causas

### 1. **Router No Inyectado Correctamente**
El router se obtiene del Environment en `HostsListView`:
```swift
@Environment(AppRouter.self) private var router
```

**Verificación**: Comprobar que el router esté en el environment cuando se crea `HostsListView`.

### 2. **NavigationStack No Configurado**
En `RootView.swift`:
```swift
NavigationStack(path: $router.path) {
    HomeView(...)
        .navigationDestination(for: AppRoute.self) { route in
            destination(for: route)
        }
}
```

**Verificación**: El `navigationDestination` debe estar en el correcto nivel de la jerarquía.

### 3. **AppRouter No Observable**
El router debe ser `@Observable` para que SwiftUI reaccione a cambios en `path`.

## ✅ Soluciones

### Solución 1: Verificar Inyección del Router

Asegúrate de que el router se esté pasando correctamente en `RootView`:

```swift
// En RootView.swift
NavigationStack(path: $router.path) {
    HomeView(viewModel: homeViewModel, router: router) {
        await authViewModel.logout()
    }
    .environment(router) // ✅ Inyectar en el root
    .navigationDestination(for: AppRoute.self) { route in
        destination(for: route)
            .environment(router) // ✅ Inyectar en cada destination
    }
}
```

### Solución 2: Agregar Logging para Debug

Añade print statements para rastrear el flujo:

```swift
// En HostsListView.swift
HostRowLabel(
    host: host,
    onConnect: { 
        print("🔵 [HostsList] Connecting to: \(host.name)")
        print("🔵 [HostsList] Host ID: \(host.id)")
        print("🔵 [HostsList] Router path before: \(router.path)")
        router.push(.connecting(hostID: host.id.uuidString))
        print("🔵 [HostsList] Router path after: \(router.path)")
    },
    onEdit: { editorTarget = .edit(host) },
    onDelete: { pendingDeletion = host }
)
```

```swift
// En RootView.swift destination method
private func destination(for route: AppRoute) -> some View {
    print("🔵 [RootView] Navigating to route: \(route)")
    
    switch route {
    case let .connecting(hostID):
        print("🔵 [RootView] Creating ConnectingHostView for: \(hostID)")
        if let uuid = UUID(uuidString: hostID) {
            return AnyView(ConnectingHostView(
                viewModel: hostsDependencies.makeConnectingViewModel(uuid)
            ))
        } else {
            print("❌ [RootView] Invalid UUID: \(hostID)")
            return AnyView(ComingSoonView(title: "Invalid host ID"))
        }
    // ...
    }
}
```

### Solución 3: Crear AppRouter si no existe

Si no existe un archivo `AppRouter.swift`, créalo:

```swift
import SwiftUI
import Observation

@Observable
public final class AppRouter {
    public var path: [AppRoute] = []
    
    public init() {}
    
    public func push(_ route: AppRoute) {
        print("🔵 [Router] Pushing route: \(route)")
        path.append(route)
    }
    
    public func pop() {
        print("🔵 [Router] Popping route")
        _ = path.popLast()
    }
    
    public func popToRoot() {
        print("🔵 [Router] Popping to root")
        path.removeAll()
    }
    
    public func replaceTop(with route: AppRoute) {
        print("🔵 [Router] Replacing top with: \(route)")
        _ = path.popLast()
        path.append(route)
    }
    
    public func handle(url: URL) {
        print("🔵 [Router] Handling URL: \(url)")
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

### Solución 4: Verificar que ConnectingHostViewModel se crea correctamente

En `HostsDependencies`:

```swift
makeConnectingViewModel: { hostID in
    print("🔵 [Dependencies] Creating ConnectingHostViewModel for: \(hostID)")
    let vm = ConnectingHostViewModel(
        hostID: hostID,
        loadHost: loadHosts,
        sshConnector: sshConnector
    )
    print("🔵 [Dependencies] ViewModel created: \(vm)")
    return vm
}
```

## 🧪 Testing

### Test Manual

1. Ejecuta la app
2. Ve a la lista de hosts
3. Haz clic en un host
4. Observa la consola para los mensajes de debug
5. Verifica que:
   - El `onConnect` closure se ejecute
   - El router reciba el push
   - El path del router se actualice
   - La navegación ocurra

### Checklist de Verificación

- [ ] El router está en el Environment de `HostsListView`
- [ ] El router es `@Observable`
- [ ] El `path` del router es un array mutable
- [ ] El `NavigationStack` está bindeado a `router.path`
- [ ] El `.navigationDestination` está configurado
- [ ] El `AppRoute.connecting` case existe
- [ ] El `ConnectingHostView` se crea correctamente

## 📝 Implementación Inmediata

Para una solución rápida, añade logging temporal:

```swift
// En HostsListView.swift, línea 90
onConnect: { 
    print("🔵 DEBUG: Tapped host: \(host.name)")
    print("🔵 DEBUG: Router exists: \(router)")
    print("🔵 DEBUG: Current path: \(router.path)")
    router.push(.connecting(hostID: host.id.uuidString))
    print("🔵 DEBUG: New path: \(router.path)")
}
```

Esto te dirá exactamente dónde falla el flujo.

## 🎯 Solución Final Recomendada

Si todo lo anterior está correcto, el problema puede ser que el router no se está actualizando correctamente. Asegúrate de que:

1. `AppRouter` sea una clase `@Observable`
2. El `path` sea una propiedad pública y mutable
3. El `NavigationStack` esté bindeado con `$router.path`
4. El environment esté inyectado en todos los niveles necesarios

---

**Estado**: Pendiente de diagnóstico con logs  
**Prioridad**: Alta  
**Impacto**: Funcionalidad core bloqueada
