# Implementação: Remover sprites antigos do castor

| Campo | Valor |
| :--- | :--- |
| Data | 2026-11-22 |
| Tipo | `chore` |
| Pendência | L07 |
| Plano | [`planos/2026-11-22-remove-sprites-antigos-castor.md`](../planos/2026-11-22-remove-sprites-antigos-castor.md) |
| Commit(s) | `34ba106` |

## O que foi feito

Foram removidos 44 arquivos (22 imagens e 22 `.import`): `Sprites/standard/`, `Sprites/custom/`, `Sprites/beaverSprite.png` e `Assets/Player/Beaver Frames.png`. Antes da remoção, os caminhos e UIDs foram procurados nas cenas, scripts e recursos, e nenhum estava em uso.

## Verificação

Godot 4.7.1 headless: `--import` e `teste_player_headless.gd` rodaram sem nenhum `ERROR` ou `SCRIPT ERROR`. Player e inimigos funcionaram normalmente.

## Pontos de atenção

- Os arquivos continuam recuperáveis pelo histórico do git.
- **L08:** o `README.md` e os links para o GitHub em `docs/index.html` ainda citam `beaverSprite.png` e `custom/slash_128.png`. As imagens exibidas na Landing Page são cópias em `docs/assets` e não foram afetadas.
- `Assets/Player/Male_Spritesheet.png` foi mantido porque ainda é usado por `Scene/player.tscn` (cena sem uso, pendência L04).
