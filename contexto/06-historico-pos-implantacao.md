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
| 2026-11-22 | fix | BlendSpace2D do Player sem triângulos fixos: fim dos 6 erros `blend_points_used = 0` ao carregar a cidade | B10 | [implementação](implementacoes/2026-11-22-corrige-blendspace-player.md) | `3ec039a` |
| 2026-11-22 | fix | Inimigo só viaja para estados existentes da AnimationTree: fim dos erros `walk is not found` / `states.has(travel)` | B09 | [implementação](implementacoes/2026-11-22-integracao-sprite-sheet-player.md) | `6ec1c82` |
| 2026-11-22 | feat | Player usa o novo sprite sheet (origem nos pés, colisão 14×8, som de passo, teste headless). Some o erro de hframes/vframes | F07, B05, B07 | [implementação](implementacoes/2026-11-22-integracao-sprite-sheet-player.md) | `c73dac6` |
| 2026-11-22 | feat | Novo sprite sheet do BeaverKnight estilo GBA (idle, walk e attack em 3 direções) + script gerador. Ainda não integrado ao jogo | — | [implementação](implementacoes/2026-11-22-sprite-sheet-beaver-knight.md) | `40fee7d` |
| 2026-11-22 | chore | Criação da pasta `contexto/` com regras de atuação, padrão de commits, visão geral, arquitetura, pendências e modelos | — | — | |
