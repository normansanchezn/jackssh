# JackSsh --- Private Personal Ops Console

## 1. Visión

**JackSsh** es una aplicación iOS privada que unifica en una
sola experiencia el acceso y la operación de la infraestructura personal
de Norman.

Actualmente el flujo remoto depende de varias aplicaciones
independientes:

-   Tailscale para acceder a la red privada.
-   Termius para conexiones SSH.
-   ntfy para recibir notificaciones.
-   Navegador o túneles SSH para abrir dashboards como OpenClaw.

La propuesta es reemplazar la experiencia fragmentada por una única
aplicación iOS nativa que funcione como **consola privada de
operaciones personales**.

La intención del usuario deja de ser:

> "Conectarme a Tailscale, abrir Termius, revisar ntfy y luego encontrar
> el dashboard."

Y pasa a ser:

> "Abrir JackSsh y administrar mi infraestructura."

------------------------------------------------------------------------

## 2. Objetivo principal

Construir una aplicación iOS nativa, privada y escalable que
permita:

1.  Consultar el estado de la infraestructura.
2.  Acceder al dashboard de OpenClaw dentro de la app.
3.  Ejecutar sesiones SSH.
4.  Explorar archivos mediante SFTP.
5.  Consultar logs y servicios.
6.  Recibir notificaciones push nativas.
7.  Ejecutar acciones remotas seguras.
8.  Administrar varios hosts y servicios.
9.  Reducir la dependencia de aplicaciones externas para la operación
    diaria.

La aplicación debe estar pensada inicialmente para uso personal y
distribución privada mediante private Xcode, TestFlight, or Ad Hoc distribution.

------------------------------------------------------------------------

## 3. Problema actual

### Flujo actual

``` text
Salir de casa / trabajar remotamente
              ↓
Abrir Tailscale
              ↓
Comprobar conexión
              ↓
Abrir Termius
              ↓
Conectar por SSH
              ↓
Abrir ntfy para revisar alertas
              ↓
Crear túnel o buscar dirección
              ↓
Abrir OpenClaw
```

### Problemas

-   Demasiado cambio de contexto.
-   Tres o más aplicaciones para una sola intención.
-   Información fragmentada.
-   Las notificaciones no conocen el recurso que deben abrir.
-   Los servicios no tienen una vista de salud centralizada.
-   Las acciones frecuentes requieren comandos manuales.
-   La experiencia depende de recordar hosts, puertos y rutas.
-   No existe un punto central de diagnóstico.

------------------------------------------------------------------------

## 4. Solución propuesta

``` text
JackSsh
│
├── Infrastructure
│   ├── VPN / Private Network
│   ├── VPS
│   ├── Mac mini
│   └── Connectivity diagnostics
│
├── OpenClaw
│   ├── Dashboard
│   ├── Sessions
│   └── Task results
│
├── Terminal
│   └── SSH
│
├── Files
│   └── SFTP
│
├── Services
│   ├── Docker
│   ├── OpenClaw
│   ├── Ollama bridge
│   └── Custom services
│
├── Logs
│   ├── Container logs
│   ├── systemd logs
│   └── Application logs
│
├── Notifications
│   ├── OpenClaw events
│   ├── VPS alerts
│   ├── Ollama events
│   └── Security events
│
└── Settings
    ├── Hosts
    ├── SSH identities
    ├── Dashboards
    ├── Services
    └── Security
```

------------------------------------------------------------------------

## 5. Principio de diseño

La app no debe ser un "Termius personalizado".

Debe modelar **intenciones**, no herramientas.

Ejemplos:

### Antes

``` text
SSH
→ docker ps
→ docker logs openclaw
→ identificar error
```

### JackSsh

``` text
OpenClaw
→ Status: Degraded
→ View logs
```

### Antes

``` text
Abrir ntfy
→ leer alerta
→ recordar servidor
→ abrir Termius
→ conectar
```

### JackSsh

``` text
OpenClaw necesita atención

[ Ver detalles ] [ Abrir logs ]
```

La terminal sigue existiendo, pero debe ser una herramienta avanzada y
no la interfaz principal para operaciones conocidas.

------------------------------------------------------------------------

## 6. Experiencia principal

### Inicio

Al abrir la aplicación:

``` text
┌─────────────────────────────────┐
│ JackSsh                     │
│ Private Ops                     │
│                                 │
│ Private Network      ● Connected│
│ VPS Principal        ● Online   │
│ OpenClaw             ● Healthy  │
│ Ollama               ● Online   │
│                                 │
│ [ Open OpenClaw ]                │
│                                 │
│ Quick Actions                   │
│ [ Terminal ] [ Files ]          │
│ [ Logs ]     [ Services ]       │
│                                 │
│ Recent Activity                 │
│ ✓ innovation-n-trends completed │
│ ! Ollama inference cancelled    │
└─────────────────────────────────┘
```

