# Relatório de Desenvolvimento: BeaverKnight

| Campo | Informação |
| :--- | :--- |
| Projeto | BeaverKnight: Sustentabilidade em 8-Bits |
| Estágio documentado | Versão final entregue e publicada na Web |
| Engine | Godot 4.7 padrão (GL Compatibility) e GDScript |
| Repositório | https://github.com/novaes11/BeaverKnight |
| Landing Page | https://novaes11.github.io/BeaverKnight/ |
| Versão jogável Web | https://novaes11.github.io/BeaverKnight/jogo/index.html |

## 1. Introdução

Este relatório apresenta o estado técnico final do jogo BeaverKnight, detalhando a arquitetura implementada na Godot 4.7, a passagem do protótipo inicial para o ciclo completo de partida, os ajustes de jogabilidade e exportação Web e os resultados dos testes automatizados em modo headless.

## 2. Metodologia e organização do projeto

O desenvolvimento seguiu fluxo contínuo com versionamento em Git e GitHub (branches de trabalho integradas via Pull Requests na `main`) e gestão de backlog e sprints no Notion. No código, a equipe adotou scripts GDScript modulares com parâmetros `@export` ajustáveis no Inspector da Godot, mantendo cenas enxutas e comunicação desacoplada por sinais e grupos (`"player"`, `"enemies"`, `"partida"`, `"mapa_navegacao"` e `"projeteis_boss"`).

## 3. Evolução técnica do protótipo à versão final

O projeto passou por três estágios de amadurecimento ao longo do desenvolvimento:

1. No protótipo inicial, parte do código estava em C# (`Global`, `Logger`, `Enums`, `CharacterMovement.cs`) e o protagonista ficava em uma cena separada (`player.tscn`). Essa base foi substituída integralmente por GDScript para simplificar a manutenção e viabilizar exportação Web sem o runtime .NET.
2. Na primeira versão jogável em GDScript (`enemy_movement.gd`), o mapa ainda permitia acesso aos planaltos laterais, a escada e a ponte ficavam bloqueadas por colisão da margem, os inimigos usavam raycast simples sem navegação e faltavam HUD, metas de etapa, chefe final e build Web.
3. Na entrega final integrada, os scripts experimentais antigos (`enemy_movement.gd`, `movimentação.cs`, `player.tscn` e 44 sprites sem uso do castor) foram removidos e substituídos por uma arquitetura unificada de terreno, pathfinding A*, spawn validado por zonas, sprite sheets novos para o castor e para o chefe, HUD, pausa, áudio ajustado para navegador e build HTML5 publicada no GitHub Pages.

## 4. Arquitetura e implementações realizadas

### 4.1 Estrutura de diretórios do projeto

```text
BeaverKnight/
├── beaver-knight-app/
│   ├── project.godot                     # Resolução 320x180 -> 1280x720, canvas_items, Input Map, Autoload AudioManager
│   ├── export_presets.cfg                # Preset Web sem threads apontando para ../docs/jogo/index.html
│   ├── Scene/                            # main_menu, tela_historia, town, hud, tela_pausa, tela_fim, inimigo, boss_petroleo, projetil_petroleo
│   ├── Scripts/
│   │   ├── Character/Player/player.gd
│   │   ├── Character/Enemy/              # inimigo.gd, enemy_spawn.gd, zona_spawn.gd, boss_petroleo.gd, projetil_petroleo.gd
│   │   ├── UI/                           # main_menu.gd, tela_historia.gd, hud.gd, tela_pausa.gd, tela_fim.gd, barra_vida.gd, estilo_ui.gd
│   │   └── World/                        # audio_manager.gd, town.gd, partida.gd, regras_terreno.gd, terreno_colisao.gd, mapa_navegacao.gd, passagem_caverna.gd
│   ├── Assets/                           # TileSets, água limpa e petróleo (AnimatedTexture), fontes e UI
│   ├── Sounds/                           # Trilhas, efeitos 8-bit e Bus_DeControle.tres
│   └── Sprites/                          # beaver_knight/beaver_knight_sheet.png e boss/boss_petroleo_sheet.png
├── docs/                                 # Landing Page (index.html, CSS, JS, mídias, PDFs) e build Web (docs/jogo/)
├── documentacao/                         # Documentação oficial do projeto em Markdown
└── ferramentas/                          # Geradores de sprites (Node.js) e testes automatizados headless (GDScript)
```

