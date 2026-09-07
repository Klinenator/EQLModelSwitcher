#!/bin/bash

# Toggle EQL's built-in classic and Luclin character model settings.

set -eu

if [ -n "${EQL_GAME_DIR:-}" ]; then
  GAME_DIR="$EQL_GAME_DIR"
else
  printf '%s' "Enter your EQL installation folder: "
  read -r GAME_DIR
fi

INI="$GAME_DIR/eqclient.ini"
BACKUP_DIR="$GAME_DIR/eqclient-model-backups"

if [ ! -f "$INI" ]; then
  printf '%s\n' "Could not find: $INI"
  printf '%s\n' "Set EQL_GAME_DIR to your EQL folder and try again."
  exit 1
fi

MODE="${1:-status}"

model_keys=(
  UseLuclinHumanMale
  UseLuclinHumanFemale
  UseLuclinBarbarianMale
  UseLuclinBarbarianFemale
  UseLuclinEruditeMale
  UseLuclinEruditeFemale
  UseLuclinWoodElfMale
  UseLuclinWoodElfFemale
  UseLuclinHighElfMale
  UseLuclinHighElfFemale
  UseLuclinDarkElfMale
  UseLuclinDarkElfFemale
  UseLuclinHalfElfMale
  UseLuclinHalfElfFemale
  UseLuclinDwarfMale
  UseLuclinDwarfFemale
  UseLuclinTrollMale
  UseLuclinTrollFemale
  UseLuclinOgreMale
  UseLuclinOgreFemale
  UseLuclinHalflingMale
  UseLuclinHalflingFemale
  UseLuclinGnomeMale
  UseLuclinGnomeFemale
  UseLuclinIksarMale
  UseLuclinIksarFemale
  UseLuclinElementals
)

set_key() {
  key="$1"
  value="$2"
  if rg -q "^${key}=" "$INI"; then
    sed -i '' -E "s/^${key}=.*/${key}=${value}/" "$INI"
  else
    printf '%s=%s\n' "$key" "$value" >> "$INI"
  fi
}

backup() {
  mkdir -p "$BACKUP_DIR"
  stamp="$(date +%Y%m%d-%H%M%S)"
  cp "$INI" "$BACKUP_DIR/eqclient.ini.$stamp"
  printf '%s\n' "Backup created: $BACKUP_DIR/eqclient.ini.$stamp"
}

clean_legacy_bad_line() {
  # Remove the concatenated setting created by an older version of this script.
  sed -i '' '/^UseLuclinHumanMaleUseLuclin/d' "$INI"
}

case "$MODE" in
  classic)
    backup
    clean_legacy_bad_line
    set_key AllLuclinPcModelsOff 1
    set_key LoadSocialAnimations FALSE
    for key in "${model_keys[@]}"; do
      set_key "$key" false
    done
    printf '%s\n' "Classic-era models enabled."
    ;;
  luclin)
    backup
    clean_legacy_bad_line
    set_key AllLuclinPcModelsOff 0
    set_key LoadSocialAnimations TRUE
    for key in "${model_keys[@]}"; do
      set_key "$key" true
    done
    printf '%s\n' "Luclin-era models enabled."
    ;;
  restore)
    latest="$(find "$BACKUP_DIR" -type f -name 'eqclient.ini.*' -print | sort | tail -n 1)"
    if [ -z "$latest" ]; then
      printf '%s\n' "No model-setting backup was found."
      exit 1
    fi
    cp "$latest" "$INI"
    printf '%s\n' "Restored: $latest"
    ;;
  status)
    rg -n '^(AllLuclinPcModelsOff|LoadSocialAnimations|UseLuclin)' "$INI" || true
    ;;
  *)
    printf '%s\n' "Usage: $0 classic | luclin | status | restore"
    exit 2
    ;;
esac
