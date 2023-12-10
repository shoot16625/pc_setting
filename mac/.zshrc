### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit light mollifier/anyframe
zinit light reegnz/jq-zsh-plugin
zinit light paulirish/git-open


eval "$(starship init zsh)"
eval "$(direnv hook zsh)"
# eval "$(github-copilot-cli alias -- "$0")"

autoload -U +X bashcompinit && bashcompinit
autoload -Uz compinit && compinit
if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
fi
complete -C '/opt/homebrew/bin/aws_completer' aws
complete -o nospace -C /opt/homebrew/bin/terraform terraform
eval "$(gh completion -s zsh)"
# 補完で小文字でも大文字にマッチさせる
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# 補完候補を詰めて表示
setopt list_packed
# 補完候補一覧をカラー表示
autoload colors
zstyle ':completion:*' list-colors ''
# コマンドのスペルを訂正
setopt correct
# glob表現無視
setopt +o nomatch
# History設定
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
# 同時に起動したzshの間で履歴を共有する
setopt share_history
# 重複排除
setopt hist_ignore_dups
# 履歴を追加 (毎回 .zsh_history を作るのではなく)
setopt hist_ignore_all_dups
# 履歴をインクリメンタルに追加
setopt inc_append_history
# 日本語ファイル名を表示可能にする
setopt print_eight_bit

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# command history
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

# ビープ音の停止
setopt no_beep
# ビープ音の停止(補完時)
setopt nolistbeep

# brew
export HOMEBREW_NO_AUTO_UPDATE=1
# terraform

# local
export PATH=$PATH:$HOME/.local/bin
# aqua
export PATH="$PATH:$(aqua root-dir)/bin"
# pyenv
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
# python
# export PATH=$PATH:$HOME/Library/Python/3.11/bin
# rust
export PATH=$PATH:$HOME/.cargo/bin
# go
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
# volta
export VOLTA_HOME="$HOME/.volta"
export PATH="$PATH:$VOLTA_HOME/bin"
# npm
export PATH=$PATH:`npm prefix --location=global`/bin
# php
export PATH="$PATH:/opt/homebrew/opt/php/bin"
export PATH="$PATH:/opt/homebrew/opt/php/sbin"
# bun completions
[ -s "/Users/shuto.uchida/.bun/_bun" ] && source "/Users/shuto.uchida/.bun/_bun"
# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$PATH:$BUN_INSTALL/bin:"


# Ctrl+x -> d
# peco でディレクトリの移動履歴を表示
bindkey '^xd' anyframe-widget-cdr
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs

# Ctrl+x -> r
# peco でコマンドの実行履歴を表示
bindkey '^xr' anyframe-widget-execute-history
# 上キー
bindkey '^\e[A' anyframe-widget-execute-history

# Ctrl+x -> b
# peco でGitブランチを表示して切替え
bindkey '^xb' anyframe-widget-checkout-git-branch

# Ctrl+x -> g
# GHQでクローンしたGitリポジトリを表示
bindkey '^xg' anyframe-widget-cd-ghq-repository

# Ctrl+x -> j
bindkey '^xj' jq-complete


alias ls=exa
alias cat=bat
alias date='gdate'
alias cp='/opt/homebrew/bin/gcp'
alias sed='/opt/homebrew/bin/gsed'
alias sleep='gsleep'
alias sll='silicon --from-clipboard --to-clipboard -l'
alias kc='kubectl'
alias tf='terraform'
alias awso="source _aws-easy-sso"

# docker
alias dcu='docker compose up'
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

# git
alias gap='git add -p'
alias gb='git branch'
alias gc='git checkout'
alias gsc='git switch -c'
alias gp='git pull --prune'
alias gpff='(){git fetch origin $1 | git reset --hard origin/$1}'
alias gpush='git push -u origin HEAD'
alias gca='git commit --amend --no-edit'
alias gs='git status'
alias gl='git log --oneline --graph'
alias gss='git stash save'
alias gsa='git stash apply'
alias gsp='git stash pop'
alias gopen='git open'
alias del_branch='git branch --all | grep -vE "develop|development|dev|staging|stg|deploy\/staging|deploy\/production|master|main|remotes|deploy\/demo" | xargs -I % git branch -D %'
alias git_reset='git reset --soft HEAD~ && git reset HEAD'
gcom() {
    echo $@ | xargs -I % git commit -S -m "%"
}

awsp() {
    profile=$(aws configure list-profiles | sort | fzf --reverse)
    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY
    export AWS_PROFILE=$profile
}

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

# other
alias awslocal='AWS_ACCESS_KEY_ID=dummy AWS_SECRET_ACCESS_KEY=dummy awslocal'
