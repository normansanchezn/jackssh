# DSButton - Componente de Botón del Design System

El `DSButton` es un componente de botón personalizado diseñado específicamente para aplicaciones SSH/OpenClaw con una estética técnica y profesional.

## 🎨 Características

- ✅ **3 Estilos Visuales**: Filled, Outline, y Text
- ✅ **3 Tamaños**: Small, Medium, Large
- ✅ **Estados**: Normal, Loading, Disabled
- ✅ **Iconos Opcionales**: Soporte para SF Symbols
- ✅ **Ancho Completo**: Opción para ocupar todo el ancho disponible
- ✅ **Tematización Automática**: Se adapta al tema de la app

## 📖 Uso Básico

### Estilo Filled (Acción Principal)
```swift
DSButton(
    "Sign In",
    icon: "arrow.right.circle.fill",
    style: .filled,
    fullWidth: true
) {
    // Acción de login
}
```

### Estilo Outline (Acción Secundaria)
```swift
DSButton(
    "Create Account",
    icon: "person.badge.plus",
    style: .outline,
    fullWidth: true
) {
    // Acción de registro
}
```

### Estilo Text (Acción Terciaria)
```swift
DSButton(
    "Forgot Password?",
    style: .text
) {
    // Acción de recuperación
}
```

## 🔧 Parámetros

| Parámetro | Tipo | Default | Descripción |
|-----------|------|---------|-------------|
| `title` | `String` | - | Texto del botón (requerido) |
| `icon` | `String?` | `nil` | Nombre del SF Symbol |
| `style` | `DSButtonStyle` | `.filled` | Estilo visual del botón |
| `size` | `DSButtonSize` | `.medium` | Tamaño del botón |
| `fullWidth` | `Bool` | `false` | Si ocupa todo el ancho |
| `isLoading` | `Bool` | `false` | Muestra indicador de carga |
| `action` | `() -> Void` | - | Acción al presionar (requerido) |

## 🎯 Estilos Disponibles

### `.filled`
- **Uso**: Acciones principales (Sign In, Connect, Save)
- **Visual**: Fondo color primario, texto blanco
- **Jerarquía**: Mayor énfasis visual

### `.outline`
- **Uso**: Acciones secundarias (Create Account, Settings, Configure)
- **Visual**: Borde color primario, texto color primario, fondo transparente
- **Jerarquía**: Énfasis medio

### `.text`
- **Uso**: Acciones terciarias (Cancel, Forgot Password, Learn More)
- **Visual**: Solo texto, sin borde ni fondo
- **Jerarquía**: Menor énfasis visual

## 📏 Tamaños

### `.small`
- Padding: 12px horizontal, 8px vertical
- Font: Footnote, Medium
- Ideal para: Botones de acción en toolbars, chips

### `.medium` (default)
- Padding: 16px horizontal, 12px vertical
- Font: Body, Semibold
- Ideal para: Botones principales de formularios

### `.large`
- Padding: 24px horizontal, 16px vertical
- Font: Title3, Bold
- Ideal para: CTAs principales, pantallas de bienvenida

## 🔄 Estados

### Loading
```swift
DSButton(
    "Connecting...",
    style: .filled,
    isLoading: true
) {
    // No se ejecuta mientras isLoading = true
}
```

### Disabled
```swift
DSButton(
    "Submit",
    style: .filled
) {
    // Acción
}
.disabled(true)  // Botón no interactivo
```

## 💡 Ejemplos de Uso

### Formulario de Login
```swift
VStack(spacing: DSSpacing.md) {
    // Botón principal
    DSButton(
        "Sign In",
        icon: "arrow.right.circle.fill",
        style: .filled,
        fullWidth: true,
        isLoading: viewModel.isLoading
    ) {
        Task { await viewModel.login() }
    }
    
    // Botón secundario
    DSButton(
        "Create Account",
        icon: "person.badge.plus",
        style: .outline,
        fullWidth: true
    ) {
        showSignUp()
    }
    
    // Acción terciaria
    DSButton(
        "Forgot Password?",
        style: .text
    ) {
        showPasswordRecovery()
    }
}
```

### Acciones de Terminal SSH
```swift
HStack(spacing: DSSpacing.md) {
    // Conectar
    DSButton(
        "Connect",
        icon: "terminal",
        style: .filled
    ) {
        connectToHost()
    }
    
    // Configuración
    DSButton(
        "Settings",
        icon: "gear",
        style: .outline
    ) {
        showSettings()
    }
    
    // Desconectar
    DSButton(
        "Disconnect",
        icon: "xmark",
        style: .text
    ) {
        disconnect()
    }
}
```

### Lista de Hosts
```swift
ForEach(hosts) { host in
    HStack {
        VStack(alignment: .leading) {
            Text(host.name)
            Text(host.address)
                .font(.caption)
        }
        
        Spacer()
        
        DSButton(
            "Connect",
            icon: "play.fill",
            style: .filled,
            size: .small
        ) {
            connect(to: host)
        }
    }
}
```

## 🎨 Personalización de Colores

Los colores se toman automáticamente del tema de la aplicación:

- **Filled**: Usa `theme.colors.primary600` para el fondo
- **Outline**: Usa `theme.colors.primary600` para borde y texto
- **Text**: Usa `theme.colors.textPrimary` para el texto
- **Disabled**: Usa `theme.colors.neutral300` con opacidad reducida

## ⚡ Mejores Prácticas

1. **Jerarquía Visual**: Usa solo un botón `.filled` por pantalla para la acción principal
2. **Consistencia**: Mantén el mismo tamaño para botones del mismo contexto
3. **Estados de Carga**: Siempre usa `isLoading` para operaciones asíncronas
4. **Iconos**: Usa iconos que refuercen el significado del botón
5. **Ancho Completo**: Úsalo en formularios para mejor UX en móviles

## 🚫 Anti-patrones

❌ **NO hagas esto:**
```swift
// Múltiples botones filled compitiendo por atención
DSButton("Save", style: .filled) {}
DSButton("Cancel", style: .filled) {}
DSButton("Delete", style: .filled) {}
```

✅ **HAZ esto:**
```swift
DSButton("Save", style: .filled) {}
DSButton("Cancel", style: .outline) {}
DSButton("Delete", style: .text) {}
```

## 🔗 Componentes Relacionados

- `Background`: Fondos con efectos de terminal
- `BackgroundElevated`: Contenedores elevados
- `TerminalBackground`: Fondos específicos para terminales
