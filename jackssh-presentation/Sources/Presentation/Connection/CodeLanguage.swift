import Foundation

enum CodeLanguage: String {
    case swift = "Swift"
    case kotlin = "Kotlin"
    case javascript = "JavaScript"
    case typescript = "TypeScript"
    case python = "Python"
    case ruby = "Ruby"
    case go = "Go"
    case rust = "Rust"
    case java = "Java"
    case c = "C"
    case cpp = "C++"
    case csharp = "C#"
    case shell = "Shell"
    case json = "JSON"
    case yaml = "YAML"
    case xml = "XML"
    case html = "HTML"
    case css = "CSS"
    case sql = "SQL"
    case markdown = "Markdown"
    case plainText = "Plain text"

    static func detect(for fileName: String) -> CodeLanguage {
        let name = fileName.lowercased()
        if ["dockerfile", "makefile", "gemfile", "rakefile"].contains(name) { return .shell }
        switch URL(fileURLWithPath: name).pathExtension {
        case "swift": return .swift
        case "kt", "kts": return .kotlin
        case "js", "jsx", "mjs", "cjs": return .javascript
        case "ts", "tsx": return .typescript
        case "py": return .python
        case "rb": return .ruby
        case "go": return .go
        case "rs": return .rust
        case "java": return .java
        case "c", "h": return .c
        case "cc", "cpp", "cxx", "hpp": return .cpp
        case "cs": return .csharp
        case "sh", "bash", "zsh", "fish", "env", "conf", "ini", "toml": return .shell
        case "json": return .json
        case "yaml", "yml": return .yaml
        case "xml", "plist", "svg": return .xml
        case "html", "htm": return .html
        case "css", "scss", "sass": return .css
        case "sql": return .sql
        case "md", "mdx": return .markdown
        default: return .plainText
        }
    }
}