### Flujo "Abrir OpenClaw"

``` text
Tap Open OpenClaw
        ↓
Validar red privada
        ↓
¿Host accesible?
   ├── No → diagnóstico
   └── Sí
        ↓
Validar OpenClaw
        ↓
Abrir dashboard en WKWebView
```

El dashboard debe abrirse dentro de JackSsh.

No debe ser necesario copiar URLs, recordar puertos ni abrir un
navegador externo.

------------------------------------------------------------------------

## 7. Red privada y Tailscale

### MVP recomendado

Durante la primera versión, JackSsh **no reemplazará el motor VPN de
Tailscale**.

Tailscale continuará funcionando como VPN del sistema iOS.

JackSsh deberá:

-   Detectar disponibilidad de la red privada.
-   Validar rutas hacia los hosts configurados.
-   Detectar si el VPS es accesible.
-   Mostrar un estado comprensible.
-   Guiar al usuario si la VPN no está disponible.
-   Reintentar automáticamente cuando la conectividad cambie.

### Objetivo UX

Aunque Tailscale continúe instalado, el usuario no debería necesitar
abrirlo durante el uso normal.

``` text
JackSsh
    ↓
Private network unavailable
    ↓
[ Connect / Open VPN ]
    ↓
Connection detected
    ↓
Continue automatically
```

### Futuro

Evaluar una integración de red más profunda únicamente después del MVP.

No implementar un `VpnService` propio ni recrear Tailscale/WireGuard
durante la primera etapa.

------------------------------------------------------------------------

## 8. Hosts

La aplicación debe soportar múltiples hosts.

Ejemplo inicial:

``` text
VPS Principal
Mac mini
```

### Modelo conceptual

``` text
Host
├── id
├── name
├── hostname
├── privateAddress
├── sshPort
├── sshUser
├── authenticationIdentity
├── healthChecks
└── tags
```

Ejemplo:

``` yaml
name: VPS Principal
hostname: vps.tailnet.internal
sshPort: 22022
sshUser: root
tags:
  - vps
  - openclaw
  - docker
```

Las credenciales sensibles nunca deben almacenarse como texto plano.

------------------------------------------------------------------------

## 9. OpenClaw

OpenClaw será un recurso de primera clase dentro de JackSsh.

### Funciones iniciales

-   Mostrar estado.
-   Abrir dashboard integrado.
-   Detectar si el contenedor está activo.
-   Consultar salud del servicio.
-   Abrir logs.
-   Mostrar actividad reciente.
-   Recibir eventos de tareas.
-   Navegar desde una notificación al recurso relacionado.

### Vista conceptual

``` text
OpenClaw

Status
● Healthy

Host
VPS Principal

Container
openclaw

Recent activity
✓ innovation-n-trends validation completed
! Inference cancelled
✓ web-expert finished task

[ Open Dashboard ]
[ View Logs ]
[ Open Terminal ]
```

### WKWebView

La aplicación utilizará un WKWebView para cargar el dashboard privado de
OpenClaw.

La URL se configura una sola vez.

Ejemplo conceptual:

``` yaml
name: OpenClaw
host: VPS Principal
port: 18789
path: /
type: dashboard
```

La app construirá y resolverá internamente el destino.

------------------------------------------------------------------------

## 10. Terminal SSH

JackSsh incluirá una terminal SSH integrada.

### Funciones

-   Conexión SSH.
-   Autenticación mediante llave.
-   Terminal interactiva.
-   Reconexión.
-   Historial local opcional.
-   Hosts favoritos.
-   Acciones para copiar salida.
-   Abrir una terminal desde el contexto de un servicio.

Ejemplo:

``` text
OpenClaw
→ Open Terminal
```

La terminal ya conoce:

``` text
Host: VPS Principal
User: root
Port: 22022
```

El usuario no debe volver a introducir esa información.

### Autenticación

Prioridad:

1.  Llave SSH.
2.  Keyboard interactive cuando sea necesario.
3.  Password únicamente como compatibilidad.

No almacenar contraseñas SSH en texto plano.

------------------------------------------------------------------------

## 11. SFTP y archivos

La app incluirá un explorador remoto.

### Funciones MVP

-   Navegar directorios.
-   Ver archivos.
-   Descargar archivos al dispositivo.
-   Subir archivos.
-   Crear carpetas.
-   Renombrar.
-   Eliminar con confirmación.
-   Copiar ruta.
-   Abrir archivos de texto.
-   Compartir archivos descargados.

### Accesos rápidos iniciales

``` text
/workspace
/root/openclaw
/home/node/.openclaw
```

Los accesos rápidos deben ser configurables por host.

### Contexto

Desde OpenClaw:

``` text
OpenClaw
→ Files
```

