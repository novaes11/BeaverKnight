# 04 — Arquitetura e Organização

## Estrutura do repositório

```text
BeaverKnight/
├── CLAUDE.md                 # Instruções de entrada do Claude (aponta para contexto/)
├── contexto/                 # Esta pasta: contexto, planos e implementações (para o Claude)
├── docs/                     # Landing Page (GitHub Pages) — NÃO é documentação técnica
├── ferramentas/sprites/      # Scripts Node.js que geram sprites (ex.: gerar_beaver_knight.js)
├── ferramentas/testes/       # Testes headless da Godot (ex.: teste_player_headless.gd)
├── src/movimentação.cs       # Arquivo C# legado, não usado pelo jogo
├── TODO.md                   # Conteúdo atual sem relevância (ver pendências)
└── beaver-knight-app/        # Projeto Godot
    ├── project.godot         # Configuração (resolução, input map, autoload)
    ├── Scene/                # main_menu.tscn, town.tscn, player.tscn, inimigo.tscn
    ├── Scripts/
    │   ├── Character/Player/player.gd
    │   ├── Character/Enemy/inimigo.gd          # IA usada pelo inimigo
    │   ├── Character/Enemy/enemy_spawn.gd      # Spawner
    │   ├── Character/Enemy/enemy_movement.gd   # Protótipo NÃO usado por nenhuma cena
    │   ├── UI/main_menu.gd
    │   └── World/audio_manager.gd, town.gd
    ├── Assets/               # TileSets, água, grama, fontes, UI
    ├── Sounds/               # Effects/, Soundtrack/, Bus_DeControle.tres
    ├── Sprites/              # Spritesheets do castor, inimigos, cortes de espada
    └── Basic Asset Pack/     # Pacote de terceiros (monstros .aseprite/.gif)
```

> Cada `.gd` possui um `.gd.uid` gerado pela Godot. Ao criar/mover scripts, manter o `.uid` junto.

## Fluxo de cenas

```
main_menu.tscn (main_menu.gd)
   └── botão Iniciar → get_tree().change_scene_to_file("res://Scene/town.tscn")
town.tscn (town.gd)
   ├── TileMapLayers: tipo_terreno, caminho_terreno, vegetação_layer, construções_layer
   ├── Player (CharacterBody2D, grupo "player") + Camera2D  ← embutido na cena, não instancia player.tscn
   └── EnemySpawn (enemy_spawn.gd) + SpawnTimer → instancia inimigo.tscn
```

Cada cena raiz para a música atual e toca a sua via `AudioManager` no `_ready()`.

## Sistemas

### AudioManager (Autoload / Singleton)
Arquivo: `Scripts/World/audio_manager.gd`, registrado em `project.godot` como `AudioManager`.

- `play_sfx(stream, volume_db, pitch)` — pool de 8 `AudioStreamPlayer` (barramento `Effect`).
- `play_sfx_2d(stream, posição, volume_db, pitch)` — pool de 8 `AudioStreamPlayer2D` (posicional).
- `play_music(stream, volume_db)` / `stop_music()` — player de música no barramento `Music` (não reinicia se a mesma música já estiver tocando).
- Os scripts expõem `@export var sfx_*: AudioStream` e passam o volume em dB em cada chamada.
- Layout de barramentos: `Sounds/Bus_DeControle.tres` (Master, Music, Effect).

### Colisão / caminhabilidade do mapa (Player)
A caminhabilidade é decidida **por código**, consultando as `TileMapLayer` irmãs do Player (`player.gd`):

| Nome da camada contém | Papel | Regra |
| :--- | :--- | :--- |
| `tipo` (`tipo_terreno`) | Terreno base (chão/água) | Bloqueia se o `source_id` da célula **não** estiver em `WALKABLE_TERRAIN_SOURCES` (`[5]`) |
| `caminh` (`caminho_terreno`) | Estradas e pontes | Qualquer tile **libera** a passagem (sobrepõe a água) |
| qualquer outro nome | Vegetação, construções etc. | Qualquer tile **bloqueia** |

- A classificação é feita **por substring do nome do nó** (só ASCII, para evitar problemas com ç/ã). **Renomear camadas ou adicionar novas TileMapLayers muda a colisão.**
- A **origem do Player fica nos pés** do castor. O teste é feito a partir de `global_position + pe_offset`, `distancia_sonda` px à frente (variáveis exportadas, padrão `(0, -2)` e `8`), separadamente em X e Y — isso permite deslizar pelas margens dos rios.
- `CollisionShape2D` do Player: caixa 14×8 nos pés (`(0, -4)`).
- Depois disso o `move_and_slide()` ainda trata colisões físicas normais.
- Os inimigos **não** usam essa lógica (atravessam água/obstáculos sem colisor).

### Combate
Comunicação por **grupos** e **métodos por convenção** (duck typing), sem signals:

- Player está no grupo `player`; inimigos no grupo `enemies` (adicionados pelo spawner).
- Ataque do Player (`attack`): trava o movimento (`can_move = false`), toca `attack_armed`, e percorre o grupo `enemies`:
  - distância ≤ 12 px → acerta em qualquer ângulo;
  - distância ≤ 28 px e `dot(direção_olhar, direção_inimigo) > 0.3` → acerta (cone ~140°).
  - Chama `take_damage(attack_damage)` se o alvo tiver o método.
- O movimento é liberado de volta por uma **track de método** na animação de ataque que chama `set_move(true)` (em `town.tscn`).
- Inimigo (`inimigo.gd`): persegue o primeiro nó do grupo `player`; dentro de `attack_range` ataca com cooldown via `await create_timer`; tem `apply_knockback(force)`; ao morrer toca SFX posicional e faz `queue_free()`.
- Morte do Player: apenas respawn na posição inicial com vida cheia.

### Spawner
`enemy_spawn.gd` (nó `EnemySpawn` em `town.tscn`): a cada timeout do `SpawnTimer`, se houver menos que `max_enemies` no grupo `enemies`, instancia `inimigo.tscn` numa posição aleatória entre `spawn_area_min` e `spawn_area_max`, alinhada a 16 px, adicionando em `current_scene`.

### Animação
- `AnimationTree` com `AnimationNodeStateMachine`; os scripts definem `parameters/<estado>/blend_position` e chamam `playback.travel()`.
- **Player:** estados `idle`, `walk`, `attack_armed` (BlendSpace2D com as animações `idle_*`, `walk_*`, `armed_*`).
  - O `Sprite2D` usa uma textura única, `Sprites/beaver_knight/beaver_knight_sheet.png` (4×9 quadros de 48×48, `offset (0, -20)`).
  - As animações só trocam `frame` e `flip_h`. A esquerda é a direita espelhada. Mapa de quadros em `contexto/implementacoes/2026-11-22-sprite-sheet-beaver-knight.md`.
  - Tracks de método:
    - `set_move(true)` no início dos `idle_*` e no fim dos `armed_*` (0,42 s);
    - `tocar_SFXPasso()` nos quadros de passo dos `walk_*`.
  - **Não animar `texture`, `hframes` ou `vframes`.** Nos blends da AnimationTree isso gera `Amount of hframes cannot be smaller than 1`.
- **Inimigo:** a máquina de estados de `inimigo.tscn` só tem o estado `slime`. `inimigo.gd` usa `_ir_para_estado()` / `_definir_blend()`, que ignoram estados inexistentes. Nunca chamar `travel()` direto para um estado que pode não existir.
