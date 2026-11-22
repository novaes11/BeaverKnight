# 05 — Estado Atual e Pendências

> Levantamento inicial feito pela leitura do código em 22/11/2026 (branch `feature/implantacaoFinal`, base `ebea2a2`).
> **Os itens abaixo precisam ser validados pelo usuário** — alguns são suspeitas, não bugs confirmados no jogo.
> Ao resolver um item, movê-lo para "Resolvidos" com o link para o arquivo em `implementacoes/`.

## Legenda

- **Tipo:** 🐞 bug · ✨ funcionalidade faltando · 🧹 limpeza/organização
- **Status:** `A validar` (levantado pelo Claude) · `Confirmado` (usuário confirmou) · `Em plano` · `Resolvido`

## Bugs suspeitos

| ID | Tipo | Descrição | Onde | Status |
| :-: | :-: | :--- | :--- | :--- |

## Funcionalidades faltando

| ID | Tipo | Descrição | Status |
| :-: | :-: | :--- | :--- |
| F04 | ✨ | Inimigo não tem animação de ataque própria (usa `slime`). | A validar |

## Limpeza / organização

| ID | Tipo | Descrição | Status |
| :-: | :-: | :--- | :--- |
| L01 | 🧹 | `enemy_movement.gd` é um protótipo não referenciado por nenhuma cena. Decidir: remover ou integrar. | A validar |
| L02 | 🧹 | `src/movimentação.cs` é legado em C# e não faz parte do jogo. | A validar |
| L04 | 🧹 | `Scene/player.tscn` existe, mas `town.tscn` tem o Player embutido; duas fontes de verdade do Player. É a única cena que usa `Assets/Player/Male_Spritesheet.png`. | A validar |
| L06 | 🧹 | `project.godot` com mudança local `4.6 → 4.7` em `config/features` (feita pelo editor). Definir a versão oficial da equipe. | A validar |

## Itens adicionados pelo usuário

_(O usuário pode listar aqui bugs e funcionalidades que conhece e que não aparecem acima.)_

| ID | Tipo | Descrição | Status |
| :-: | :-: | :--- | :--- |
| | | | |

## Resolvidos

| ID | Descrição | Implementação |
| :-: | :--- | :--- |
| F07 | Novo sprite sheet integrado nas animações do Player | [integração](implementacoes/2026-11-22-integracao-sprite-sheet-player.md) |
| B05 | Offset dos pés fixo `(30, 41)` → `pe_offset` / `distancia_sonda` exportados, origem nos pés | [integração](implementacoes/2026-11-22-integracao-sprite-sheet-player.md) |
| B07 | Som de passo não era chamado → `tocar_SFXPasso` nas `walk_*` | [integração](implementacoes/2026-11-22-integracao-sprite-sheet-player.md) |
| F09 | Exportação HTML5/Web em `docs/jogo/` com Jogar Agora na Landing Page | [implementação](implementacoes/2026-11-22-gameplay-rejogavel-boss-web.md) |
| F08 | Boss de Petróleo com pancada, cuspe, fúria e condição de vitória | [implementação](implementacoes/2026-11-22-gameplay-rejogavel-boss-web.md) |
| F06 | Objetivos em etapas e ciclo de partidas rejogável | [implementação](implementacoes/2026-11-22-gameplay-rejogavel-boss-web.md) |
| F05 | Telas de vitória, derrota, jogar novamente e menu | [implementação](implementacoes/2026-11-22-gameplay-rejogavel-boss-web.md) |
| F03 | Feedback visual de dano e morte | [implementação](implementacoes/2026-11-22-gameplay-rejogavel-boss-web.md) |
| F02 | HUD de vida, objetivo e barras nos inimigos | [implementação](implementacoes/2026-11-22-gameplay-rejogavel-boss-web.md) |
| B06 | Jogador não fica mais travado se o ataque for interrompido | [implementação](implementacoes/2026-11-22-gameplay-rejogavel-boss-web.md) |
| B02 | Layout de barramentos de áudio ativado | [implementação](implementacoes/2026-11-22-gameplay-rejogavel-boss-web.md) |
| B01 | `play_sfx` tocava em vários canais; volumes recalibrados | [implementação](implementacoes/2026-11-22-gameplay-rejogavel-boss-web.md) |
| L09 | Arquivo temporário `town.tscn562209570.tmp` removido | [implementação](implementacoes/2026-11-22-gameplay-rejogavel-boss-web.md) |
| L05 | `print()` de debug removidos do Player e do inimigo | [implementação](implementacoes/2026-11-22-gameplay-rejogavel-boss-web.md) |
| L03 | `TODO.md` agora aponta para as pendências | [implementação](implementacoes/2026-11-22-gameplay-rejogavel-boss-web.md) |
| B11 | Escada e ponte de madeira bloqueadas pela física da margem | [implementação](implementacoes/2026-11-22-colisoes-mapa-ia-spawn.md) |
| B12 | Jogador saía do mapa e andava pelos planaltos | [implementação](implementacoes/2026-11-22-colisoes-mapa-ia-spawn.md) |
| B13 | Spawn em paredes e áreas isoladas → zonas de combate validadas | [implementação](implementacoes/2026-11-22-colisoes-mapa-ia-spawn.md) |
| B04 | Inimigos sem pathfinding → navegação A* e estados | [implementação](implementacoes/2026-11-22-colisoes-mapa-ia-spawn.md) |
| B08 | Origem do inimigo no canto do sprite | [implementação](implementacoes/2026-11-22-colisoes-mapa-ia-spawn.md) |
| B03 | `Camera2D` sobrando no inimigo | [implementação](implementacoes/2026-11-22-colisoes-mapa-ia-spawn.md) |
| F01 | Knockback ligado ao golpe do jogador | [implementação](implementacoes/2026-11-22-colisoes-mapa-ia-spawn.md) |
| L08 | Links do README e da Landing Page para sprites removidos agora apontam para o commit `ebea2a2` | [limpeza](implementacoes/2026-11-22-remove-sprites-antigos-castor.md) |
| L07 | Sprites antigos do castor sem uso removidos | [limpeza](implementacoes/2026-11-22-remove-sprites-antigos-castor.md) |
| B10 | 6 erros `blend_points_used = 0` ao carregar a cidade → BlendSpace2D do Player com `auto_triangles` padrão | [correção](implementacoes/2026-11-22-corrige-blendspace-player.md) |
| B09 | Erros de console do walk (`travel("walk")` no slime sem esse estado) + `hframes/vframes < 1` | [integração](implementacoes/2026-11-22-integracao-sprite-sheet-player.md) |
