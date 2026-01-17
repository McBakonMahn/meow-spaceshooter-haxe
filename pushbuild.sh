#!/bin/bash
git add -f export/html5/bin
git commit -m "Build update: $(date)"
git push origin `git subtree split --prefix export/html5/bin source`:refs/heads/htmlbin --force
git reset --soft HEAD~1
git rm -r --cached export/html5/bin
