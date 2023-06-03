# pc_setting

## Applications

| App              | Note                                            |
| ---------------- | ----------------------------------------------- |
| MiddleClick      |                                                 |
| Mos              |                                                 |
| Karabiner        |                                                 |
| AltTab           |                                                 |
| RayCast          |                                                 |
| iTerm            |                                                 |
| Zsh, Prezto      |                                                 |
| Starship + zinit |                                                 |
| GPGTools         | <https://blog.katsubemakito.net/git/github-gpg> |
| Hadolint         |                                                 |

## Commands

```zsh
cd mac
cp ~/.zshrc .
cp ~/Library/Application\ Support/Code/User/settings.json vscode/
cp ~/Library/Application\ Support/Code/User/keybindings.json vscode/
code --list-extensions >| vscode/extensions.txt # ref. https://www.travelhacks.tokyo/entry/stdout-overwrite
rsync -a ~/.config/karabiner . --exclude 'automatic_backups/'
cp ~/.gitconfig .
# raycast export (Just in case, delete Clipboard History. ref. https://manual.raycast.com/core)
```