Puede abrir directamente:

``` text
/root/openclaw
```

Desde un proyecto:

``` text
innovation-n-trends
→ Files
```

Puede abrir:

``` text
/workspace/innovation-n-trends
```

------------------------------------------------------------------------

## 12. Servicios

JackSsh debe abstraer servicios conocidos.

### Ejemplos iniciales

``` text
OpenClaw
Ollama Bridge
Docker
```

### Estado

``` text
● Healthy
● Running
● Degraded
● Stopped
● Unknown
```

### Acciones

Dependiendo del servicio:

``` text
Start
Stop
Restart
View logs
Open terminal
```

Las acciones destructivas o de impacto deben requerir confirmación.

Ejemplo:

``` text
Restart OpenClaw?

Active tasks may be interrupted.

[ Cancel ] [ Restart ]
```

------------------------------------------------------------------------

## 13. Logs

La aplicación debe ofrecer una experiencia superior a ejecutar
manualmente comandos SSH.

### Fuentes

-   Docker logs.
-   journalctl/systemd.
-   Archivos de log.
-   Endpoints de diagnóstico.

### Funciones

-   Streaming.
-   Pause.
-   Resume.
-   Search.
-   Filter.
-   Copy.
-   Share.
-   Follow.
-   Limpiar vista local.

### Ejemplo

``` text
OpenClaw Logs

[ All ] [ Error ] [ Warning ]

20:32:01 Session started
20:32:14 web-expert delegated
20:35:49 Inference cancelled
20:35:50 Repository state preserved

[ Follow: ON ]
```

La app no debe borrar logs del servidor cuando el usuario limpia la
vista.

------------------------------------------------------------------------

## 14. Notificaciones push nativas

JackSsh reemplazará gradualmente ntfy mediante notificaciones
iOS propias.

### Arquitectura

``` text
OpenClaw / VPS / Scripts
            │
            ▼
JackSsh Notification Gateway
            │
            ▼
Apple Push Notification service
            │
            ▼
JackSsh iOS
            │
            ▼
Native iOS Notification
```

### Notification Gateway

Servicio pequeño desplegado en el VPS.

Responsabilidades:

-   Recibir eventos internos.
-   Validar autenticación.
-   Normalizar eventos.
-   Enviar mensajes mediante APNs.
-   Evitar exponer secretos de Firebase a clientes internos.
-   Mantener logs mínimos de entrega.

Ejemplo:

``` http
POST /v1/events
```

Payload conceptual:

``` json
{
  "type": "openclaw.task.completed",
  "title": "Jack finished",
  "message": "Validation completed successfully",
  "hostId": "vps-main",
  "resourceId": "openclaw",
  "project": "innovation-n-trends",
  "sessionId": "session-123",
  "severity": "success"
}
```

------------------------------------------------------------------------

## 15. Modelo de eventos

Los eventos deben ser estructurados.

No enviar únicamente título y mensaje.

### Ejemplo

``` json
{
  "event": "openclaw.task.completed",
  "resource": "openclaw",
  "project": "innovation-n-trends",
  "sessionId": "abc123",
  "destination": {
    "type": "openclaw_session",
    "id": "abc123"
  },
  "severity": "success"
}
```

### Tipos iniciales

``` text
openclaw.task.started
openclaw.task.completed
openclaw.task.failed
openclaw.inference.cancelled
openclaw.approval.required

vps.online
vps.offline
vps.disk.warning
vps.memory.warning

service.started
service.stopped
service.failed

ollama.online
ollama.offline
ollama.inference.cancelled

security.ssh.failed
security.authentication.failed
```

------------------------------------------------------------------------

## 16. Deep links internos

Cada notificación debe saber qué abrir.

Ejemplo:

``` text
OpenClaw finished innovation-n-trends

[ View result ]
```

Tap:

``` text
jackssh://openclaw/session/abc123
```

La app:

``` text
Receive deep link
      ↓
Resolve resource
      ↓
Check private network
      ↓
Check host
      ↓
Navigate to OpenClaw
      ↓
Open session abc123
```

Otros ejemplos:

``` text
jackssh://services/openclaw/logs
jackssh://hosts/vps-main
jackssh://terminal/vps-main
jackssh://files/vps-main/workspace
```

Los identificadores y rutas deben validarse antes de ejecutar navegación
o acciones.

------------------------------------------------------------------------

## 17. Canales de notificación iOS

### OpenClaw Tasks

Eventos de tareas y agentes.

``` text
Task completed
Task failed
Inference cancelled
Approval required
```

### Infrastructure

``` text
VPS offline
Disk warning
Memory warning
Connectivity restored
```

### Services

``` text
OpenClaw stopped
Ollama bridge failed
Service restarted
```

### Security

