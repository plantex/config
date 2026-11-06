---
name: handoff
description: >-
  Ouvre une nouvelle session Claude Code interactive, dans une fenêtre sway à part,
  dans le répertoire voulu, et lui injecte un prompt de départ. Déclencher quand
  l'utilisateur veut lancer une autre conversation sur un autre sujet ou passer la
  main à une session neuve, par exemple : « ouvre une session claude pour STO-132 »,
  « lance une conversation sur ça dans le repo X », « fais un handoff vers une
  nouvelle session », « forke ce sujet », « fais ça dans une autre session », ou
  quand il invoque /handoff. « Forker » veut dire ici une session que
  l'utilisateur pilote dans sa propre fenêtre, pas un sous-agent en arrière-plan.
---

# handoff

Script `~/.local/bin/claude-open` (source : `~/config`, `home/local/bin/`).

```bash
claude-open <répertoire> <fichier-prompt> [nom-de-session]
```

## Contraintes sur les arguments

- Aucun des trois ne doit contenir `,`, `;` ou `'`. Ils passent par `swaymsg exec`, qui coupe sur `,` et `;`, et sont mis entre `'`. Le script refuse ces valeurs.
- Le prompt reste dans son fichier et peut donc contenir n'importe quel caractère. Ne jamais le mettre en argument.
- Le répertoire doit exister. Pour du code, c'est un worktree dédié (cf. CLAUDE.md), qu'il faut créer avant l'appel.
- Le nom de session reste court et sans espace : `sto-132`, pas une phrase.

## Contenu à transmettre

- `/tmp/claude-handoffs/<sujet>-prompt.md` : la consigne de départ. Elle n'est lue qu'au lancement, donc `/tmp`, vidé au reboot, suffit. Ne pas la mettre dans le scratchpad, propre à la session qui écrit. Elle peut commencer par un skill (`/start-ticket STO-XX`) et renvoyer au handoff.
- `~/shadow/handoffs/<sujet>.md` (facultatif) : le handoff, c'est-à-dire l'état durable, l'environnement déjà monté, les découvertes et les pièges. Il doit survivre à une reprise de session, d'où son emplacement hors de `/tmp`. Il ne contient que ce que la nouvelle session ne peut pas retrouver seule (ticket, code, git).

Quand il y a un handoff, le prompt confie son nettoyage à la nouvelle session : « Quand le sujet est clos (MR mergée, ticket terminé), propose de supprimer `~/shadow/handoffs/<sujet>.md`. » Le déclencheur est la clôture du sujet, pas la fin de la session, puisque le handoff sert aux reprises. Ce n'est pas une garantie, car la session peut être fermée avant.

Le prompt démarre une session **interactive**, pas `claude -p`. Elle reste ouverte pour l'utilisateur.

## Après l'appel

Le script rend la main tout de suite et n'affiche rien en cas de succès. Pour vérifier que la fenêtre s'est ouverte :

```bash
swaymsg -t get_tree | jq -r '.. | select(.app_id? == "Alacritty") | .name'
```
