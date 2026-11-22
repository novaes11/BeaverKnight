# Implementação: Pendências finais pós-publicação

| Campo | Valor |
| :--- | :--- |
| Data | 2026-11-22 |
| Tipo | `chore` |
| Pendências | L01, L02, L04, L06, L11 |
| Plano | [`planos/2026-11-22-pendencias-finais.md`](../planos/2026-11-22-pendencias-finais.md) |
| Commit(s) | `497b8ed`, `83166f9`, `cb2d571`, `2c414ba` |

## O que foi feito

- **Versão:** Godot 4.7 em `project.godot`, README, Landing Page e contexto.
- **Landing Page:** o card do Cavaleiro Castor e o slide de ataque usam imagens geradas da folha atual (`beaver_knight_poses.png` e `beaver_knight_ataque.png`).
- **Removidos:** `Scripts/Character/Enemy/enemy_movement.gd` (+ `.uid`), `src/movimentação.cs` e `Scene/player.tscn`.
- **Links:** as evidências de `enemy_movement.gd` apontam para o commit `ebea2a2`, preservando o histórico do trabalho da equipe.
- **Histórico:** registrados o PR #23 e o commit de documentação `0b4d285`.
- **Landing Page e README (L11):** textos reescritos para o jogo atual (objetivo, etapas, IA, boss, HUD, ciclo e Web), novas capturas reais, card e slides do Boss de Petróleo e remoção das menções a capangas como inimigos, reflorestamento e áreas desmatadas.
- **Autoria:** as atribuições da equipe foram mantidas; arte e protótipos antigos aparecem como versão histórica.

## Verificação

Testes de mapa, partida e jogador sem erros. Landing Page conferida em 375, 1024 e 1440 px, sem imagens quebradas nem estouro horizontal.

## Pontos de atenção

- `Assets/Player/Male_Spritesheet.png` ficou sem uso depois da remoção de `player.tscn` (pendência L10).
- O vídeo antigo `docs/assets/video/beaver_knight base design.mp4` e as artes antigas continuam no repositório, mas não aparecem mais na Landing Page.
- A build em `docs/jogo/` não precisou ser refeita: os arquivos removidos já estavam fora do preset de exportação.
