# Purpose

This git repository is a template for *client repositories* which allow managing source code outside of the echronos RTOS repository.


# Repository Setup


## `core` submodule

This git repository is a *client repository* of the RTOS core git repository that contains the main, or *core*, RTOS code.
To use this repository, you need to set up the RTOS core repository as the git submodule called `core` first.
Follow these steps:

# Run the command `git submodule init`.

# Replace `breakaway_ci` with your own user name in the file `.git/config`.
  This file contains the URL of the RTOS repository, but you need to configure your own user name to successfully log in to the  RTOS core git server.
  You require a personal, dedicated account on that git server.
  If unsure, please contact the administrators of the git server.

# Run the command `git submodule update`.

This clones the core RTOS repository into the sub-directory `core` which git treats as a submodule.
For further information on git submodules, please refer to the man page of `git-submodule` or the excellent Git book.

When working with this repository, note that git does not automatically update the core submodule, e.g., when switching branches.
One can check the status of the core module via `git status` and update it if necessary via `git submodule update`.
