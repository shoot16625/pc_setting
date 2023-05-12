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
code --list-extensions >| mac/vscode/extensions.txt # ref. https://www.travelhacks.tokyo/entry/stdout-overwrite
cp -R ~/.config/karabiner .
cp ~/.gitconfig .
```
