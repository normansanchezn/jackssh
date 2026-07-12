---
title: JackSSH Obsidian Vault
tags:
  - jackssh
  - obsidian-vault
  - index
---

# JackSSH Obsidian Vault

Este directorio es el vault de Obsidian del proyecto. Toda documentación `.md` debe vivir aquí, con frontmatter YAML y tags útiles para el grafo.

## Mapa

- [[00-meta/AGENTS|AGENTS]]: instrucciones para agentes y uso de CodeGraph.
- [[00-meta/CLAUDE|CLAUDE]]: guardrails de arquitectura para asistentes.
- [[01-product/Product-and-Architecture|Product and Architecture]]: visión del producto y arquitectura funcional.
- [[01-product/Real-Host-Connection-Flow|Real Host Connection Flow]]: flujo real de conexión SSH.
- [[02-setup/Development-Setup|Development Setup]]: entorno local.
- [[02-setup/Permissions-and-Privacy|Permissions and Privacy]]: permisos iOS y privacidad.
- [[02-setup/Supabase-Local-Setup|Supabase Local Setup]]: Supabase local.
- [[02-setup/Supabase-Remote-Setup|Supabase Remote Setup]]: Supabase remoto.
- [[02-setup/Supabase-Integration-Guide|Supabase Integration Guide]]: integración con la app.
- [[02-setup/Successful-Connection-Best-Practices|Successful Connection Best Practices]]: checklist operativo para conexiones SSH confiables.
- [[03-architecture/Dependency-Injection|Dependency Injection]]: composición de dependencias.
- [[03-architecture/Localization-Architecture|Localization Architecture]]: localización en `Presentation`.
- [[04-modules/presentation/auth/welcome/Welcome-Architecture|Welcome Architecture]]: MVVM de Welcome.
- [[04-modules/design-system/atoms/DSButton|DSButton]]: botón del design system.
- [[05-plans/2026-07-11-Host-Onboarding-SSH-Connection|Host Onboarding SSH Connection Plan]]: plan histórico.

## Organización

- `00-meta`: reglas para agentes y herramientas.
- `01-product`: visión, objetivos y flujos de producto.
- `02-setup`: setup local, permisos e integración externa.
- `03-architecture`: decisiones transversales del sistema.
- `04-modules`: documentación por módulo y feature.
- `05-plans`: planes de implementación fechados.
- `99-archive`: notas antiguas o readmes mínimos conservados por trazabilidad.

## Reglas del vault

1. Cada archivo `.md` debe tener frontmatter YAML con `title` y `tags`.
2. Usa wikilinks `[[...]]` para conectar decisiones, módulos y features.
3. No guardes documentación nueva dentro de carpetas `Sources`; muévela aquí.
4. Si una nota describe una arquitectura vieja, actualízala o muévela a `99-archive`.
5. Las instrucciones de arquitectura vivas están en [[00-meta/CLAUDE|CLAUDE]] y [[00-meta/AGENTS|AGENTS]].

## Tags principales

- `#architecture`
- `#module/presentation`
- `#module/design-system`
- `#localization`
- `#supabase`
- `#ssh`
- `#agent-instructions`
- `#architecture-guardrails`