``` text
Authentication failure
SSH failure threshold reached
Unknown access event
```

El usuario podrá configurar sonido e importancia mediante los canales
nativos de iOS.

------------------------------------------------------------------------

## 18. Notificaciones interactivas

En fases posteriores:

``` text
OpenClaw needs approval

Continue with deployment?

[ Approve ] [ Reject ] [ Details ]
```

### Seguridad

Las acciones sensibles desde una notificación deben:

1.  Abrir JackSsh.
2.  Validar sesión.
3.  Solicitar biometría si aplica.
4.  Mostrar el contexto.
5.  Ejecutar la acción.

No ejecutar acciones críticas directamente desde un broadcast sin
validación.

------------------------------------------------------------------------

## 19. Seguridad

JackSsh administra infraestructura sensible.

La seguridad es un requisito central.

### Principios

-   Zero plaintext secrets.
-   Least privilege.
-   Biometric authentication.
-   Explicit destructive actions.
-   Private network first.
-   No public management endpoints.
-   Auditable remote actions.

### iOS Keystore

Utilizar iOS Keystore para proteger:

-   Material criptográfico local.
-   Tokens.
-   Secretos cifrados.
-   Referencias de identidades SSH.

### Biométricos

Solicitar autenticación para:

-   Abrir la app, si está habilitado.
-   Mostrar secretos.
-   Ejecutar acciones destructivas.
-   Aprobar operaciones remotas.
-   Importar o eliminar identidades SSH.

### SSH

Preferir llaves SSH.

``` text
root
+
id_ed25519
```

La llave privada debe almacenarse cifrada y desbloquearse mediante una
clave protegida por iOS Keystore.

### Network

Los dashboards y servicios administrativos deben continuar privados.

No exponer OpenClaw públicamente únicamente para facilitar la app.

------------------------------------------------------------------------

## 20. Arquitectura iOS propuesta

### Stack

-   Swift.
-   SwiftUI.
-   Apple Human Interface Guidelines.
-   Coroutines.
-   Flow.
-   Navigation Compose.
-   Hilt o Koin.
-   SwiftData.
-   UserDefaults / AppStorage.
-   WorkManager.
-   Apple Push Notification service.
-   iOS Keystore.
-   LocalAuthentication.
-   WKWebView.
-   Cliente SSH/SFTP compatible con iOS.

### Arquitectura

``` text
app
│
├── core
│   ├── common
│   ├── network
│   ├── security
│   ├── ssh
│   ├── notifications
│   └── design-system
│
├── domain
│   ├── model
│   ├── repository
│   └── usecase
│
├── data
│   ├── local
│   ├── remote
│   ├── ssh
│   └── repository
│
└── feature
    ├── home
    ├── hosts
    ├── openclaw
    ├── terminal
    ├── files
    ├── services
    ├── logs
    ├── notifications
    └── settings
```

### Estado de UI

MVI o unidirectional data flow.

Ejemplo:

``` text
UI Event
   ↓
ViewModel
   ↓
Use Case
   ↓
Repository
   ↓
StateFlow
   ↓
Compose UI
```

------------------------------------------------------------------------

## 21. Modelo de dominio inicial

``` text
Host
Service
Dashboard
SshIdentity
RemotePath
HealthCheck
RemoteAction
InfrastructureEvent
NotificationDestination
```

### Host

Representa una máquina.

### Service

Representa un servicio conocido dentro de un host.

### Dashboard

Representa una interfaz web privada.

### SshIdentity

Representa una identidad de autenticación.

### HealthCheck

Define cómo comprobar el estado de un recurso.

### RemoteAction

Representa una acción remota conocida y controlada.

### InfrastructureEvent

Evento producido por la infraestructura.

### NotificationDestination

Define el destino interno al tocar una notificación.

------------------------------------------------------------------------

## 22. Health checks

La app debe poder comprobar recursos.

### Tipos

``` text
TCP
HTTP
HTTPS
SSH
Docker
systemd
Custom command
```

Ejemplo OpenClaw:

``` yaml
type: HTTP
host: VPS Principal
port: 18789
path: /
```

Ejemplo SSH:

``` yaml
type: TCP
port: 22022
```

### Resultado

``` text
Healthy
Degraded
Offline
Unknown
```

Cada resultado debe incluir:

``` text
status
checkedAt
latency
message
```

------------------------------------------------------------------------

## 23. Backend mínimo

JackSsh no requiere inicialmente un backend complejo.

### VPS

Agregar:

``` text
jack-remote-gateway
```

Responsabilidades iniciales:

``` text
POST /v1/events
GET  /health
```

Posteriormente:

``` text
Device registration
Notification preferences
Event history
Remote action authorization
```

### Recomendación

El gateway puede desarrollarse en Ktor para mantener una arquitectura
Swift end-to-end, o en Python/Node.js si se prioriza la velocidad del
MVP.

