# Plano: Remover sprites antigos do castor

| Campo | Valor |
| :--- | :--- |
| Data | 2026-11-22 |
| Tipo | `chore` |
| Pendência | L07 |
| Status | `Implementado` (pedido direto do usuário) |

## Objetivo

Tirar do projeto os sprites do castor que deixaram de ser usados após a integração da nova folha.

## Escopo

- **Remover:** `Sprites/standard/`, `Sprites/custom/`, `Sprites/beaverSprite.png` e `Assets/Player/Beaver Frames.png`, com os respectivos `.import`.
- **Manter:** `Sprites/beaver_knight/`, `Sprites/capanga_petroleopng.png`, os demais arquivos de `Assets/Player/`, `Scene/player.tscn` e as cópias da Landing Page em `docs/assets/images/game/`.

## Como testar

Reimportar o projeto na Godot e rodar `ferramentas/testes/teste_player_headless.gd`: não deve aparecer nenhum erro.
