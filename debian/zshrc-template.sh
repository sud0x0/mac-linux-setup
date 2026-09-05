# IMPORTANT
#
# SAVE THIS AS .zshrc - DO NOT EXECUTE
# cp zshrc-template.sh ~/.zshrc
# source ~/.zshrc
#
# ===========================================
# GENERAL
# ===========================================

# PATH Configuration
export PATH="$HOME/.local/bin:$PATH"

# Command Aliases
alias la='eza -la --group-directories-first --color=always'
alias ls='eza -la --group-directories-first --color=always'
alias td='eza --tree --color=always'
alias python='python3'
alias pip='pip3'
alias clear='printf "\ec"'

# ===========================================
# SYNTAX HIGHLIGHTING AND AUTOSUGGESTIONS
# ===========================================

if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# ===========================================
# THEME
# ===========================================

# Enable prompt substitution and colors
setopt PROMPT_SUBST
autoload -U colors && colors

# Theme Configuration Variables
THEME_DISPLAY_VI=no
THEME_POWERLINE_FONTS=no
THEME_NERD_FONTS=no
THEME_COLOR_SCHEME=dracula
DEFAULT_USER=$USER
PROMPT_PWD_DIR_LENGTH=1
THEME_PROJECT_DIR_LENGTH=20
THEME_AVOID_AMBIGUOUS_GLYPHS=yes

# Command Execution Timestamp Variable
typeset -g _prompt_exec_timestamp

# Hook: Capture timestamp before command execution
prompt_preexec() {
    _prompt_exec_timestamp=$(date '+%a %d %b %H:%M:%S %Y')
}

# Hook: Keep timestamp for display after command completes
prompt_precmd() {
    :
}

# Register hooks with Zsh
if (( $+functions[add-zsh-hook] )); then
    autoload -U add-zsh-hook
    add-zsh-hook preexec prompt_preexec
    add-zsh-hook precmd prompt_precmd
else
    preexec_functions+=(prompt_preexec)
    precmd_functions+=(prompt_precmd)
fi

# Git Information Display Function
git_prompt_info() {
    git rev-parse --git-dir > /dev/null 2>&1 || return

    local ref
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref=$(git rev-parse --short HEAD 2> /dev/null) || return
    local branch=${ref#refs/heads/}

    local git_status=$(git status --porcelain 2> /dev/null)

    echo -n "%K{237}%F{white} ⎇ ${branch} %f%k"

    if [[ -n $git_status ]]; then
        echo -n "%K{#f44336}%F{black}...%f%k"
    else
        echo -n "%K{#00a152}%F{white} ✓ %f%k"
    fi
}

# Smart Path Display Function
smart_path() {
    local dir_path="${PWD/#$HOME/~}"
    local -a path_parts
    path_parts=("${(@s:/:)dir_path}")

    local term_width=${COLUMNS:-80}
    local current_dir="${PWD##*/}"
    local estimated_prompt_length=$(( ${#USER} + ${#dir_path} + ${#current_dir} + 40 ))

    if [[ $estimated_prompt_length -lt $term_width ]]; then
        echo "$dir_path"
        return
    fi

    if [[ ${#path_parts[@]} -le 2 ]]; then
        echo "$dir_path"
    else
        local result=""
        for i in {1..$(( ${#path_parts[@]} - 1 ))}; do
            if [[ $i -eq 1 ]]; then
                result+="${path_parts[$i]}"
            else
                result+="/${path_parts[$i]:0:1}"
            fi
        done
        result+="/${path_parts[-1]}"
        echo "$result"
    fi
}

# Build Complete Prompt
build_prompt() {
    local prompt_parts=""

    prompt_parts+="%K{237}%F{252} %n %f%k"

    local path_display=$(smart_path)
    prompt_parts+="%K{39}%F{black} ${path_display} %f%k"

    prompt_parts+="$(git_prompt_info)"

    local current_dir="${PWD##*/}"
    prompt_parts+="%K{237}%F{white} ${current_dir} %f%k"

    echo "${prompt_parts}"
}

# Main Prompt
PROMPT='$(build_prompt)
%F{green}→%f '

# Right Prompt
RPROMPT='%F{240}${_prompt_exec_timestamp}%f'

# ===========================================
# AUTOCOMPLETION
# ===========================================

autoload -Uz compinit
compinit

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-suffixes
zstyle ':completion:*' expand prefix suffix
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric
zstyle ':completion:*' menu select
zstyle ':completion:*:*:*:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}!- %d (errors: %e) -!%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors "${(s.:.)}"
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
zstyle ':completion:*:cd:*' ignore-parents parent pwd

setopt GLOB_DOTS
setopt AUTO_CD
setopt AUTO_LIST
setopt AUTO_MENU
setopt ALWAYS_TO_END
setopt COMPLETE_IN_WORD
unsetopt LIST_BEEP

# ===========================================
# HISTORY CONFIGURATION
# ===========================================

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_SAVE_NO_DUPS
setopt HIST_FIND_NO_DUPS
