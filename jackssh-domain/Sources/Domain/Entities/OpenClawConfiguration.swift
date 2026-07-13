import Foundation

/// Optional OpenClaw dashboard configuration.
public struct OpenClawConfiguration: Equatable, Sendable {
    public let host: String
    public let port: Int
    public let scheme: String // "http" or "https"
    public let basePath: String
    public let authTokenCommand: String?

    public init(
        host: String,
        port: Int = 18789,
        scheme: String = "http",
        basePath: String = "/",
        authTokenCommand: String? = nil
    ) {
        self.host = host
        self.port = port
        self.scheme = scheme
        self.basePath = basePath
        self.authTokenCommand = authTokenCommand
    }

    public var dashboardURL: URL? {
        URL(string: "\(scheme)://\(host):\(port)\(basePath)")
    }

    public var resolvedAuthTokenCommand: String {
        authTokenCommand ?? Self.defaultAuthTokenCommand
    }

    private static let defaultAuthTokenCommand = """
    emit_token() {
      value="$(printf '%s' "$1" | tr -d '\\r' | awk 'NF { print; exit }')"
      if [ -n "$value" ]; then printf '%s\\n' "$value"; exit 0; fi
    }

    try_file() {
      if [ -r "$1" ]; then
        case "$1" in
          *.json) cat "$1" 2>/dev/null; exit 0 ;;
          *) emit_token "$(cat "$1" 2>/dev/null)" ;;
        esac
      fi
    }

    try_command() {
      output="$("$@" 2>/dev/null | tr -d '\\r' | awk 'NF { print; exit }')"
      if [ -n "$output" ]; then printf '%s\\n' "$output"; exit 0; fi
    }

    extract_env_token() {
      awk -F= '
        BEGIN { keys=" OPENCLAW_TOKEN OPENCLAW_AUTH_TOKEN OPENCLAW_DASHBOARD_TOKEN DASHBOARD_TOKEN AUTH_TOKEN AUTHORIZATION ACCESS_TOKEN JWT TOKEN " }
        index(keys, " " $1 " ") > 0 && length($2) > 0 {
          sub(/^[^=]*=/, "")
          print
          exit
        }
      '
    }

    for path in \
      "$HOME/.openclaw/token" \
      "$HOME/.config/openclaw/token" \
      "$HOME/.openclaw/dashboard.token" \
      "/root/.openclaw/token" \
      "/root/.config/openclaw/token" \
      "/root/openclaw/data/credentials/openclaw-secrets.json" \
      "/etc/openclaw/token" \
      "/etc/openclaw/dashboard.token" \
      "/var/lib/openclaw/token" \
      "/var/lib/openclaw/dashboard.token" \
      "/opt/openclaw/token" \
      "/opt/openclaw/.openclaw/token" \
      "/app/.openclaw/token" \
      "/data/openclaw/token"
    do
      try_file "$path"
    done

    output="$(env | extract_env_token)"
    if [ -n "$output" ]; then printf '%s\\n' "$output"; exit 0; fi

    if command -v openclaw >/dev/null 2>&1; then
      try_command openclaw auth token
      try_command openclaw token
      try_command openclaw dashboard token
    fi

    if command -v docker >/dev/null 2>&1; then
      container_ids="$(docker ps --format '{{.ID}} {{.Names}} {{.Image}}' 2>/dev/null | awk 'tolower($0) ~ /openclaw/ { print $1 }')"
      if [ -z "$container_ids" ]; then
        container_ids="$(docker ps --format '{{.ID}}' 2>/dev/null | awk 'NR <= 20 { print }')"
      fi

      for container_id in $container_ids; do
        output="$(docker inspect --format '{{range .Config.Env}}{{println .}}{{end}}' "$container_id" 2>/dev/null | extract_env_token)"
        if [ -n "$output" ]; then printf '%s\\n' "$output"; exit 0; fi
        output="$(docker exec "$container_id" sh -lc '
          emit() { v="$(printf "%s" "$1" | tr -d "\\r" | awk "NF { print; exit }")"; [ -n "$v" ] && { printf "%s\\n" "$v"; exit 0; }; }
          for f in "$HOME/.openclaw/token" "$HOME/.config/openclaw/token" /root/.openclaw/token /root/.config/openclaw/token /root/openclaw/data/credentials/openclaw-secrets.json /etc/openclaw/token /var/lib/openclaw/token /app/.openclaw/token /app/openclaw/token /data/openclaw/token; do
            if [ -r "$f" ]; then
              case "$f" in
                *.json) cat "$f" 2>/dev/null; exit 0 ;;
                *) emit "$(cat "$f" 2>/dev/null)" ;;
              esac
            fi
          done
          for k in OPENCLAW_TOKEN OPENCLAW_AUTH_TOKEN OPENCLAW_DASHBOARD_TOKEN DASHBOARD_TOKEN AUTH_TOKEN AUTHORIZATION ACCESS_TOKEN JWT TOKEN; do
            eval "v=\\${$k:-}"
            emit "$v"
          done
          if command -v openclaw >/dev/null 2>&1; then
            openclaw auth token 2>/dev/null || openclaw token 2>/dev/null || openclaw dashboard token 2>/dev/null || true
          fi
        ' 2>/dev/null | tr -d '\\r' | awk 'NF { print; exit }')"
        if [ -n "$output" ]; then printf '%s\\n' "$output"; exit 0; fi
      done
    fi

    true
    """
}
