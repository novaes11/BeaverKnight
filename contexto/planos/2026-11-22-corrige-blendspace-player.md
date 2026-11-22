# Plano: Corrigir erro `blend_points_used = 0` ao carregar a cidade

| Campo | Valor |
| :--- | :--- |
| Data | 2026-11-22 |
| Tipo | `fix` |
| Pendência | B10 |
| Status | `Implementado` (aprovado pelo usuário: "Corrigir B10 agora") |

## 1. Objetivo

Ao carregar `town.tscn` não devem mais aparecer os 6 erros `Index p_x = 0/1 is out of bounds (blend_points_used = 0)`.

## 2. Diagnóstico

- Os 3 `AnimationNodeBlendSpace2D` do Player (`idle`, `walk`, `attack_armed`) estão salvos com `auto_triangles = false` e uma lista fixa em `triangles`.
- No arquivo, `triangles` aparece **antes** dos `blend_point_*`. Ao carregar, a Godot tenta montar os triângulos quando ainda não existe nenhum ponto, e o resultado são os 6 erros (2 por BlendSpace).
- Reordenar as linhas não adianta: a Godot grava nessa mesma ordem sempre que a cena é salva, e o erro voltaria.
- Os 3 BlendSpaces usam `blend_mode = 1` (discreto). Nesse modo a Godot escolhe a animação do **ponto mais próximo** da direção, e os triângulos não influenciam o resultado.

## 3. Arquivos afetados

| Arquivo | Mudança |
| :--- | :--- |
| `beaver-knight-app/Scene/town.tscn` | Nos 3 BlendSpace2D do Player: remover `auto_triangles = false` e `triangles = ...` (volta ao padrão `auto_triangles = true`, a Godot gera os triângulos sozinha depois de carregar os pontos) |

## 4. Riscos

Nenhum na escolha da animação, porque o modo discreto não usa os triângulos. A troca de animação por direção (cima/baixo/esquerda/direita) continua igual.

## 5. Como testar

- Rodar `ferramentas/testes/teste_player_headless.gd` e conferir que não aparece nenhum `blend_points_used`.
- Conferir que os quadros por direção continuam os mesmos do teste anterior.

## 6. Commit previsto

```
fix(player): remove triângulos fixos dos BlendSpace2D do jogador
```
