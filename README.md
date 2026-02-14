# Zman

`Zman` is yet another Zsh plugin manager.

## Origin story

Why another Zsh plugin manager when there are plenty of excellent options to choose from? Well, why not! This started as (and still is) a personal project to figure out the internal mechanisms of Zsh and its ecosystem. After moving away from `oh-my-zsh` and trying out a plethora of Zsh plugin managers, it was about time to create my own. A couple of hours and beers later, `Zman` was created!

*Note:* This is still more of a personal quest rather than a production-ready Zsh plugin manager. Don't shout too much at me if you find it inefficient or notice that I'm approaching things in a wrong way. **You've been warned!**

## Prerequisites

- [Zsh](https://www.zsh.org/) (duh!)

- [git](https://git-scm.com/)

## Installation

Add below lines to your `.zshrc` file, or any other configuration file that is sourced during Zsh initialization to install the latest stable version of `Zman`:

```shell
# .zshrc

# Bootstrap Zman as the plugin manager
# Update to a different installation path, if you prefer chaos.
ZMAN_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zman"

if [[ ! -f $ZMAN_DIR/zman.zsh ]]; then
  git clone --branch=stable https://github.com/vtsionis/zman.git $ZMAN_DIR
fi

source $ZMAN_DIR/zman.zsh
```

To install the latest development version, use the `master` branch.

All plugins will be installed under `$ZMAN_DIR/plugins`.

## Usage

After `zman.zsh` is sourced, you will be able to use the `zman` command and its sub-commands.

#### `zman help`

Print the help menu of `Zman`.

#### `zman load <plugin>`

Load your preferred Zsh plugins by specifying them in your `.zshrc` file, one by one.
If the plugin is missing, it will be automatically installed by Zman. The `<plugin>` should be specified as a partial URL in the form of `<author>/<plugin>`. Currently, only plugins that are hosted as a Github repository are supported. Example:

```shell
# .zshrc
...
zman load zsh-users/zsh-autosuggestions
zman load zsh-users/zsh-completions
...
```

#### `zman ls`

Display all of the installed plugins in a nice table view. The second column indicates whether the plugin is loaded or not for the current shell session.

#### `zman purge [all]`

Remove all installed plugins that are not loaded in the current Zsh session. When `all` is specified, then all installed plugins are removed regardless if they are loaded or not. This is an easy way to clean up the plugins directory and start fresh.

#### `zman update <target>`

This will start the updating process depending on the specified `<target>`.

- To update `Zman` itself:
  
  `zman update self`
  
  Note that `zman.sh` will be sourced again automatically after this update so there is no need for a manual sourcing.

- To update all installed plugins:
  
  `zman update plugins`

- Finally, to update both `Zman` and all plugins:
  
  `zman update all`

---

### Other Zsh plugin managers

Let's face it. There are far better and more complex implementations of Zsh plugin managers to choose from than this one. The author highly recommends picking one from the below list, as they were the inspiration and priceless knowledge resource for this project.

- [antidote](https://github.com/mattmc3/antidote)

- [Znap](https://github.com/marlonrichert/zsh-snap)

- [zcomet](https://github.com/agkozak/zcomet)
