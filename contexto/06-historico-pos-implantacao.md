# 06 — Histórico Pós-Implantação

Registro cronológico de tudo que foi adicionado, corrigido ou alterado **após a implantação**.

**Marco da implantação:** commit `ebea2a2` — *Merge pull request #22 (feat/modernize-pages-and-team-tasks)*, branch `main`.
Todo trabalho a partir daqui é registrado abaixo (o mais recente no topo).

## Como registrar

Ao concluir uma implementação, adicionar uma linha **no topo** da tabela:

- **Data:** AAAA-MM-DD
- **Tipo:** `fix` / `feat` / `chore` (o mesmo do commit)
- **Resumo:** uma frase do que mudou
- **Pendência:** ID de [05-estado-atual-e-pendencias.md](05-estado-atual-e-pendencias.md), se houver
- **Detalhes:** link para o arquivo em `implementacoes/`
- **Commit:** hash curto (preencher após o commit)

## Registro

| Data | Tipo | Resumo | Pendência | Detalhes | Commit |
| :--- | :--- | :--- | :-: | :--- | :--- |
| 2026-11-23 | fix | Câmera alinhada ao pixel do sprite, eliminando o tremor do castor ao andar | — | [implementação](implementacoes/2026-11-23-feedback-gameplay.md) | |
| 2026-11-23 | feat | Boss mais forte e tela de pausa | F11, F12 | [implementação](implementacoes/2026-11-23-feedback-gameplay.md) | |
| 2026-11-23 | fix | Slimes da refinaria caçam o jogador e volume da Web reforçado | B14, B15 | [implementação](implementacoes/2026-11-23-feedback-gameplay.md) | |
| 2026-11-22 | chore | Godot 4.7 oficial, Landing Page e README atualizados para o jogo atual e remoção de arquivos sem uso | L01, L02, L04, L06, L11 | [implementação](implementacoes/2026-11-22-pendencias-finais.md) | `497b8ed`, `83166f9`, `cb2d571`, `2c414ba` |
| 2026-11-22 | chore | Merge do PR #23 na `main` e publicação do jogo no GitHub Pages | F09 | [implementação](implementacoes/2026-11-22-gameplay-rejogavel-boss-web.md) | `e843871` |
| 2026-11-22 | chore | Documentação do modelo de gameplay e da build Web | — | [implementação](implementacoes/2026-11-22-gameplay-rejogavel-boss-web.md) | `0b4d285` |
| 2026-11-22 | chore | Exportação Web sem threads, build em `docs/jogo/` e botão Jogar Agora | F09, L03, L09 | [implementação](implementacoes/2026-11-22-gameplay-rejogavel-boss-web.md) | `1a1a246`, `a6eade3` |
| 2026-11-22 | feat | Boss de Petróleo com sprites, ataques, fúria e balanceamento | F08 | [implementação](implementacoes/2026-11-22-gameplay-rejogavel-boss-web.md) | `c920ce7` |
| 2026-11-22 | feat | Partida em etapas, combate, HUD, telas e ciclo rejogável | F02, F03, F05, F06 | [implementação](implementacoes/2026-11-22-gameplay-rejogavel-boss-web.md) | `0c90e4f`, `edb9dd7` |
| 2026-11-22 | fix | Áudio duplicado, barramentos, volumes e travamento ao morrer atacando | B01, B02, B06, L05 | [implementação](implementacoes/2026-11-22-gameplay-rejogavel-boss-web.md) | `32bc19f`, `0c90e4f` |
| 2026-11-22 | feat | Navegação A*, estados de IA e spawn por zonas de combate | B04, B13, F01 | [implementação](implementacoes/2026-11-22-colisoes-mapa-ia-spawn.md) | `06bf45e`, `27a82f3` |
| 2026-11-22 | fix | Escada, ponte, limites do mapa, paredes invisíveis, tanques sólidos e caverna com fade até a refinaria | B03, B08, B11, B12 | [implementação](implementacoes/2026-11-22-colisoes-mapa-ia-spawn.md) | `818876e`, `f31cf54` |
| 2026-11-22 | fix | Links do README e da Landing Page para os sprites removidos passam a apontar para o commit original `ebea2a2` | L08 | [implementação](implementacoes/2026-11-22-remove-sprites-antigos-castor.md) | `2fa1026` |
| 2026-11-22 | chore | Remoção dos sprites antigos do castor sem uso (44 arquivos) | L07 | [implementação](implementacoes/2026-11-22-remove-sprites-antigos-castor.md) | `34ba106` |
| 2026-11-22 | fix | BlendSpace2D do Player sem triângulos fixos: fim dos 6 erros `blend_points_used = 0` ao carregar a cidade | B10 | [implementação](implementacoes/2026-11-22-corrige-blendspace-player.md) | `3ec039a` |
| 2026-11-22 | fix | Inimigo só viaja para estados existentes da AnimationTree: fim dos erros `walk is not found` / `states.has(travel)` | B09 | [implementação](implementacoes/2026-11-22-integracao-sprite-sheet-player.md) | `6ec1c82` |
| 2026-11-22 | feat | Player usa o novo sprite sheet (origem nos pés, colisão 14×8, som de passo, teste headless). Some o erro de hframes/vframes | F07, B05, B07 | [implementação](implementacoes/2026-11-22-integracao-sprite-sheet-player.md) | `c73dac6` |
| 2026-11-22 | feat | Novo sprite sheet do BeaverKnight estilo GBA (idle, walk e attack em 3 direções) + script gerador. Ainda não integrado ao jogo | — | [implementação](implementacoes/2026-11-22-sprite-sheet-beaver-knight.md) | `40fee7d` |
| 2026-11-22 | chore | Criação da pasta `contexto/` com regras de atuação, padrão de commits, visão geral, arquitetura, pendências e modelos | — | — | `62aa001` |
