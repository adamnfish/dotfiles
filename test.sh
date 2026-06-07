#!/usr/bin/env bash

set -euo pipefail

DEFAULT_IMAGE="ubuntu:latest"
REPO_URL="https://github.com/adamnfish/dotfiles.git"

IMAGE="$DEFAULT_IMAGE"
MODE="manual"
BRANCH=""

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Start an ephemeral container, install dotfiles, then open an interactive shell
or run automated checks.

OPTIONS:
  --image IMAGE    Base Docker image to use (default: ${DEFAULT_IMAGE})
  --branch BRANCH  Branch to check out (default: repo default branch)
  --auto           Run automated checks instead of an interactive shell
  -h, --help       Show this help message

EXAMPLES:
  $(basename "$0")
  $(basename "$0") --image mcr.microsoft.com/devcontainers/base:ubuntu
  $(basename "$0") --branch my-feature
  $(basename "$0") --auto
  $(basename "$0") --auto --image ubuntu:24.04
EOF
}

while [[ $# -gt 0 ]]; do
  case $1 in
    --image)
      if [[ $# -lt 2 ]]; then
        printf "Error: --image requires an argument\n" >&2
        usage >&2
        exit 1
      fi
      IMAGE="$2"
      shift 2
      ;;
    --branch)
      if [[ $# -lt 2 ]]; then
        printf "Error: --branch requires an argument\n" >&2
        usage >&2
        exit 1
      fi
      BRANCH="$2"
      shift 2
      ;;
    --auto)
      MODE="auto"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf "Error: unknown option: %s\n" "$1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if ! command -v docker &>/dev/null; then
  printf "Error: docker is not available on PATH. Install Docker and try again.\n" >&2
  exit 1
fi

printf "Image:  %s\n" "$IMAGE"
printf "Mode:   %s\n" "$MODE"
printf "Branch: %s\n\n" "${BRANCH:-(default)}"

case "$MODE" in
  manual)
    printf "Starting interactive session (container will be removed on exit)...\n"
    # install.sh uses a relative path on its first line (>> .bash_aliases), so it must be
    # invoked from the home directory for that path to resolve to ~/.bash_aliases correctly.
    docker run --rm -it \
      -e "DEBIAN_FRONTEND=noninteractive" \
      "$IMAGE" \
      bash -c "cd ~ \
        && apt-get update -q \
        && apt-get install -y -q git \
        && git clone ${BRANCH:+--branch ${BRANCH} }${REPO_URL} dotfiles \
        && pushd dotfiles \
        && bash install.sh \
        && popd \
        && exec bash"
    ;;
  auto)
    printf "Running automated checks...\n"
    # Pass the repo URL as an environment variable so the single-quoted heredoc
    # (which prevents outer-shell expansion) can still reference it inside the container.
    docker run --rm -i \
      -e "DEBIAN_FRONTEND=noninteractive" \
      -e "DOTFILES_REPO=${REPO_URL}" \
      -e "DOTFILES_BRANCH=${BRANCH}" \
      "$IMAGE" \
      bash -s <<'SCRIPT'
set -euo pipefail
cd ~
# Redirect stdout to /dev/null during setup to keep check output readable.
# Errors (stderr) are still forwarded so failures remain visible.
printf "  apt-get update...\n" >&2
apt-get update -q >/dev/null
printf "  apt-get install git...\n" >&2
apt-get install -y -q git >/dev/null
printf "  cloning dotfiles...\n" >&2
git clone -q ${DOTFILES_BRANCH:+--branch "$DOTFILES_BRANCH" }"$DOTFILES_REPO" dotfiles
printf "  running install.sh...\n" >&2
pushd dotfiles >/dev/null
bash install.sh >/dev/null
popd >/dev/null
printf "  setup complete.\n" >&2

# Non-interactive bash neither sources ~/.bash_aliases nor enables alias processing.
# Both are required: shopt enables the alias table, source loads the definitions.
shopt -s expand_aliases
source ~/.bash_aliases

PASS=0
FAIL=0

check() {
  local desc="$1"
  local result="$2"
  if [[ "$result" == "pass" ]]; then
    printf "  PASS: %s\n" "$desc"
    PASS=$((PASS + 1))
  else
    printf "  FAIL: %s\n" "$desc"
    FAIL=$((FAIL + 1))
  fi
}

printf "\nRunning checks...\n"

if [[ -f ~/.bash_aliases ]]; then
  check ".bash_aliases exists" "pass"
else
  check ".bash_aliases exists" "fail"
fi

if grep -q "adamnfish/dotfiles" ~/.bash_aliases 2>/dev/null; then
  check ".bash_aliases contains dotfiles header" "pass"
else
  check ".bash_aliases contains dotfiles header" "fail"
fi

for name in la ll gatus hex2rgb cu gog; do
  if type "$name" &>/dev/null; then
    check "$name is available" "pass"
  else
    check "$name is available" "fail"
  fi
done

if type emacs &>/dev/null; then
  check "emacs is available" "pass"
else
  check "emacs is available" "fail"
fi

if [[ -f /usr/share/liquidprompt/liquidprompt ]]; then
  check "liquidprompt is installed" "pass"
else
  check "liquidprompt is installed" "fail"
fi

if [[ -f ~/.emacs.d/init.el ]]; then
  check "emacs config is installed" "pass"
else
  check "emacs config is installed" "fail"
fi

printf "\nResults: %d passed, %d failed\n" "$PASS" "$FAIL"
[[ $FAIL -eq 0 ]]
SCRIPT
    ;;
esac
