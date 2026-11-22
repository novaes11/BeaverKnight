# 04 — Arquitetura e Organização

## Estrutura do repositório

```text
BeaverKnight/
├── CLAUDE.md                 # Instruções de entrada do Claude (aponta para contexto/)
├── contexto/                 # Esta pasta: contexto, planos e implementações (para o Claude)
├── docs/                     # Landing Page (GitHub Pages) e build Web em docs/jogo/
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
    │   ├── Character/Enemy/enemy_spawn.gd      # Gerencia as zonas
    │   ├── Character/Enemy/zona_spawn.gd       # Zona de combate
    │   ├── Character/Enemy/enemy_movement.gd   # Protótipo NÃO usado por nenhuma cena
    │   ├── UI/main_menu.gd
    │   └── World/audio_manager.gd, town.gd, regras_terreno.gd, terreno_colisao.gd,
    │             mapa_navegacao.gd, passagem_caverna.gd
    ├── Assets/               # TileSets, água, grama, fontes, UI
    ├── Sounds/               # Effects/, Soundtrack/, Bus_DeControle.tres
    ├── Sprites/              # beaver_knight/ (folha do castor) e capanga de petróleo
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

### Colisão e caminhabilidade do mapa
`Scripts/World/regras_terreno.gd` (`RegrasTerreno`) é a **fonte única** usada pelo Player e pelos inimigos. As `TileMapLayer` são classificadas por parte do nome (só ASCII):

| Nome da camada contém | Papel | Regra |
| :--- | :--- | :--- |
| `tipo` (`tipo_terreno`) | Terreno base | Sem tile ou `source_id` fora de `FONTES_ANDAVEIS` (`[5]`) bloqueia |
| `caminh` (`caminho_terreno`) | Estradas, pontes e escadas | Qualquer tile **libera** |
| outros | Vegetação, construções | Bloqueiam, exceto decoração baixa (canos, capim, plantas, areia) |

- Objetos de várias células sem colisão (tanques, turbinas, tocos) bloqueiam a metade de baixo do desenho.
- `terreno_colisao.gd`, em `tipo_terreno`, remove a física da margem sob escada e ponte (atlas 42–47 × 10–12).
- `LimitesMapa` (StaticBody2D) fecha os planaltos laterais, e o `Camera2D` tem `limit_*`.
- A **origem do Player fica nos pés**. O teste usa `global_position + pe_offset`, `distancia_sonda` px à frente, separado em X e Y para deslizar nas margens. `CollisionShape2D`: 14×8 em `(0, -4)`.
- **Camadas físicas:** 1 = mundo, 2 = Player, 3 (valor 4) = inimigos. Inimigos e Player não se empurram.

### Passagens
`PassagemCaverna` (nós em `Passagens`) leva o Player até um `Marker2D` com fade e `set_travado()`. Liga a caverna da praia ao túnel da refinaria. Inimigos não atravessam.

### Navegação
`MapaNavegacao` (grupo `mapa_navegacao`) monta um `AStarGrid2D` de 8 px na área de combate, no 3º quadro de física, e rotula regiões conectadas. API: `caminho()`, `conectados()`, `ponto_livre()`.

### Combate
Comunicação por **grupos** e **métodos por convenção**:

- Player no grupo `player`; inimigos em `enemies`.
- Ataque do Player: sai de `global_position + (0, -8)`, acerta até 12 px em qualquer ângulo ou até 28 px no cone frontal (`dot > 0.3`), chama `apply_knockback()` e `take_damage()`.
- `set_move(true)` na animação de ataque devolve o movimento.
- **Inimigo** (`inimigo.gd`): estados `PATRULHA`, `PERSEGUICAO`, `AVISO`, `RECUPERACAO`, `RETORNO`. Visão 110 px, desiste a 180 px, fora da zona ou sem rota.
- Morte do Player: respawn na posição inicial com vida cheia.

### Spawner
`enemy_spawn.gd` (nó `EnemySpawn`) percorre os filhos `ZonaSpawn` a cada 0,5 s. Só nasce em ponto livre, conectado ao jogador, a pelo menos 190 px e em zona próxima. A cidade não tem zona.

### Partida
`Partida` (`Scripts/World/partida.gd`, grupo `partida`) controla as etapas `PRAIA → REFINARIA → BOSS → FIM`, a contagem, o tempo e o recorde. Cada `ZonaSpawn` tem `etapa` e `total_inimigos`. A caverna usa `requer_etapa`. No fim, o jogo pausa e mostra `tela_fim.tscn`; rejogar recarrega a cena.

Fluxo de telas: `main_menu.tscn → tela_historia.tscn → town.tscn`. O `hud.tscn` é instanciado na cidade.

### Boss
`BossPetroleo` (`boss_petroleo.gd`) usa uma folha 6×6 de 96 px animada por código. Estados: `SURGINDO`, `ESPERANDO`, `ANDANDO`, `PANCADA`, `CUSPE`, `RECUPERANDO`, `MORRENDO`. Anda só dentro de `arena` e expõe `ponto_mais_proximo()` para o golpe considerar o corpo grande.

### Exportação Web
Preset em `beaver-knight-app/export_presets.cfg`, sem threads, com lista explícita em `export_files` (**cenas e scripts novos precisam entrar nela**). A build fica em `docs/jogo/`. Texturas não podem ficar embutidas apontando para `.godot/imported`, senão ficam fora da build.

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
