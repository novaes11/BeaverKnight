# Plano: Integrar o novo sprite sheet nas animações do Player

| Campo | Valor |
| :--- | :--- |
| Data | 2026-11-22 |
| Tipo | `feat` |
| Pendência | F07 (resolve também B05) |
| Status | `Implementado` — aguardando teste do usuário no jogo |

## 1. Objetivo

O Player em jogo passa a usar a folha aprovada `Sprites/beaver_knight/beaver_knight_sheet.png` em todas as animações (idle, walk e ataque, nas 4 direções), mantendo o funcionamento atual de movimento, ataque, colisão com o mapa e sons.

## 2. Diagnóstico (como está hoje)

Tudo está no nó `Player` embutido em `Scene/town.tscn`. O `Scene/player.tscn` separado **não** é usado pela cidade.

**Sprite2D**
- `centered = false`, `scale = (0.96, 1)`.
- Cada animação troca **textura, `hframes`, `vframes`, `offset` e `frame`**, usando 3 folhas diferentes:
  - `standard/idle.png` (13×4)
  - `standard/walk.png` (13×4)
  - `custom/halfslash_128.png` (6×4, com offset `(-32,-32)`)
- Por causa disso, a origem do Player é o **canto superior esquerdo do quadro de 64 px**, e não os pés.

**AnimationPlayer** (12 animações + `RESET`)
- `idle_*`, `walk_*` e `armed_*` (o ataque), nas direções `down/up/left/right`.
- As animações `idle_*` chamam `set_move(true)` no início, como trava de segurança.
- As `armed_*` chamam `set_move(true)` no fim (~0,6–0,75 s), o que devolve o movimento após o ataque.

**AnimationTree**
- Estados `idle`, `walk` e `attack_armed`, cada um com um BlendSpace2D apontando para as animações acima pelo **nome**.
- O ataque volta sozinho para idle/walk ao terminar.
- **Não precisa mudar.**

**Colisão e pés**
- `CollisionShape2D`: retângulo 28×42 em `(30, 41)`, cobrindo o corpo inteiro.
- `player.gd` testa o terreno em `global_position + Vector2(30, 41)`, sondando 10 px à frente. Esses números só fazem sentido para o quadro antigo (B05).

**Achados durante a análise** (fora do escopo, viram pendências novas):
- **B07:** a função `tocar_SFXPasso` existe em `player.gd`, mas **nenhuma animação a chama**, então hoje não há som de passo.
- **B08:** as origens do Player e do inimigo ficam no canto superior esquerdo dos sprites. Por isso o inimigo persegue o "canto" do Player e o alcance do ataque (12/28 px) é medido entre cantos, não entre corpos.

## 3. Arquivos afetados

| Arquivo | Mudança |
| :--- | :--- |
| `beaver-knight-app/Scene/town.tscn` | Sprite2D, CollisionShape2D, posição do Player e as 13 animações do Player (texto do `.tscn`, só no trecho do Player) |
| `beaver-knight-app/Scripts/Character/Player/player.gd` | Troca os números fixos `(30, 41)` e `10.0` por variáveis exportadas |

O AnimationTree, o TileMap, o inimigo e as demais cenas não mudam. As folhas antigas continuam no disco.

## 4. Passos de implementação

### 4.1 Sprite2D (configurado uma vez, sem trocas por animação)
- `texture` = `beaver_knight_sheet.png` (uid `uid://cqpwh4m8sm6er`, já importado pela Godot).
- `hframes = 4`, `vframes = 9`, `centered = true`, `offset = (0, -20)` → o pixel dos pés (24, 44) fica exatamente na **origem do Player**.
- Remover `scale = (0.96, 1)` e `region_rect`; manter o filtro Nearest.

### 4.2 Origem nos pés e posição na cidade
- Com a origem nos pés, o `y_sort` passa a ordenar pelo pé do personagem, que é o padrão de jogos top-down.
- Ajustar a `position` do Player em `town.tscn` para cerca de `(30, 52)`. Isso mantém o ponto de nascimento (e de respawn) praticamente no mesmo lugar do mapa. O valor fino pode ser conferido no editor.

### 4.3 Colisão (estilo GBA: caixa nos pés)
- `CollisionShape2D`: retângulo **14×8** em `(0, -4)`, cobrindo só a base do corpo.
- Assim o castor pode "passar na frente" de objetos altos sem travar pela cabeça.

### 4.4 `player.gd` (resolve B05)
- Novas variáveis: `@export var pe_offset := Vector2(0, -2)` e `@export var distancia_sonda := 8.0`.
- `feet_pos = global_position + pe_offset`, e a sonda passa a usar `distancia_sonda` no lugar de `10.0`.
- Nenhuma outra lógica muda.

### 4.5 Animações (mesmos nomes, então o AnimationTree continua funcionando)

Cada animação fica só com as tracks `Sprite2D:frame` e `Sprite2D:flip_h`, mais as tracks de método. As tracks de `texture`, `hframes`, `vframes` e `offset` são removidas.

