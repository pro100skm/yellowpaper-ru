#!/usr/bin/env bash

set -e

SHA=`git rev-parse --verify HEAD`

git config user.name "$COMMIT_AUTHOR"
git config user.email "$COMMIT_AUTHOR_EMAIL"
git checkout --orphan gh-pages
git rm --cached -r .
echo "# Automatic build" > README.md
echo "Built pdf from \`$SHA\`. See https://github.com/pro100skm/yellowpaper-ru/ for details." >> README.md
echo "The generated pdf is here: https://pro100skm.github.io/yellowpaper-ru/paper.pdf" >> README.md
echo '<html><head><meta http-equiv="refresh" content="0; url=paper.pdf" /></head><body></body></html>' > index.html
mv build/Paper.pdf paper.pdf
git add -f README.md index.html paper.pdf
git commit -m "Built pdf from {$SHA}."

ENCRYPTED_KEY_VAR="encrypted_19a81de38b62_key"
ENCRYPTED_IV_VAR="encrypted_19a81de38b62_iv"
ENCRYPTED_KEY=${!ENCRYPTED_KEY_VAR}
ENCRYPTED_IV=${!ENCRYPTED_IV_VAR}
openssl aes-256-cbc -K $ENCRYPTED_KEY -iv $ENCRYPTED_IV -in deploykey.enc -out deploykey -d
chmod 600 deploykey
eval `ssh-agent -s`
ssh-add deploykey

git push -f "$PUSH_REPO" gh-pages
