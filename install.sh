#/bin/sh

if [ $(uname) = "Linux" ]; then
  mkdir -p "${HOME}/.config/waybar"

  ln -sf "${PWD}/config" "${HOME}/.config/waybar/"
  ln -sf "${PWD}/style.css" "${HOME}/.config/waybar/"
  ln -sf "${PWD}/scripts" "${HOME}/.config/waybar/"
fi