| Animação | Quadros | Tempo por quadro | Duração | Loop | `flip_h` | Métodos |
| :--- | :--- | :-: | :-: | :-: | :-: | :--- |
| `idle_down` | 0, 1 | 0,5 s | 1,0 s | sim | não | `set_move(true)` em 0 s (mantido) |
| `idle_up` | 4, 5 | 0,5 s | 1,0 s | sim | não | idem |
| `idle_right` | 8, 9 | 0,5 s | 1,0 s | sim | não | idem |
| `idle_left` | 8, 9 | 0,5 s | 1,0 s | sim | **sim** | idem |
| `walk_down` | 12, 13, 14, 15 | 0,15 s | 0,6 s | sim | não | — |
| `walk_up` | 16, 17, 18, 19 | 0,15 s | 0,6 s | sim | não | — |
| `walk_right` | 20, 21, 22, 23 | 0,15 s | 0,6 s | sim | não | — |
| `walk_left` | 20, 21, 22, 23 | 0,15 s | 0,6 s | sim | **sim** | — |
| `armed_down` | 24, 25, 26, 27 | 0,08 / 0,14 / 0,12 / 0,1 s | 0,44 s | não | não | `set_move(true)` no fim (0,44 s) |
| `armed_up` | 28, 29, 30, 31 | idem | 0,44 s | não | não | idem |
| `armed_right` | 32, 33, 34, 35 | idem | 0,44 s | não | não | idem |
| `armed_left` | 32, 33, 34, 35 | idem | 0,44 s | não | **sim** | idem |
| `RESET` | 0 | — | — | — | não | — |

- O ataque fica mais rápido (0,44 s contra 0,6–0,9 s hoje). Se preferir o ritmo antigo, basta aumentar os tempos.
- O dano continua sendo aplicado no momento do clique, como hoje: a lógica de combate não muda neste plano.

### 4.6 Forma de edição
O Claude edita o texto do `town.tscn` **apenas** nos blocos do Player: as 13 sub-resources `Animation`, o `RectangleShape2D` do Player e os nós `Player`, `Sprite2D` e `CollisionShape2D`.
- As referências às 3 texturas antigas saem da cena.
- A Godot reorganiza ids/uids na próxima vez que a cena for salva, o que é normal.
- Como a Godot não está disponível no terminal, **a validação final é sua, abrindo o projeto**.

## 5. Riscos e impactos

- **Tamanho na tela:** o castor novo tem ~24 px de altura, contra ~45 px do sprite atual. Ele vai parecer menor na cidade, mas proporcional aos tiles de 16 px, como no GBA.
- **Colisão menor:** ele se aproxima mais de casas e árvores com colisor físico. A colisão com água e caminhos continua por código (só muda o ponto dos pés).
- **Combate:** como a origem do Player muda para os pés, a distância até o inimigo muda. O ataque pode passar a acertar mais ou menos que hoje. O ajuste fino fica para B08, se você aprovar depois.
- **Edição de `.tscn` por texto:** se a Godot reclamar ao abrir, o `git` permite voltar o arquivo exatamente ao estado anterior (`git checkout -- beaver-knight-app/Scene/town.tscn`).

## 6. Como testar no jogo

1. Abrir o projeto na Godot e conferir se a cena `town.tscn` abre sem erros.
2. Rodar (`F5`) e entrar no jogo pelo menu.
3. Ficar parado em cada direção: deve aparecer o idle de 2 quadros, com a esquerda espelhada.
4. Andar nas 4 direções e nas diagonais: ciclo de 4 quadros na direção certa.
5. Atacar nas 4 direções:
   - a animação com rastro deve tocar;
   - o movimento deve voltar ao fim;
   - o ataque ainda deve acertar um inimigo próximo.
6. Encostar na água sem ponte (deve parar na margem), atravessar uma ponte, encostar em casas e vegetação.
7. Morrer e conferir que o respawn acontece no ponto inicial.

## 7. Commit previsto

```
feat(player): integra novo sprite sheet do BeaverKnight nas animações do jogador
```

Corpo listando: troca das animações, origem nos pés, nova colisão e variáveis `pe_offset`/`distancia_sonda` (B05).

## 8. Validação do usuário

- [x] Plano aprovado pelo usuário (2026-11-22)
- Decisões do usuário:
  - Ritmo do ataque: a critério do Claude, o que encaixar melhor com os sprites → mantido **0,44 s**.
  - Som de passo (B07): **incluir**. Track de método `tocar_SFXPasso` nas `walk_*`, nos quadros de passo (0 s e 0,3 s).
- Correção adicional pedida: os erros de console do walk (`_make_travel_path: ... states.has(travel)`, `No such node: 'walk'`, `get_node: walk is not found current state`) e `Amount of hframes/vframes cannot be smaller than 1` não podem mais ocorrer.
  - **Causa dos erros de `walk`:** vêm do **inimigo**. O `AnimationNodeStateMachine` de `inimigo.tscn` só tem o estado `slime`, mas `inimigo.gd` chama `anim_state.travel("walk")` a cada frame de perseguição. Correção em `inimigo.gd`: só viajar para estados que existem na máquina de estados e só definir `blend_position` de parâmetros existentes. Vira um **commit `fix(enemy)` separado** (pendência B09).
  - **Causa do erro de `hframes`/`vframes`:** as animações do Player animam `hframes`/`vframes` com `update` contínuo e, nos blends do AnimationTree, o valor passa por 0. Resolvido pela própria integração, já que essas tracks são removidas (passo 4.5).
- Commits previstos (só quando o usuário mandar): `fix(enemy)` para os erros de walk; `feat(player)` para a integração.