La decisión debe tomarse por simplicidad operativa, no por añadir
tecnología innecesaria.

------------------------------------------------------------------------

## 24. Persistencia local

SwiftData:

``` text
Hosts
Services
Dashboards
Remote paths
Event history
Recent destinations
```

UserDefaults / AppStorage:

``` text
Theme
Biometric preference
Default host
Notification preferences
UI preferences
```

iOS Keystore + encrypted storage:

``` text
Tokens
SSH secrets
Sensitive configuration
```

------------------------------------------------------------------------

## 25. MVP

### Fase 1 --- Foundation

-   Proyecto iOS.
-   Arquitectura modular.
-   Design system.
-   Navegación.
-   SwiftData.
-   UserDefaults / AppStorage.
-   Security module.
-   Host configuration.

### Fase 2 --- Infrastructure Home

-   Dashboard principal.
-   Hosts.
-   Connectivity checks.
-   Health checks.
-   Estado de VPS.
-   Estado de OpenClaw.
-   Estado de Ollama.

### Fase 3 --- OpenClaw

-   Recurso OpenClaw.
-   Dashboard WKWebView.
-   Connectivity validation.
-   Error states.
-   Open logs.
-   Open terminal.

### Fase 4 --- SSH

-   SSH identities.
-   Key authentication.
-   Interactive terminal.
-   Host context.
-   Reconnect.

### Fase 5 --- Files

-   SFTP.
-   Navigation.
-   Text preview.
-   Upload.
-   Download.
-   Quick paths.

### Fase 6 --- Services and Logs

-   Docker service state.
-   systemd service state.
-   Streaming logs.
-   Restart actions.
-   Confirmations.

### Fase 7 --- Push Notifications

-   Firebase project.
-   APNs iOS.
-   Notification Gateway.
-   Event schema.
-   iOS channels.
-   Deep links.

### Fase 8 --- Hardening

-   Biometrics.
-   Keystore review.
-   Network security configuration.
-   Input validation.
-   Action audit.
-   Failure recovery.
-   Tests.

------------------------------------------------------------------------

## 26. Fuera del MVP

No implementar inicialmente:

-   VPN propia.
-   Reimplementación de Tailscale.
-   WireGuard control plane.
-   Editor de código completo.
-   Cliente Git completo.
-   Kubernetes dashboard.
-   Multi-user SaaS.
-   App Store.
-   Sincronización cloud de secretos.
-   IA embebida adicional.
-   Ejecución arbitraria automática desde notificaciones.

Estas funciones pueden evaluarse después de validar el uso diario.

------------------------------------------------------------------------

## 27. Testing

### Unit tests

-   Use cases.
-   Health check resolution.
-   Event mapping.
-   Deep link parsing.
-   Notification routing.
-   Host validation.
-   Service state mapping.

### Integration tests

-   SwiftData.
-   UserDefaults / AppStorage.
-   Gateway event flow.
-   SSH configuration.
-   APNs token registration.

### UI tests

-   Home states.
-   Offline host.
-   OpenClaw unavailable.
-   Deep link navigation.
-   Confirmation dialogs.

### Manual real-environment tests

Validar físicamente:

1.  Wi-Fi de casa.
2.  Datos móviles.
3.  VPN disponible.
4.  VPN no disponible.
5.  VPS online.
6.  VPS offline.
7.  OpenClaw stopped.
8.  SSH rejected.
9.  APNs con app abierta.
10. APNs con app en background.
11. APNs con app cerrada.
12. Reinicio del dispositivo.
13. iOS Doze.
14. Biometric success.
15. Biometric cancellation.

Las pruebas deben ejecutar operaciones reales contra un entorno
controlado. No considerar mocks como validación final de
infraestructura.

------------------------------------------------------------------------

## 28. Criterios de éxito del MVP

El MVP es exitoso si Norman puede salir de casa y realizar este flujo:

``` text
Recibir notificación de OpenClaw
              ↓
Tap notification
              ↓
Abrir JackSsh
              ↓
Autenticación biométrica
              ↓
Validar red privada
              ↓
Abrir resultado de OpenClaw
```

Y también:

``` text
Abrir JackSsh
       ↓
Ver infraestructura
       ↓
OpenClaw: Healthy
       ↓
Open OpenClaw
```

Sin abrir manualmente:

``` text
Termius
ntfy
Browser
```

Tailscale puede continuar operando como infraestructura VPN del sistema
durante el MVP.

------------------------------------------------------------------------

## 29. Evolución futura

### Phase 2

-   Widgets iOS.
-   Control Center control or App Shortcut.
-   watchOS alerts.
-   iOS shortcuts.
-   Pinned OpenClaw sessions.
-   Rich event timeline.
-   Safer remote actions.
-   Multiple VPS profiles.