### 4.2 Mundo, colisões e passagem da caverna

O script `regras_terreno.gd` centraliza a caminhabilidade lendo as `TileMapLayer` pelo nome (`tipo_terreno`, `caminho_terreno`, demais obstáculos). Células sem tile bloqueiam a saída do mapa, estradas e pontes liberam a travessia, decorações baixas (`DECORACAO_VEGETACAO` e canos no chão) não travam o jogador e estruturas altas multi-célula bloqueiam somente a metade inferior do desenho.

Para liberar a passagem sobre os rios, `terreno_colisao.gd` remove em tempo de execução a física dos tiles de margem cobertos pela escada da praia e pela ponte da refinaria (faixa de atlas `42..47 × 10..12`). Os planaltos laterais são fechados por `LimitesMapa`, a `Camera2D` respeita os limites do cenário e `passagem_caverna.gd` faz o transporte em mão dupla entre praia e refinaria com fade de `0,2 s` e trava temporária de movimento (`set_travado()`), abrindo apenas depois da etapa da praia.

### 4.3 Jogador e design visual do BeaverKnight

O protagonista ganhou um sprite sheet único estilo GBA (`gerar_beaver_knight.js` → `beaver_knight_sheet.png`, `192×432 px`, grade `4×9` de `48×48 px`, paleta de 15 cores e transparência), com contorno separado por camadas, túnica e capa verdes, broche dourado, cauda quadriculada e espada presente em todos os quadros.

No script `player.gd`, a origem passou para os pés `(24, 44)` com `CollisionShape2D` de `14×8 px`, alinhada à mesma sonda de terreno usada pelos inimigos. O ataque em cone frontal de `28 px` (`dot > 0,3`) dispara no quadro de impacto e possui trava máxima de `0,5 s` para impedir travamento se o jogador morrer ou pausar durante o golpe. Também foram removidas as faixas fixas do `BlendSpace2D` (eliminando erros `blend_points_used = 0`) e adicionou-se o alinhamento da `Camera2D` ao arredondamento do sprite após `move_and_slide()`, zerando o tremor visual do castor quando o modo `canvas_items` entrou em uso para deixar os textos nítidos.

### 4.4 Inimigos, navegação A*, spawn e chefe final

A navegação dos inimigos usa `mapa_navegacao.gd`, que monta no terceiro quadro de física uma grade `AStarGrid2D` com células de `8×8 px` e folga de `12×12 px`, rotulando regiões conectadas por busca em largura (~256 ms na carga inicial; rotas calculadas em ~1 ms).

Em `inimigo.gd` e `barra_vida.gd`, o Death Slime passou a operar em cinco estados (`PATRULHA`, `PERSEGUICAO`, `AVISO`, `RECUPERACAO`, `RETORNO`), com aviso vermelho de `0,25 s` antes do ataque, barra de vida própria, separação entre unidades, knockback seguro e proteção de `AnimationTree` (`_ir_para_estado()` e `_definir_blend()`), encerrando erros antigos de estado `walk` inexistente. O spawner (`enemy_spawn.gd` e `zona_spawn.gd`) gera inimigos apenas em pontos livres e conectados dentro das zonas ativas (`ZonaPraia` com 6 slimes e `ZonaRefinaria` com 16 slimes que nascem em anel fora da tela e caçam o jogador via A*).

O Boss de Petróleo (`boss_petroleo.gd`, `projetil_petroleo.gd`, folha `6×6` de `96×96 px` gerada por `gerar_boss_petroleo.js`) possui `1050 HP`, sete estados, pancada em área com aviso circular vermelho de `1,0 s` e cuspe de 3 gotas (5 na fúria). O balanceamento garante que ficar parado apenas golpeando leve à derrota, enquanto desviar dos avisos permite vencer com folga.

### 4.5 Partida, interfaces, áudio e exportação Web

