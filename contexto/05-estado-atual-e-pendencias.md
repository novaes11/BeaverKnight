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
| B01 | 🐞 | `play_sfx` não tem `return` dentro do laço: o som é tocado em **todos** os canais livres e depois ainda no canal 0 (o `play_sfx_2d` tem o `return` correto). Efeitos ficam mais altos/duplicados. | `Scripts/World/audio_manager.gd` | A validar |
| B02 | 🐞 | `audio/buses/default_bus_layout=""` no `project.godot`: o `Bus_DeControle.tres` pode não estar sendo carregado, e os barramentos `Music`/`Effect` podem não existir em tempo de execução (o áudio cai no Master). | `project.godot`, `Sounds/Bus_DeControle.tres` | A validar |
| B03 | 🐞 | O inimigo possui um nó `Camera2D` na cena; pode competir com a câmera do Player. | `Scene/inimigo.tscn` | A validar |
| B04 | 🐞 | Inimigos ignoram a lógica de terreno (água/vegetação/construções) e podem atravessar áreas que o Player não atravessa. | `Scripts/Character/Enemy/inimigo.gd` | A validar |
| B08 | 🐞 | Origens do Player e do inimigo no canto superior esquerdo dos sprites: o inimigo persegue o "canto" do Player e o alcance do ataque (12/28 px) é medido entre cantos, não entre corpos. | `player.gd`, `inimigo.gd`, `inimigo.tscn` | A validar |
| B06 | 🐞 | Se o Player morrer/respawnar durante o ataque, depende da track de animação para liberar o movimento; risco de ficar travado se a animação for interrompida. | `player.gd`, animação `attack_armed` | A validar |

## Funcionalidades faltando

| ID | Tipo | Descrição | Status |
| :-: | :-: | :--- | :--- |
| F01 | ✨ | Knockback: `apply_knockback()` existe no inimigo mas o Player nunca o chama. | A validar |
| F02 | ✨ | HUD: não há barra de vida do Player nem indicação de dano. | A validar |
| F03 | ✨ | Feedback visual de dano/morte (piscar, animação de morte) para Player e inimigos. | A validar |
| F04 | ✨ | Inimigo não tem animação de ataque própria (usa `slime`). | A validar |
| F05 | ✨ | Tela de Game Over / pausa / retorno ao menu. | A validar |
| F06 | ✨ | Objetivo/progressão do jogo (missões ambientais, contagem de inimigos, condição de vitória). | A validar |

## Limpeza / organização

| ID | Tipo | Descrição | Status |
| :-: | :-: | :--- | :--- |
| L01 | 🧹 | `enemy_movement.gd` é um protótipo não referenciado por nenhuma cena. Decidir: remover ou integrar. | A validar |
| L02 | 🧹 | `src/movimentação.cs` é legado em C# e não faz parte do jogo. | A validar |
| L03 | 🧹 | `TODO.md` contém um texto sem relação com o projeto ("Original state restored..."). | A validar |
| L04 | 🧹 | `Scene/player.tscn` existe, mas `town.tscn` tem o Player embutido; duas fontes de verdade do Player. É a única cena que usa `Assets/Player/Male_Spritesheet.png`. | A validar |
| L05 | 🧹 | Diversos `print()` de debug em `player.gd` e `inimigo.gd`. | A validar |
| L06 | 🧹 | `project.godot` com mudança local `4.6 → 4.7` em `config/features` (feita pelo editor). Definir a versão oficial da equipe. | A validar |
| L08 | 🧹 | `README.md` e links para o GitHub em `docs/index.html` ainda citam `beaverSprite.png` e `custom/slash_128.png`, removidos do jogo. | Confirmado |

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
| L07 | Sprites antigos do castor sem uso removidos | [limpeza](implementacoes/2026-11-22-remove-sprites-antigos-castor.md) |
| B10 | 6 erros `blend_points_used = 0` ao carregar a cidade → BlendSpace2D do Player com `auto_triangles` padrão | [correção](implementacoes/2026-11-22-corrige-blendspace-player.md) |
| B09 | Erros de console do walk (`travel("walk")` no slime sem esse estado) + `hframes/vframes < 1` | [integração](implementacoes/2026-11-22-integracao-sprite-sheet-player.md) |
