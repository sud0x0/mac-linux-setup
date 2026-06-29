# IMPORTANT
#
# SAVE THIS AS .zshrc - DO NOT EXECUTE
# cp zshrc-template.sh ~/.zshrc
# source ~/.zshrc
#
# ===========================================
# GENERAL
# ===========================================
# Set Homebrew prefix
export HOMEBREW_PREFIX="/opt/homebrew"

# PATH Configuration
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/sbin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Command Aliases
alias la='eza -la --group-directories-first --color=always'
alias ls='eza -la --group-directories-first --color=always'
alias td='eza --tree --color=always'
alias rm='trash'
alias python='/usr/bin/python3'
alias pip='pip3'
alias ldev='cd "$HOME/Local_Development/"'
alias clear='printf "\ec"'

# ===========================================
# SYNTAX HIGHLIGHTING AND AUTOSUGGESTIONS
# ===========================================

if [ -f $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

if [ -f $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
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
# Shows branch name and status (clean/dirty)
git_prompt_info() {
    # Check if we're in a git repository
    git rev-parse --git-dir > /dev/null 2>&1 || return
    
    # Get current branch name
    local ref
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref=$(git rev-parse --short HEAD 2> /dev/null) || return
    local branch=${ref#refs/heads/}
    
    # Check for uncommitted changes
    local git_status=$(git status --porcelain 2> /dev/null)
    
    # Display branch with ⎇ symbol
    echo -n "%K{237}%F{white} ⎇ ${branch} %f%k"
    
    if [[ -n $git_status ]]; then
        # Dirty: red background with ...
        echo -n "%K{#f44336}%F{black}...%f%k"
    else
        # Clean: green background with ✓
        echo -n"%K{#00a152}%F{white} ✓ %f%k"
    fi
}

# Smart Path Display Function
# Shows full path if it fits, otherwise shortens intermediate directories
smart_path() {
    local dir_path="${PWD/#$HOME/~}"
    local -a path_parts
    path_parts=("${(@s:/:)dir_path}")
    
    # Get terminal width
    local term_width=${COLUMNS:-80}
    
    # Estimate prompt length
    local current_dir="${PWD##*/}"
    local estimated_prompt_length=$(( ${#USER} + ${#dir_path} + ${#current_dir} + 40 ))
    
    # Show full path if it fits
    if [[ $estimated_prompt_length -lt $term_width ]]; then
        echo "$dir_path"
        return
    fi
    
    # Otherwise, shorten intermediate directories
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
# Combines username, path, git info, and current directory
build_prompt() {
    local prompt_parts=""
    
    # Username segment (grey background)
    prompt_parts+="%K{237}%F{252} %n %f%k"
    
    # Path segment (cyan background)
    local path_display=$(smart_path)
    prompt_parts+="%K{39}%F{black} ${path_display} %f%k"
    
    # Git branch and status segment
    prompt_parts+="$(git_prompt_info)"
    
    # Current directory segment (grey background)
    local current_dir="${PWD##*/}"
    prompt_parts+="%K{237}%F{white} ${current_dir} %f%k"
    
    echo "${prompt_parts}"
}

# Main Prompt (left side with green arrow)
PROMPT='$(build_prompt)
%F{green}→%f '

# Right Prompt (shows command execution timestamp)
RPROMPT='%F{240}${_prompt_exec_timestamp}%f'

# ===========================================
# AUTOCOMPLETION
# ===========================================

# Initialize completion system
autoload -Uz compinit
compinit

# Case-insensitive completion (e.g., 'a' matches 'Applications')
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Partial path completion (e.g., '/u/lo/b' expands to '/usr/local/bin')
zstyle ':completion:*' list-suffixes
zstyle ':completion:*' expand prefix suffix

# Fuzzy matching (allows typos in completion)
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Enable menu selection for completion
zstyle ':completion:*' menu select

# Formatting for completion groups
zstyle ':completion:*:*:*:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}!- %d (errors: %e) -!%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*' group-name ''

# Colorize file and directory completions
zstyle ':completion:*' list-colors "${(s.:.)}"

# Allow completion of special directories (. and ..)
zstyle ':completion:*' special-dirs true

# Include hidden files in completion
setopt GLOB_DOTS

# Enable completion caching for faster results
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# Prevent parent directory from appearing in cd completions
zstyle ':completion:*:cd:*' ignore-parents parent pwd

# Enable AUTO_CD (type directory name to cd into it)
setopt AUTO_CD

# Automatically list choices on ambiguous completion
setopt AUTO_LIST

# Automatically use menu completion
setopt AUTO_MENU

# Move cursor to end of word after completion
setopt ALWAYS_TO_END

# Allow completion from within a word
setopt COMPLETE_IN_WORD

# Disable beep on ambiguous completions
unsetopt LIST_BEEP

# ===========================================
# HISTORY CONFIGURATION
# ===========================================

# History file location and size
HISTFILE=~/.zsh_history
HISTSIZE=10000              # Number of commands to keep in memory
SAVEHIST=10000              # Number of commands to save to file

# History behavior options
setopt HIST_IGNORE_ALL_DUPS # Remove older duplicate entries from history
setopt HIST_IGNORE_SPACE    # Don't save commands that start with a space
setopt HIST_REDUCE_BLANKS   # Remove superfluous blanks from history
setopt HIST_VERIFY          # Show command with history expansion before running
setopt SHARE_HISTORY        # Share history between all sessions
setopt APPEND_HISTORY       # Append to history file instead of replacing
setopt INC_APPEND_HISTORY   # Write to history file immediately, not on exit
setopt HIST_SAVE_NO_DUPS    # Don't write duplicate entries to history file
setopt HIST_FIND_NO_DUPS    # Don't show duplicates when searching history