O gerenciador `partida.gd` controla as etapas `PRAIA → REFINARIA → BOSS → FIM`, restaura a vida entre etapas, conta os inimigos derrotados, mede o tempo e grava o recorde em `user://recorde.cfg`. As telas (`main_menu.gd`, `tela_historia.gd`, `hud.gd`, `tela_pausa.gd`, `tela_fim.gd`, `estilo_ui.gd`) padronizam a fonte `pkmnfl.ttf`, ajustam o fundo da HUD ao tamanho do texto e implementam a pausa via `Esc` ou `P`.

No áudio (`audio_manager.gd`), foi corrigida a falha em que `play_sfx()` tocava o mesmo efeito em vários canais livres simultaneamente. Os volumes foram recalibrados após a ativação correta do barramento `Effect`, o controlador recebeu `PROCESS_MODE_ALWAYS` para responder em telas pausadas e ganhou reforço exclusivo na Web (`+14 dB` em `Music` e `+8 dB` em `Effect`). A build HTML5 sem threads (`export_presets.cfg` → `docs/jogo/`) usa lista explícita em `export_files`, evitando perda de trilhas ou texturas embutidas no navegador.

## 5. Verificação e testes automatizados

O repositório conta com três suítes de teste executáveis via linha de comando na Godot 4.7 (`--headless`) em [`ferramentas/testes/`](../ferramentas/testes/):

| Script de teste | O que verifica | Resultado registrado |
| :--- | :--- | :--- |
| [teste_player_headless.gd](../ferramentas/testes/teste_player_headless.gd) | Movimento nas 4 direções e diagonais, ataque, quadros corretos (`idle`, `walk`, `attack_armed`), espelhamento e perseguição inicial | Sem erros de console (`0` erros de `AnimationTree`, `walk` ou `hframes/vframes`) |
| [teste_mapa_headless.gd](../ferramentas/testes/teste_mapa_headless.gd) | Conectividade cidade-praia, unificação da refinaria, `0` posições alcançáveis fora dos tiles (antes `34.335`), planaltos inacessíveis, tanques sólidos, ativação das passagens e pontos válidos por zona (`≥ 40`) | `PASSOU` com `0` falhas |
| [teste_combate_headless.gd](../ferramentas/testes/teste_combate_headless.gd) | Cidade segura, caverna fechada antes da praia e aberta depois, invencibilidade, slimes caçando na refinaria, 3 fluxos completos de vitória/derrota/pausa/reinício e 6 simulações do Boss | `PASSOU` com `0` falhas (com desvio: vitória em ~29 s; parado sem desviar: derrota em ~21 s) |

Duas medições complementares também validaram os ajustes finais: a oscilação da câmera ao andar no modo `canvas_items` caiu de 119 quadros com tremor (em 120 avaliados) para `0` quadros após o alinhamento em `player.gd`, e os picos de áudio na Web ficaram em `-14 dB` na música do menu, `-20 dB` no combate e `-3,5 dB` na espada, sem saturação.

## 6. Entregáveis publicados

| Entrega | Localização |
| :--- | :--- |
| Repositório GitHub (código-fonte completo) | https://github.com/novaes11/BeaverKnight |
| Landing Page oficial (GitHub Pages) | https://novaes11.github.io/BeaverKnight/ |
| Versão jogável no navegador (HTML5/Web) | https://novaes11.github.io/BeaverKnight/jogo/index.html |
| Documentação oficial em Markdown | [`documentacao/`](README.md) |
| Documentos em PDF para download | [`docs/assets/documents/`](../docs/assets/documents/) |

## 7. Considerações finais

O projeto cumpre todos os requisitos técnicos e pedagógicos definidos para a entrega final: o ciclo completo de partida roda do início ao fim diretamente no navegador, os sistemas de colisão, IA, combate, chefe, áudio e interface passaram nos testes headless sem erros críticos e toda a documentação reflete exatamente o código em Godot 4.7.

Para evoluções futuras fora do escopo atual, permanecem em aberto apenas a criação de animações próprias de ataque para o Death Slime (que hoje usa o loop `slime` com aviso avermelhado) e a remoção do asset legado sem uso `Assets/Player/Male_Spritesheet.png`.
