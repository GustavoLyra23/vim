ZSH_THEME="mgutz"

# Plugins do Oh My Zsh e complementos locais para desenvolvimento.
# Sugestoes e syntax highlighting continuam sendo carregados pelo CachyOS.
export ZSH_CUSTOM="${XDG_DATA_HOME:-$HOME/.local/share}/oh-my-zsh/custom"
source "$ZSH_CUSTOM/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh"
plugins=(
  git fzf extract z sudo colored-man-pages
  docker docker-compose azure python jsontools urltools dirhistory
)
export FZF_BASE=/usr/share/fzf
export FZF_DEFAULT_OPTS='--height=40% --layout=reverse --border'
# Preserve o PATH existente e garanta os diretorios dos comandos basicos.
# O array path do Zsh e vinculado automaticamente a variavel PATH.
typeset -U path
path=("${path[@]}" /usr/local/sbin /usr/local/bin /usr/bin /bin)
export PATH

# Use o Fish como fonte dos caminhos personalizados (inclui fish_add_path).
# Sem -i, evita carregar plugins exclusivos de sessoes interativas.
if [[ -x /usr/bin/fish ]]; then
  _fish_path="$(/usr/bin/fish -c 'string join : -- $PATH')"
  if [[ $? -eq 0 && -n $_fish_path ]]; then
    export PATH="$_fish_path"
  fi
  unset _fish_path
fi

if (( $+commands[fd] )); then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
fi

# Pre-visualizacao de arquivos (Ctrl+T) e pastas (Alt+C) no fzf.
if (( $+commands[bat] )); then
  export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:150 {}' --bind 'ctrl-/:toggle-preview'"
fi
if (( $+commands[eza] )); then
  export FZF_ALT_C_OPTS="--preview 'eza --color=always --tree --level=2 -- {}'"
fi

# Python: ambientes virtuais criados com mkv ficam em .venv.
PYTHON_VENV_NAME=.venv
PYTHON_VENV_NAMES=(.venv venv)
JSONTOOLS_METHOD=python3
URLTOOLS_METHOD=python

ZSH_AUTOSUGGEST_STRATEGY=(history)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:git-checkout:*' sort false

source /usr/share/cachyos-zsh-config/cachyos-config.zsh
source /usr/share/nvm/init-nvm.sh
# Historico persistente e compartilhado entre terminais.
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS
setopt AUTO_CD INTERACTIVE_COMMENTS
unsetopt CORRECT CORRECT_ALL

# Edicao estilo Emacs, navegacao nos menus e aceite de sugestoes.
bindkey -e
bindkey '^I' complete-word
bindkey '^[[A' up-line-or-search
bindkey '^[[B' down-line-or-select
bindkey '^[OA' up-line-or-search
bindkey '^[OB' down-line-or-select
bindkey '^[[C' forward-char
bindkey '^[OC' forward-char
bindkey '^ ' autosuggest-accept
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# Listagem legivel, mantendo ls e cat disponiveis como de costume.
if (( $+commands[eza] )); then
  alias ll='eza -lh --group-directories-first'
  alias la='eza -lah --group-directories-first'
  alias lt='eza --tree --level=2 --group-directories-first'
fi
if (( $+commands[bat] )); then
  alias bat='bat --style=plain --paging=auto'
fi