### Phase 3

-   Mac mini management.
-   Wake-on-LAN where applicable.
-   Unified OpenClaw session viewer.
-   Agent status.
-   Ollama model state.
-   Model load/unload actions.
-   Resource usage charts.

### Phase 4

Evaluar si tiene sentido una integración de red más profunda.

Únicamente entonces estudiar:

-   VpnService.
-   WireGuard integration.
-   Tailscale-compatible approaches.
-   Embedded private networking.

------------------------------------------------------------------------

## 30. Resumen ejecutivo

JackSsh será una aplicación iOS privada que centraliza la
operación remota de la infraestructura personal de Norman.

La aplicación reemplazará progresivamente la experiencia fragmentada de
Tailscale, Termius, ntfy y navegador por una consola contextual.

Tailscale continuará inicialmente como infraestructura VPN del sistema.

JackSsh absorberá:

-   Visualización de infraestructura.
-   OpenClaw integrado.
-   SSH.
-   SFTP.
-   Logs.
-   Servicios.
-   Notificaciones push nativas.
-   Deep links.
-   Acciones remotas seguras.

La arquitectura priorizará seguridad, contexto y simplicidad operativa.

El objetivo final no es crear otra herramienta de administración de
servidores.

El objetivo es crear una interfaz privada sobre la infraestructura
personal existente:

> **One app to operate Jack, OpenClaw, the VPS and the private
> infrastructure from anywhere.**


---

# 31. Arquitectura iOS profesional

## 31.1 Principios arquitectónicos

JackSsh se implementará como una aplicación nativa para iOS con:

- Swift y SwiftUI.
- MVVM con flujo unidireccional de estado.
- Modularización mediante Swift Packages locales.
- Organización feature-first, manteniendo juntos los archivos que pertenecen a una capacidad del producto.
- Dependency Inversion entre Presentation, Domain y Data.
- Inyección de dependencias por inicializador.
- Swift Concurrency mediante `async/await`, `Task`, `AsyncSequence` y actores cuando exista estado mutable compartido.
- Swift Testing para pruebas unitarias y de integración; XCTest/XCUITest sólo cuando sea necesario para UI automation o compatibilidad.
- Atomic Design dentro del paquete DesignSystem.
- `@Observable` y Observation para ViewModels nuevos, salvo restricciones justificadas.

La arquitectura debe ser escalable sin caer en abstracciones ceremoniales. Cada protocolo, capa y módulo debe tener una responsabilidad real.

## 31.2 Módulos obligatorios

```text
JackSsh/
├── JackSsh/            # App target y composition root
├── Packages/
│   ├── Presentation/
│   ├── Domain/
│   ├── Data/
│   ├── DesignSystem/
│   └── Shared/
├── JackSshTests/
├── JackSshUITests/
├── Documentation/
├── Configurations/
└── Scripts/
```

### JackSsh app target

Debe permanecer delgado y contener únicamente:

- `JackSshApp.swift`.
- Composition root.
- Creación de dependencias live.
- Navegación raíz.
- App lifecycle.
- Registro de notificaciones remotas.
- Manejo de universal links y custom deep links.
- Recursos, entitlements y configuración del bundle.

No debe contener reglas de negocio, implementaciones de repositorios, acceso SSH ni componentes reutilizables del sistema de diseño.

### Presentation package

Responsabilidades:

- SwiftUI Views.
- ViewModels MVVM.
- Estados de pantalla.
- Acciones de usuario.
- Rutas y destinos tipados.
- Modelos exclusivos de presentación.
- Mapeo Domain → Presentation.

No puede acceder directamente a Keychain, SwiftData, SSH, SFTP, APNs ni clientes HTTP concretos.

### Domain package

Es el núcleo independiente del producto.

Contiene:

- Entidades.
- Value Objects.
- Repository protocols.
- Use Cases.
- Domain Errors.
- Políticas de autorización y validación.

No debe importar SwiftUI, UIKit, SwiftData, librerías SSH ni implementaciones de red.

### Data package

Contiene las implementaciones concretas:

- Repositories live.
- Cliente SSH.
- Cliente SFTP.
- HTTP clients.
- Integración con OpenClaw.
- Health checks.
- Docker y systemd adapters.
- Persistencia SwiftData.
- Keychain adapters.
- Registro APNs y Notification Gateway.
- DTOs y mappers.

Data depende de Domain y Shared, nunca al revés.

### DesignSystem package

Contiene el lenguaje visual y los componentes reutilizables bajo Atomic Design:

```text
DesignSystem/
├── Tokens/
│   ├── ColorToken.swift
│   ├── TypographyToken.swift
│   ├── SpacingToken.swift
│   ├── RadiusToken.swift
│   ├── ElevationToken.swift
│   └── MotionToken.swift
├── Atoms/
├── Molecules/
├── Organisms/
├── Templates/
├── Foundations/
└── PreviewCatalog/
```

