#!/usr/bin/env bash

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "This bootstrap script must be run as root" >&2
  exit 1
fi

info() {
  printf '\n→ %s\n' "$1"
}

enable_service() {
  local service="$1"

  if ! command -v systemctl >/dev/null 2>&1; then
    info "Skipping ${service} (systemctl unavailable)"
    return
  fi

  if ! systemctl enable "$service" >/dev/null 2>&1; then
    info "Skipping ${service}; could not enable (systemd inactive?)"
    return
  fi

  if ! systemctl start "$service" >/dev/null 2>&1; then
    info "Unable to start ${service} now; it will start on next boot"
  fi
}

prompt_user() {
  local prompt="$1"
  local var_name="$2"
  local value
  while true; do
    read -rp "$prompt" value
    if [[ -n "$value" ]]; then
      printf -v "$var_name" '%s' "$value"
      return 0
    fi
  done
}

select_timezone() {
  local selection
  while true; do
    prompt_user "Timezone (e.g. Europe/Berlin): " selection
    if [[ -f "/usr/share/zoneinfo/$selection" ]]; then
      printf -v "$1" '%s' "$selection"
      return 0
    fi
    echo "Invalid timezone. Please try again." >&2
  done
}

ESSENTIAL_PACKAGES=(
  base-devel
  git
  curl
  zsh
  zsh-completions
  networkmanager
  openssh
  gnupg
  neovim
)

CONSOLE_KEYMAP="ruwin_alt-shift"
CONSOLE_FONT="cyr-sun16"

info "Updating package database"
pacman -Syu --noconfirm

info "Installing essential packages"
pacman -S --needed --noconfirm "${ESSENTIAL_PACKAGES[@]}"

prompt_user "Hostname: " HOSTNAME_VALUE
select_timezone TIMEZONE_VALUE
prompt_user "New admin username: " NEW_USER

LOCALE_ENTRIES=("en_US.UTF-8 UTF-8")
LANG_VALUE="en_US.UTF-8"
LC_TIME_VALUE="en_US.UTF-8"

if [[ -f /usr/share/i18n/locales/ru_RU ]]; then
  LOCALE_ENTRIES+=("ru_RU.UTF-8 UTF-8")
  LC_TIME_VALUE="ru_RU.UTF-8"
else
  info "ru_RU locale definition not found; skipping"
fi

info "Setting hostname to $HOSTNAME_VALUE"
echo "$HOSTNAME_VALUE" > /etc/hostname

info "Configuring /etc/hosts"
cat <<HOSTS >/etc/hosts
127.0.0.1	localhost
::1	localhost
127.0.1.1	$HOSTNAME_VALUE
HOSTS

info "Configuring timezone to $TIMEZONE_VALUE"
ln -sf "/usr/share/zoneinfo/$TIMEZONE_VALUE" /etc/localtime
if ! hwclock --systohc >/dev/null 2>&1; then
  info "Skipping hardware clock sync"
fi

info "Configuring console keymap"
cat <<EOF >/etc/vconsole.conf
KEYMAP=${CONSOLE_KEYMAP}
FONT=${CONSOLE_FONT}
EOF
if ! loadkeys "$CONSOLE_KEYMAP" >/dev/null 2>&1; then
  info "Skipping loadkeys (no console available)"
fi

info "Configuring locales"
for entry in "${LOCALE_ENTRIES[@]}"; do
  if grep -q "^${entry}$" /etc/locale.gen; then
    continue
  elif grep -q "^#\s*${entry}$" /etc/locale.gen; then
    sed -i "s/^#\s*${entry}$/${entry}/" /etc/locale.gen
  else
    echo "${entry}" >> /etc/locale.gen
  fi
done

cat <<EOF >/etc/locale.conf
LANG=${LANG_VALUE}
LC_TIME=${LC_TIME_VALUE}
EOF
locale-gen

info "Enabling NetworkManager"
enable_service NetworkManager.service

info "Enabling systemd-timesyncd"
enable_service systemd-timesyncd.service

info "Creating user $NEW_USER"
useradd -m -U -G wheel "$NEW_USER"

info "Setting password for $NEW_USER"
if [[ -n "${BOOTSTRAP_PASSWORD:-}" ]]; then
  echo "$NEW_USER:${BOOTSTRAP_PASSWORD}" | chpasswd
else
  passwd "$NEW_USER"
fi

info "Configuring sudo access"
echo "$NEW_USER ALL=(ALL) ALL" > "/etc/sudoers.d/$NEW_USER"
chmod 0440 "/etc/sudoers.d/$NEW_USER"

info "Changing default shell to zsh"
chsh -s /bin/zsh "$NEW_USER"

info "Preparing user local bin directory"
install -d -m 755 -o "$NEW_USER" -g "$NEW_USER" "/home/$NEW_USER/.local/bin"

info "Bootstrap complete"
