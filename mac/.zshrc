# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

eval "$(zoxide init zsh)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!**/.git/*"'
export FZF_DEFAULT_OPTS="
    --height 80% --reverse --border=sharp --margin=0,1
    --prompt='☆ ' --color=light
"

# for finding files in current directories
export FZF_CTRL_T_COMMAND='rg --files --hidden --follow --glob "!**/.git/*"'
export FZF_CTRL_T_OPTS="
    --preview 'bat --color=always --style=header,grid {}'
    --preview-window=right:60%
"

# Customize to your needs...

# ctrl + r : コマンド履歴
function peco-history-selection() {
    BUFFER=$(history 1 | sort -k1,1nr | perl -ne 'BEGIN { my @lines = (); } s/^\s*\d+\*?\s*//; $in=$_; if (!(grep {$in eq $_} @lines)) { push(@lines, $in); print $in; }' | peco --query "$LBUFFER")
    CURSOR=${#BUFFER}
    zle reset-prompt
}
zle -N peco-history-selection
bindkey '^R' peco-history-selection

# ctrl + f : 過去に移動したことのあるディレクトリを選択できるようにする。
if [[ -n $(echo ${^fpath}/chpwd_recent_dirs(N)) && -n $(echo ${^fpath}/cdr(N)) ]]; then
    autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
    add-zsh-hook chpwd chpwd_recent_dirs
    zstyle ':completion:*' recent-dirs-insert both
    zstyle ':chpwd:*' recent-dirs-default true
    zstyle ':chpwd:*' recent-dirs-max 1000
    zstyle ':chpwd:*' recent-dirs-file "$HOME/.cache/chpwd-recent-dirs"
fi
function peco-cdr () {
    local selected_dir="$(cdr -l | sed 's/^[0-9]* *//' | peco --prompt="cdr >" --query "$LBUFFER")"
    if [ -n "$selected_dir" ]; then
        BUFFER="cd ${selected_dir}"
        zle accept-line
    fi
}
zle -N peco-cdr
bindkey '^f' peco-cdr

# ctrl + g :  peco + ghq
function peco-ghq () {
  local selected_dir=$(ghq list -p | peco --query "$LBUFFER")
  if [ -n "$selected_dir" ]; then
    BUFFER="cd ${selected_dir}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-ghq
bindkey '^g' peco-ghq

# ctrl + O : open git repository
function open-git-remote() {
  git rev-parse --git-dir >/dev/null 2>&1
  if [[ $? == 0 ]]; then
    git config --get remote.origin.url | sed -e 's/git@github.com:/https:\/\/github.com\//g' | xargs open
  else
    echo ".git not found.\n"
  fi
}
zle -N open-git-remote
bindkey '^O' open-git-remote

# fd - cd to selected directory
# https://qiita.com/kamykn/items/aa9920f07487559c0c7e
fd() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
}

# プロセスをkill
fkill() {
  local pid
  pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')

  if [ "x$pid" != "x" ]
  then
    echo $pid | xargs kill -${1:-9}
  fi
}

# fs - switch git branch including remote branches
# ref: https://qiita.com/kamykn/items/aa9920f07487559c0c7e
fs() {
  local branches branch
  branches=$(git branch -a --sort=-authordate | grep -v -e '->' -e '*' | perl -pe 's/^\h+//g' | perl -pe 's#^remotes/origin/##' | perl -nle 'print if !$c{$_}++') &&
  branch=$(echo "$branches" | fzf +m) &&
  git switch "$branch"
}

# flog - git commit browser
# ref: https://qiita.com/kamykn/items/aa9920f07487559c0c7e
flog() {
  git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(#C0C0C0)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
      --bind "ctrl-m:execute:
              (grep -o '[a-f0-9]\{7\}' | head -1 |
              xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
              {}
              FZF-EOF
              "
}

# fad: git add / -p をインタラクティブに．Ctrl-p で -p, Enter で add
# https://qiita.com/reviry/items/e798da034955c2af84c5
fad() {
  local out q n addfiles
  while out=$(
      git status --short |
      awk '{if (substr($0,2,1) !~ / /) print $2}' |
      fzf-tmux --multi --exit-0 --expect=ctrl-p); do
    q=$(head -1 <<< "$out")
    n=$[$(wc -l <<< "$out") - 1]
    addfiles=(`echo $(tail "-$n" <<< "$out")`)
    [[ -z "$addfiles" ]] && continue
    if [ "$q" = ctrl-p ]; then
      git add -p $addfiles
    else
      git add $addfiles
    fi
  done
}

# fzfでdockerコンテナに入る
# ref: https://momozo.tech/2021/03/10/fzf%E3%81%A7zsh%E3%82%BF%E3%83%BC%E3%83%9F%E3%83%8A%E3%83%AB%E4%BD%9C%E6%A5%AD%E3%82%92%E5%8A%B9%E7%8E%87%E5%8C%96/
fde() {
  local cid
  cid=$(docker ps | sed 1d | fzf -q "$1" | awk '{print $1}')
  [ -n "$cid" ] && docker exec -it "$cid" /bin/bash
}

# fzfでdockerのログを取得
# ref: https://momozo.tech/2021/03/10/fzf%E3%81%A7zsh%E3%82%BF%E3%83%BC%E3%83%9F%E3%83%8A%E3%83%AB%E4%BD%9C%E6%A5%AD%E3%82%92%E5%8A%B9%E7%8E%87%E5%8C%96/
fdl() {
  local cid
  cid=$(docker ps -a | sed 1d | fzf -q "$1" | awk '{print $1}')
  [ -n "$cid" ] && docker logs -f --tail=200 "$cid"
}

alias date='gdate'
alias cp='/opt/homebrew/bin/gcp'
alias sed='/opt/homebrew/bin/gsed'
alias sleep='gsleep'
alias sll='silicon --from-clipboard --to-clipboard -l'
alias kc='kubectl'
one-login() {
  onelogin-aws-login -C "$1" --profile "$1"
  awsctx use-context -p "$1"
}

alias dcud='docker compose up -d --build'
alias dcd='docker compose down'
alias dcr='docker compose restart'
alias drmca='docker rm `docker ps -f "status=exited" -q`'
alias drmia='docker rmi `docker images -q`'
drmi() {
  local cid
  cid=$(docker images | sed 1d | fzf -m -q "$1" | awk '{print $3}')
  [ -n "$cid" ] && echo $cid | xargs docker rmi -f
}

alias gap='git add -p'
alias gbd='git branch -D'
alias gc='git checkout'
alias gcb='git switch -c'
alias gp='git pull --prune'
alias gpff='(){git fetch origin $1 | git reset --hard origin/$1}'
alias gpush='git push -u origin HEAD'
alias gca='git commit --amend --no-edit'
alias gss='git stash save'
alias gsa='git stash apply'
alias glog='git log --oneline --decorate --graph --all'
alias del_branch='git branch --all | grep -vE "develop|development|staging|master|main|remotes" | xargs -I % git branch -D %'
alias git_reset='git reset --soft HEAD~ && git reset HEAD'
gcom() {
  echo $@ | xargs -I % git commit -S -m "%"
}
pc() { # switch git branch
  git branch -a --sort=-authordate |
    grep -v -e '->' -e '*' |
    perl -pe 's/^\h+//g' |
    perl -pe 's#^remotes/origin/##' |
    perl -nle 'print if !$c{$_}++' |
    peco |
    xargs git switch
}

# terraform
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform

# aws cli aut complete
complete -C '/usr/local/bin/aws_completer' aws

# python
export PATH=$PATH:$HOME/Library/Python/3.9/bin
eval "$(pyenv init -)"

# go
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# nodejs
export PATH=/opt/homebrew/var/nodebrew/current/bin:$PATH

# brew
export HOMEBREW_NO_AUTO_UPDATE=1

# rust
export PATH=$PATH:$HOME/.cargo/bin

# pnpm
export PNPM_HOME="/Users/shuto.uchida/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"
# pnpm end

# openssl
export PATH="/opt/homebrew/opt/openssl@3/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/openssl@3/lib"
export CPPFLAGS="-I/opt/homebrew/opt/openssl@3/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/openssl@3/lib/pkgconfig"
export GRPC_PYTHON_BUILD_SYSTEM_OPENSSL=1
export GRPC_PYTHON_BUILD_SYSTEM_ZLIB=1
export PATH="$HOME/bin:$PATH"

# gh
eval "$(gh completion -s zsh)"
