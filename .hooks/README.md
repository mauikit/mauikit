# Git Hooks

Git Hooks for this repository

## Installing the hooks
**Run this script from the `.hooks` directory**
```bash
for i in $(ls -I README.md); do ln -s ../../.hooks/$i ../.git/hooks/$i; done
```

# Hooks in this repository
## pre-commit
Checks if the cpp sources and headers are well formatted or not with `clang-format`.
If any of the changed files are not  well formatted, the the hook aborts the commit.