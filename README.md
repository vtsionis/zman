# Zman

`Zman` is yet another Zsh plugin manager.

## Origin story

Why another Zsh plugin manager when there are plenty of excellent options to choose from? Well, why not! This started as (and still is) a personal project to figure out the internal mechanisms of Zsh and its ecosystem. After moving away from `oh-my-zsh` and trying out a plethora of Zsh plugin managers, it was about time to try and create my own. A couple of hours and beers later, `Zman` was created!

*Note:* This is still more of a personal quest rather than a production-ready Zsh plugin manager. Don't shout too much at me if you find it inefficient or notice that I'm approaching things in a wrong way. **You've been warned!**

## Installation

Add below lines to your `.zshrc` file, or any other configuration file that is sourced during Zsh initialization:

```shell
# .zshrc

# Bootstrap Zman as the plugin manager
export ZMAN_DIR="/path/to/zman"

if [[ ! -f $ZMAN_DIR/zman.zsh ]]; then
  git clone https://github.com/vtsionis/zman.git $ZMAN_DIR
fi

source $ZMAN_DIR/zman.zsh
```

Since I try to follow the [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html), my preferred `ZMAN_DIR` would be:

```shell
export ZMAN_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zman/zman.zsh"
```

For the installation of plugins, `Zman` will use one of the below paths:

- If `$XDG_DATA_HOME` is defined:
  
  - `$XDG_DATA_HOME/zman/plugins`

- else:
  
  - `$HOME/.local/share/zman/plugins`

You can override this behavior by setting the `ZMAN_PLUGINS` environment variable in your `.zshrc`file, before sourcing `zman.zsh`:

```shell
# .zshrc

...
export ZMAN_PLUGINS="/Path/to/zman/plugins"

source $ZMAN_DIR/zman.zsh
...
```

## Usage

After `zman.zsh` is sourced, then you will gain access to the `zman` command and its sub-commands.

#### `zman help`

Print the help menu of `Zman`.

```shell
% zman help
Usage:
  zman [subcommand] [plugin]

Subcommands:
  help        Print this menu
  load        Optionally install and load the provided plugin
  list        List all installed plugins
  update      When no plugin is provided, update Zman itself, else
              update the corresponding plugin. The special plugin name "all"
              will trigger the update of all installed plugins
  purge       When no plugin is provided, Zman will uninstall all of
              the installed plugins that are not loaded, else it will
              only uninstall the provided plugin
```

#### `zman load`

After `zman.zsh` is sourced, load your preferred Zsh plugins by specifying them in your `.zshrc` file. Example:

```shell
# .zshrc
...
zman load zsh-users/zsh-autosuggestions
zmam load zsh-users/zsh-completions
...
```

`load` is responsible for two things. First, in case the plugin is not already present, it will install it. Second, it will load the plugin making it available in your shell session. Do note that currently, only partial Git urls in the form of `<author>/<plugin>` are supported.

#### `zman list`

Get a list of all installed and loaded plugins. Installed plugins that are not loaded will be grayed out in the list. Example:

![zman-list](https://github.com/vtsionis/zman/assets/101921146/3b66403a-6b18-490b-947d-0086634db040)

#### `zman update`

TODO

#### `zman purge`

TODO

---

### Other Zsh plugin managers

Let's face it. There are far better and more complex implementations of Zsh plugin managers to choose from than this one. The author highly recommends picking one from the below list, as they were the inspiration and priceless knowledge resource for this project.

- [antidote](https://github.com/mattmc3/antidote)

- [Znap](https://github.com/marlonrichert/zsh-snap)

- [zcomet](https://github.com/agkozak/zcomet)