Reglas:

- Los átomos no conocen conceptos de dominio.
- Los componentes específicos de una feature permanecen en Presentation.
- Un componente sólo se promueve al DesignSystem cuando demuestra reutilización real.
- Todo componente público debe tener previews.
- Dynamic Type, VoiceOver, contraste, Reduce Motion y tamaños táctiles deben considerarse desde el inicio.
- Soporte completo de light mode y dark mode.

### Shared package

Sólo contiene primitivas verdaderamente transversales:

- Typed identifiers.
- Logging abstractions con `OSLog`.
- Utilidades de fecha y formato.
- Helpers de concurrencia.
- Errores comunes.
- Validadores reutilizables.
- Feature flags.
- Extensiones de Foundation justificadas.

Shared no debe convertirse en una carpeta de residuos.

## 31.3 Organización por features

Dentro de Presentation y de sus pruebas, los archivos deben organizarse por capacidad funcional:

```text
Presentation/Sources/Presentation/
├── AppShell/
│   ├── Root/
│   ├── Navigation/
│   └── State/
├── Features/
│   ├── Home/
│   │   ├── Models/
│   │   ├── ViewModels/
│   │   ├── Views/
│   │   └── Navigation/
│   ├── Hosts/
│   ├── OpenClaw/
│   ├── Terminal/
│   ├── Files/
│   ├── Services/
│   ├── Logs/
│   ├── Notifications/
│   └── Settings/
└── Shared/
    ├── Components/
    ├── Modifiers/
    └── Navigation/
```

Cada feature agrupa su UI, estado, navegación y modelos de presentación. No se crearán carpetas globales gigantes de `Views`, `ViewModels` o `Models` sin contexto funcional.

## 31.4 Ejemplo de feature OpenClaw

```text
Presentation/.../Features/OpenClaw/
├── Models/
│   ├── OpenClawStatusViewData.swift
│   └── OpenClawActivityViewData.swift
├── ViewModels/
│   └── OpenClawViewModel.swift
├── Views/
│   ├── OpenClawScreen.swift
│   ├── OpenClawDashboardView.swift
│   └── OpenClawActivityList.swift
├── Components/
│   ├── OpenClawHealthHeader.swift
│   └── OpenClawQuickActions.swift
└── Navigation/
    └── OpenClawRoute.swift
```

```text
Domain/.../
├── Entities/OpenClaw/
├── Repositories/OpenClawRepository.swift
└── UseCases/OpenClaw/
    ├── ObserveOpenClawStatus.swift
    ├── LoadOpenClawActivity.swift
    └── RestartOpenClaw.swift
```

```text
Data/.../OpenClaw/
├── API/
├── DTOs/
├── Mappers/
└── OpenClawRepositoryLive.swift
```

## 31.5 Flujo MVVM

```text
SwiftUI View
    ↓ user action
ViewModel (@MainActor, @Observable)
    ↓
Use Case
    ↓
Repository Protocol (Domain)
    ↓
Repository Live (Data)
    ↓
SSH / SFTP / HTTP / SwiftData / Keychain
```

La View sólo renderiza estado y emite acciones. El ViewModel coordina casos de uso, transforma resultados y controla tareas cancelables.

Ejemplo conceptual:

```swift
@MainActor
@Observable
final class OpenClawViewModel {
    private(set) var state: State = .idle

    private let observeStatus: ObserveOpenClawStatus
    private let restartService: RestartService

    init(
        observeStatus: ObserveOpenClawStatus,
        restartService: RestartService
    ) {
        self.observeStatus = observeStatus
        self.restartService = restartService
    }
}
```

Se prefieren estados explícitos sobre colecciones de booleanos inconsistentes:

```swift
enum Loadable<Value: Equatable>: Equatable {
    case idle
    case loading
    case loaded(Value)
    case failed(PresentationError)
}
```

## 31.6 Navegación

Usar `NavigationStack` y rutas tipadas:

```swift
enum AppRoute: Hashable {
    case host(HostID)
    case openClaw
    case openClawSession(SessionID)
    case terminal(HostID)
    case files(HostID, RemotePath)
    case service(ServiceID)
    case logs(ServiceID)
    case settings
}
```

Los deep links deben parsearse a rutas tipadas. Nunca deben ejecutar directamente una acción destructiva.

## 31.7 Inyección de dependencias

Usar constructor injection y composition root en el app target:

```swift
struct AppDependencies {
    let hostRepository: any HostRepository
    let serviceRepository: any ServiceRepository
    let sshRepository: any SSHRepository
    let fileRepository: any FileRepository
    let notificationRepository: any NotificationRepository
}
```

