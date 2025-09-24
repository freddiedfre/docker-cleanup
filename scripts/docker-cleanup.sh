#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
docker-cleanup: Unified Docker cleanup tool (Linux/macOS/Windows with Docker Desktop/Rootless)
Usage:
  docker-cleanup [command]

Commands:
  show        Show all Docker resources
  default     Prune unused containers/images/volumes/networks
  full        Aggressive cleanup of all resources
  selective   Interactive selective cleanup
  project     Project-only cleanup (if Docker project detected)
  menu        Launch interactive menu (default)

Examples:
  docker-cleanup default
  docker-cleanup project
EOF
  exit 0
}

[[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && usage

MODE="${1:-menu}"
shift || true

confirm() {
  read -rp ">> $1 [y/N]: " ans
  [[ "$ans" =~ ^[Yy]$ ]]
}

err() { echo "ERROR: $*" >&2; }

is_docker_project() {
  shopt -s nullglob
  local files=(Dockerfile docker-compose*.yml docker-compose*.yaml .devcontainer docker-compose.override*.yml docker-compose.override*.yaml)
  (( ${#files[@]} > 0 ))
}

detect_docker_host() {
  local sock="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/docker.sock"
  if [[ -S "$sock" ]]; then
    export DOCKER_HOST="unix://$sock"
    echo ">> Using rootless Docker socket at $sock"
    return 0
  fi

  if docker info &>/dev/null; then
    unset DOCKER_HOST
    echo ">> Using rootful/desktop Docker socket"
    return 0
  fi

  err "No usable Docker socket found. Exiting."
  exit 1
}

show_resources() {
  echo "===================================================="
  echo "Docker Resources"
  echo "===================================================="

  echo -e "\nContainers:"
  docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}"

  echo -e "\nImages:"
  docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}"

  echo -e "\nVolumes:"
  docker volume ls --format "table {{.Name}}\t{{.Driver}}\t{{.Mountpoint}}"

  echo -e "\nNetworks:"
  docker network ls --format "table {{.ID}}\t{{.Name}}\t{{.Driver}}\t{{.Scope}}"

  echo -e "\nBuild Cache:"
  docker buildx du || echo "No buildx cache info available."
}

default_cleanup() {
  echo ">> Running safe cleanup of unused Docker resources..."
  docker container prune -f
  docker image prune -f
  docker volume prune -f
  docker network prune -f --filter "until=0h" || true
  docker builder prune -f
  echo "Default cleanup completed."
}

full_cleanup() {
  if confirm "Remove ALL containers, images, volumes, networks (except defaults), and build cache?"; then
    docker ps -aq | xargs -r docker stop
    docker ps -aq | xargs -r docker rm -f
    docker images -aq | xargs -r docker rmi -f
    docker volume ls -q | xargs -r docker volume rm -f
    docker network ls --format '{{.Name}}' \
      | grep -vE '^(bridge|host|none)$' \
      | xargs -r docker network rm
    docker builder prune -af
    echo "Full cleanup completed."
  else
    echo "Full cleanup aborted."
  fi
}

selective_cleanup() {
  echo "Choose resource type to clean:"
  echo "1) Containers"
  echo "2) Images"
  echo "3) Volumes"
  echo "4) Networks"
  echo "5) Build cache"
  read -rp "Enter choice [1-5]: " choice

  case "$choice" in
    1)
      docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}"
      read -rp "Enter container IDs/Names to remove (space separated): " ids
      if [[ -n "${ids:-}" ]]; then
        read -ra arr <<<"$ids"
        docker rm -f "${arr[@]}"
      fi
      ;;
    2)
      docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}"
      read -rp "Enter image IDs to remove (space separated): " ids
      if [[ -n "${ids:-}" ]]; then
        read -ra arr <<<"$ids"
        docker rmi -f "${arr[@]}"
      fi
      ;;
    3)
      docker volume ls --format "table {{.Name}}\t{{.Driver}}"
      read -rp "Enter volume names to remove (space separated): " ids
      if [[ -n "${ids:-}" ]]; then
        read -ra arr <<<"$ids"
        docker volume rm "${arr[@]}"
      fi
      ;;
    4)
      docker network ls --format "table {{.ID}}\t{{.Name}}\t{{.Driver}}"
      read -rp "Enter network IDs/Names to remove (space separated): " ids
      read -ra arr <<<"$ids"
      for net in "${arr[@]}"; do
        if [[ "$net" =~ ^(bridge|host|none)$ ]]; then
          echo "Skipping default network: $net"
        else
          docker network rm "$net"
        fi
      done
      ;;
    5)
      docker buildx du
      if confirm "Remove ALL build cache?"; then
        docker buildx prune -af
      fi
      ;;
    *) echo "Invalid choice." ;;
  esac
}

project_limited_cleanup() {
  echo ">> Project context detected (Dockerfile/docker-compose/devcontainer present)."
  local project="${PWD##*/}"
  docker ps -a --filter "name=$project" --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"
  docker images --filter "reference=$project*" --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}"
  if confirm "Remove containers/images for project '$project'?"; then
    docker ps -aq --filter "name=$project" | xargs -r docker rm -f
    docker images -q --filter "reference=$project*" | xargs -r docker rmi -f
  fi
}

detect_docker_host

# --- CLI Mode Dispatch ---
case "$MODE" in
  show) show_resources; exit 0 ;;
  default) default_cleanup; exit 0 ;;
  full) full_cleanup; exit 0 ;;
  selective) selective_cleanup; exit 0 ;;
  project) project_limited_cleanup; exit 0 ;;
  menu) ;;
  *) usage ;;
esac

# --- Interactive Menu Mode ---
while true; do
  echo "===================================================="
  echo "Docker Safe Cleanup Menu"
  echo "===================================================="
  echo "1) Show all resources"
  echo "2) Default cleanup (recommended unused only)"
  echo "3) Full cleanup (everything)"
  echo "4) Selective cleanup"
  if is_docker_project; then
    echo "5) Project-only cleanup"
    echo "6) Exit"
  else
    echo "5) Exit"
  fi

  read -rp "Enter choice: " action
  case "$action" in
    1) show_resources ;;
    2) default_cleanup ;;
    3) full_cleanup ;;
    4) selective_cleanup ;;
    5) if is_docker_project; then project_limited_cleanup; else exit 0; fi ;;
    6) exit 0 ;;
    *) echo "Invalid choice." ;;
  esac
done
