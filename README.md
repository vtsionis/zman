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

## Environment variables

###### `ZMAN_PLUGINS_DIR`

Points to the location of where the plugins will be installed. Defaults to `/ZMAN_DIR/plugins`. If you want to configure a custom one, make sure to set it **BEFORE** you source `/ZMAN_DIR/zman.zsh`.

## Usage

After `zman.zsh` is sourced, you will be able to use the `zman` command and its sub-commands.

For detailed information on the `zman` command as well as all available commands, run `zman help` and `zman help <command>`.

Currently supported commands:

- `help`

- `install`

- `ls`

- `purge`

- `remove`

- `update`

- `version`

---

### Other Zsh plugin managers

Let's face it. There are far better and more complex implementations of Zsh plugin managers to choose from than this one. The author highly recommends picking one from the below list, as they were the inspiration and priceless knowledge resource for this project.

- [antidote](https://github.com/mattmc3/antidote)

- [Znap](https://github.com/marlonrichert/zsh-snap)

- [zcomet](https://github.com/agkozak/zcomet)
