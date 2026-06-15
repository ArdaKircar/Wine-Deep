#!/usr/bin/env bash
# ─────────────────────────────────────────────
#  wine-deep — Wine dependency installer
#  https://ardakircar.github.io/Wine-Deep
# ─────────────────────────────────────────────

set -e

# ── Colors ──────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ── Banner ───────────────────────────────────
echo ""
echo -e "${CYAN}${BOLD}"
echo "  ██╗    ██╗██╗███╗   ██╗███████╗      ██████╗ ███████╗███████╗██████╗ "
echo "  ██║    ██║██║████╗  ██║██╔════╝      ██╔══██╗██╔════╝██╔════╝██╔══██╗"
echo "  ██║ █╗ ██║██║██╔██╗ ██║█████╗  █████╗██║  ██║█████╗  █████╗  ██████╔╝"
echo "  ██║███╗██║██║██║╚██╗██║██╔══╝  ╚════╝██║  ██║██╔══╝  ██╔══╝  ██╔═══╝ "
echo "  ╚███╔███╔╝██║██║ ╚████║███████╗      ██████╔╝███████╗███████╗██║     "
echo "   ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝╚══════╝      ╚═════╝ ╚══════╝╚══════╝╚═╝     "
echo -e "${RESET}"
echo -e "  ${BOLD}Wine Dependency Installer${RESET} — installs essential winetricks libraries"
echo ""

# ── OS Detection ────────────────────────────
OS="$(uname -s)"
case "$OS" in
  Linux*)  PLATFORM="linux" ;;
  Darwin*) PLATFORM="mac" ;;
  *)
    echo -e "${RED}[✗] Unsupported OS: $OS${RESET}"
    exit 1
    ;;
esac
echo -e "${CYAN}[i] Detected platform: ${BOLD}$OS${RESET}"

# ── Check: Wine ──────────────────────────────
if ! command -v wine &>/dev/null; then
  echo -e "${RED}[✗] Wine is not installed. Please install Wine first:${RESET}"
  if [ "$PLATFORM" = "linux" ]; then
    echo -e "    ${YELLOW}https://wiki.winehq.org/Ubuntu${RESET}"
  else
    echo -e "    ${YELLOW}https://wiki.winehq.org/MacOS${RESET}"
  fi
  exit 1
fi
echo -e "${GREEN}[✓] Wine found: $(wine --version)${RESET}"

# ── Check: winetricks ───────────────────────
if ! command -v winetricks &>/dev/null; then
  echo -e "${YELLOW}[!] winetricks not found. Attempting to install...${RESET}"
  if [ "$PLATFORM" = "linux" ]; then
    if command -v apt-get &>/dev/null; then
      sudo apt-get install -y winetricks
    elif command -v pacman &>/dev/null; then
      sudo pacman -S --noconfirm winetricks
    elif command -v dnf &>/dev/null; then
      sudo dnf install -y winetricks
    else
      echo -e "${RED}[✗] Could not auto-install winetricks. Install it manually and re-run.${RESET}"
      exit 1
    fi
  elif [ "$PLATFORM" = "mac" ]; then
    if command -v brew &>/dev/null; then
      brew install winetricks
    else
      echo -e "${RED}[✗] Homebrew not found. Install Homebrew first: https://brew.sh${RESET}"
      exit 1
    fi
  fi
fi
echo -e "${GREEN}[✓] winetricks found: $(winetricks --version 2>/dev/null || echo 'ok')${RESET}"

# ── Dependencies list ────────────────────────
PACKAGES=(
  d3dcompiler_42
  d3dcompiler_43
  d3dcompiler_47
  d3dx11_43
  d3dx9
  dxvk
  quartz
  vkd3d
)

# vcrun2019 is handled separately (silent install, no Microsoft popup)
VCRUN_PACKAGE="vcrun2019"

# ── Install packages ─────────────────────────
echo ""
echo -e "${BOLD}── Installing winetricks packages ──────────────────${RESET}"
echo ""

FAILED=()

for pkg in "${PACKAGES[@]}"; do
  echo -e "${CYAN}[→] Installing ${BOLD}$pkg${RESET}${CYAN}...${RESET}"
  if WINEDEBUG=-all winetricks -q "$pkg" &>/dev/null; then
    echo -e "${GREEN}[✓] $pkg installed successfully${RESET}"
  else
    echo -e "${YELLOW}[!] $pkg may have had issues (continuing...)${RESET}"
    FAILED+=("$pkg")
  fi
  echo ""
done

# ── vcrun2019 — silent, no Microsoft installer ──
echo -e "${CYAN}[→] Installing ${BOLD}vcrun2019${RESET}${CYAN} (silent mode — no Microsoft popup)...${RESET}"
if WINEDEBUG=-all WINEDLLOVERRIDES="mscoree,mshtml=" winetricks -q "$VCRUN_PACKAGE" &>/dev/null; then
  echo -e "${GREEN}[✓] vcrun2019 installed (Wine Mono preserved)${RESET}"
else
  echo -e "${YELLOW}[!] vcrun2019 may have had issues${RESET}"
  FAILED+=("vcrun2019")
fi
echo ""

# ── Summary ──────────────────────────────────
echo -e "${BOLD}── Summary ─────────────────────────────────────────${RESET}"
echo ""
TOTAL=$(( ${#PACKAGES[@]} + 1 ))
FAIL_COUNT=${#FAILED[@]}
PASS_COUNT=$(( TOTAL - FAIL_COUNT ))

echo -e "${GREEN}[✓] $PASS_COUNT / $TOTAL packages installed${RESET}"

if [ "$FAIL_COUNT" -gt 0 ]; then
  echo -e "${YELLOW}[!] The following packages had issues:${RESET}"
  for f in "${FAILED[@]}"; do
    echo -e "    ${RED}• $f${RESET}"
  done
  echo ""
  echo -e "${YELLOW}    Try running them manually with: ${BOLD}winetricks -q <package>${RESET}"
else
  echo -e "${GREEN}[✓] All packages installed successfully!${RESET}"
fi

echo ""
echo -e "${CYAN}${BOLD}wine-deep complete. Happy gaming! 🍷${RESET}"
echo ""
