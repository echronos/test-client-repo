# Purpose

This git repository is a template for *client repositories* which allow managing source code outside of the echronos RTOS repository.


# Repository Setup


## `core` submodule

This git repository is a *client repository* of the RTOS core git repository that contains the main, or *core*, RTOS code.
To use this repository, you need to set up the RTOS core repository as the git submodule called `core` first.
Follow these steps:

0. Run the command `git submodule init`.

0. Optional: if you want to access the core submodule as your own github user instead of through anonymous https, set the url in `.git/config` to `git@github.com:echronos/echronos.git`.

0. Run the command `git submodule update`.

This clones the core RTOS repository into the sub-directory `core` which git treats as a submodule.
For further information on git submodules, please refer to the man page of `git-submodule` or the excellent Git book.

When working with this repository, note that git does not automatically update the core submodule, e.g., when switching branches.
One can check the status of the core module via `git status` and update it if necessary via `git submodule update`.
