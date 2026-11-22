# Plano: Pendências finais pós-publicação

| Campo | Valor |
| :--- | :--- |
| Data | 2026-11-22 |
| Tipo | `chore` |
| Pendências | L01, L02, L04, L06, L11 |
| Status | `Implementado` (pedido direto do usuário) |

## Escopo

1. Adotar a Godot **4.7** como versão oficial em `project.godot`, README e Landing Page.
2. Trocar a arte antiga do castor na Landing Page pela folha atual.
3. Remover `enemy_movement.gd`, `src/movimentação.cs` e `Scene/player.tscn`, que não são usados.
4. Registrar no histórico o PR #23 e o último commit de documentação.

## Cuidados

- Links de evidência da equipe para arquivos removidos passam a apontar para o commit `ebea2a2`.
- `Assets/Player/Male_Spritesheet.png` fica fora da remoção, porque não estava na lista aprovada.

## Como testar

Rodar os testes headless e abrir a Landing Page.