No usar singletons globales mutables para repositorios ni clientes de infraestructura.

## 31.8 Persistencia y secretos

- SwiftData: hosts, dashboards, servicios, favoritos, historial de eventos y destinos recientes.
- `UserDefaults`/`AppStorage`: preferencias pequeñas y no sensibles.
- Keychain: tokens, password fallback, referencias a llaves SSH y credenciales del gateway.
- Secure Enclave y `LocalAuthentication`: protección biométrica cuando aplique.

Las llaves privadas y tokens nunca se almacenan en SwiftData, plist, código fuente o archivos de configuración versionados.

## 31.9 Swift Concurrency

- Mutaciones de UI en `@MainActor`.
- Operaciones SSH, SFTP y HTTP asíncronas.
- Logs y eventos en streaming mediante `AsyncSequence`.
- Actores para clientes con estado mutable compartido.
- Propagación real de cancelación.
- Evitar `Task.detached` sin justificación.
- Tipos de dominio `Sendable` cuando crucen límites de concurrencia.

Ejemplo:

```swift
protocol LogStreamingRepository: Sendable {
    func streamLogs(
        for serviceID: ServiceID
    ) -> AsyncThrowingStream<LogEntry, Error>
}
```

## 31.10 Testing

Usar Swift Testing para unit tests e integration tests:

```swift
import Testing
@testable import Presentation

@Suite("OpenClawViewModel")
struct OpenClawViewModelTests {
    @Test("loads healthy service state")
    func loadsHealthyState() async throws {
        // Arrange
        // Act
        // Assert
    }
}
```

Estructura:

```text
Packages/
├── Presentation/Tests/PresentationTests/Features/
├── Domain/Tests/DomainTests/
├── Data/Tests/DataTests/
├── DesignSystem/Tests/DesignSystemTests/
└── Shared/Tests/SharedTests/
```

Cobertura prioritaria:

- Use Cases y políticas de Domain.
- ViewModels y navegación.
- Deep-link parsing.
- Notification routing.
- Host validation.
- Host-key verification.
- DTO mapping.
- Persistencia.
- Cancelación y recuperación.
- Estados offline, timeout y permisos denegados.

XCUITest se reserva para flujos críticos end-to-end:

1. Desbloquear con autenticación.
2. Abrir OpenClaw.
3. Navegar desde una notificación.
4. Abrir terminal y archivos.
5. Confirmar reinicio de servicio.
6. Manejar host offline.
7. Manejar cambio de host key.

## 31.11 Estándares de código

- Swift 6 cuando sea viable.
- Strict Concurrency Checking.
- Access control explícito.
- Value types por defecto.
- Clases `final` salvo herencia intencional.
- Sin force unwraps en producción.
- Sin `try?` silencioso cuando el error importa.
- Sin lógica de negocio en Views.
- Sin implementaciones Data dentro de Presentation.
- Sin credenciales hardcodeadas.
- Sin comandos arbitrarios ejecutados desde payloads push.
- APIs públicas documentadas.
- Previews para UI reutilizable.
- `OSLog` estructurado y sin secretos.

## 31.12 Árbol recomendado del repositorio

```text
JackSsh/
├── JackSsh.xcodeproj
├── JackSsh/
│   ├── App/
│   │   ├── JackSshApp.swift
│   │   ├── AppDelegate.swift
│   │   ├── AppDependencies.swift
│   │   ├── AppRouter.swift
│   │   └── RootView.swift
│   ├── Resources/
│   └── SupportingFiles/
├── Packages/
│   ├── Presentation/
│   ├── Domain/
│   ├── Data/
│   ├── DesignSystem/
│   └── Shared/
├── JackSshTests/
├── JackSshUITests/
├── Documentation/
│   ├── ARCHITECTURE.md
│   ├── SECURITY.md
│   ├── TESTING.md
│   └── DECISIONS/
├── Configurations/
│   ├── Debug.xcconfig
│   ├── Release.xcconfig
│   └── Secrets.example.xcconfig
├── Scripts/
├── .gitignore
└── README.md
```

# 32. Resumen final actualizado

JackSsh será una consola privada nativa para iOS, no una aplicación Android ni un simple cliente SSH.

Centralizará:

- Tailscale como capa privada subyacente.
- OpenClaw embebido mediante `WKWebView`.
- SSH y SFTP.
- Logs y servicios.
- Notificaciones push reales mediante APNs.
- Deep links contextuales.
- Acciones remotas seguras.
- Face ID, Keychain y Secure Enclave.

Su implementación seguirá MVVM, SwiftUI, Swift Concurrency, Swift Testing, módulos por paquetes, organización feature-first y un DesignSystem basado en Atomic Design.

> **One native iOS app to securely operate Jack, OpenClaw, the VPS, and the private infrastructure from anywhere.**
