# Implementação: Corrigir erro `blend_points_used = 0` ao carregar a cidade

| Campo | Valor |
| :--- | :--- |
| Data | 2026-11-22 |
| Tipo | `fix` |
| Pendência | B10 |
| Plano | [`planos/2026-11-22-corrige-blendspace-player.md`](../planos/2026-11-22-corrige-blendspace-player.md) |
| Commit(s) | `3ec039a` |

## O que foi feito

Os 3 `AnimationNodeBlendSpace2D` do Player em `town.tscn` (`idle`, `walk`, `attack_armed`) deixaram de usar triângulos fixos (`auto_triangles = false` + `triangles = ...`) e voltaram ao padrão `auto_triangles = true`.

- **Causa do erro:** a Godot grava `triangles` antes dos `blend_point_*`. Ao carregar a cena, os triângulos eram montados quando ainda não havia pontos, e isso gerava 6 erros `Index p_x ... (blend_points_used = 0)`.
- **Por que não muda nada no jogo:** com `blend_mode = 1` (discreto), a animação escolhida é a do ponto mais próximo da direção, e os triângulos não são usados.

## Alterações por arquivo

| Arquivo | O que mudou |
| :--- | :--- |
| `beaver-knight-app/Scene/town.tscn` | Removidas as linhas `auto_triangles = false` e `triangles = PackedInt32Array(...)` dos 3 BlendSpace2D do Player |

## Verificação (Godot 4.7.1 headless, `ferramentas/testes/teste_player_headless.gd`)

| Erro | Antes | Depois |
| :--- | :-: | :-: |
| `Index p_x = 0 is out of bounds (blend_points_used = 0)` | 5 | **0** |
| `Index p_x = 1 is out of bounds (blend_points_used = 0)` | 1 | **0** |
| Qualquer outro `ERROR` / `SCRIPT ERROR` | 0 | **0** |

Os quadros exibidos por direção são idênticos aos do teste anterior:
- walk: 12 / 16 / 20;
- ataque: 24 / 28 / 32;
- idle: 0 / 4 / 8;
- `flip_h` na esquerda.

## Pontos de atenção

- Se alguém editar esses BlendSpaces no editor e desligar "Auto Triangles" de novo, o erro volta.
- Os BlendSpaces de movimento devem continuar em modo discreto.
