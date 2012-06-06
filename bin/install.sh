#!/bin/bash

BIN_DIR=$(cd "$(dirname "$0")"; pwd)
DOTFILES_DIR=$(dirname "$BIN_DIR")
HOME_DIR=$(cd ~; pwd)

symlinks=$(find $DOTFILES_DIR -name '*.symlink' -print)
for symlink in $symlinks; do
  name=$(basename "${symlink%.symlink}")
  # Anything beginning with _ should be renamed to .file (e.g. _vimrc -> .vimrc)
  name=${name/#_/.}
  basedir=$(dirname "$symlink")
  basedir=${basedir#$DOTFILES_DIR} # Note: includes slash at the beginning.

  # Create the required directory structure if one is needed.
  if [ ! -z "$basedir" ] && [ ! -e "${HOME_DIR}${basedir}" ]; then
    $(mkdir -p "${HOME_DIR}${basedir}")
    echo "Created directory: ${HOME_DIR}${basedir}"
  fi

  # Create symlinks.
  # This will produce something like:
  # ln -fs /home/rich/.dotfiles/vimrc.symlink /home/rich/.vimrc
  if [ -z "$basedir" ]; then
    link_at="${HOME_DIR}/${name}"
  else
    link_at="${HOME_DIR}${basedir}/${name}"
  fi

  $(ln -fs "${symlink}" "${link_at}")
  echo "Created symlink to ${symlink} at ${link_at}"
done
