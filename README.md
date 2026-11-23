# 🦫⚔️ BeaverKnight — Sustentabilidade em 8-Bits

<p align="center">
  <img src="beaver-knight-app/Assets/UI/BeaverKnight-BG.png" alt="Banner Oficial BeaverKnight" width="760">
</p>

<p align="center">
  <a href="https://novaes11.github.io/BeaverKnight/"><img src="https://img.shields.io/badge/GitHub_Pages-Landing_Page_Oficial-10b981?style=for-the-badge&logo=github" alt="Landing Page"></a>
  <img src="https://img.shields.io/badge/Godot_Engine-4.7_(GL_Compatibility)-478cbf?style=for-the-badge&logo=godotengine&logoColor=white" alt="Godot 4.7">
  <img src="https://img.shields.io/badge/Linguagem-GDScript-38bdf8?style=for-the-badge" alt="GDScript">
  <img src="https://img.shields.io/badge/UniFil-Projeto_de_Extens%C3%A3o-f59e0b?style=for-the-badge" alt="Extensão UniFil">
</p>

> 🎮 **Jogue agora no navegador:** [**novaes11.github.io/BeaverKnight/jogo/**](https://novaes11.github.io/BeaverKnight/jogo/index.html)
>
> 🌐 **Landing Page oficial:** [**novaes11.github.io/BeaverKnight/**](https://novaes11.github.io/BeaverKnight/)

---

## 📖 Sobre o Projeto

O **BeaverKnight** é um jogo educativo 2D em estilo **Pixel Art** desenvolvido como **Projeto de Extensão Universitária** no curso de Ciência da Computação do **Centro Universitário Filadélfia (UniFil)**.

O projeto gamifica a conscientização ambiental — conservação da água, contaminação por petróleo e equilíbrio ecológico — em uma aventura top-down na qual o jogador controla o **Cavaleiro Castor** para limpar a região da poluição.

---

## 🎯 Objetivo do Jogo

Derrote os monstros da poluição para **limpar a cidade e manter o equilíbrio ecológico**. Cada partida dura de 5 a 8 minutos:

1. **Praia:** saia da cidade, suba a escada e derrote **6 slimes** para abrir a caverna.
2. **Refinaria:** atravesse a caverna e derrote mais **16 slimes**, que vão atrás de você.
3. **Boss de Petróleo:** vá ao pátio da fábrica e vença a gosma gigante.

Ao vencer ou perder, a tela final mostra tempo, inimigos derrotados e melhor tempo, com a opção de **jogar novamente**. Se a vida acabar, a partida recomeça do início.

---

## 🎮 Como Jogar

| Comando | Ação no Jogo |
| :--- | :--- |
| **Setas Direcionais (`←` `↑` `↓` `→`) / D-Pad** | Movimentam o Cavaleiro Castor |
| **Botão Esquerdo do Mouse (`Clique`)** | Ataca com a espada |
| **`Esc` ou `P`** | Pausa o jogo: continuar, reiniciar ou voltar ao menu |

**Dicas contra o boss:** saia do círculo vermelho antes da pancada, desvie das gotas de petróleo e revide enquanto ele se recupera. Abaixo de 50% da vida ele entra em fúria, e você recebe **+35 de vida**. Ficar parado só batendo não vence a luta.

---

## ⚙️ Arquitetura Técnica & Sistemas (Godot 4.7)

- **Resolução:** base de `320×180 px` ampliada para `1280×720 px`, com texto renderizado na resolução da tela para ficar nítido.
- **Partida (`Scripts/World/partida.gd`):** etapas, objetivos, vitória, derrota, tempo, recorde e recomeço.
- **Mapa em camadas (`Scene/town.tscn`):** `tipo_terreno`, `caminho_terreno`, `vegetação_layer` e `construções_layer`, com regras centralizadas em `Scripts/World/regras_terreno.gd`.
- **Jogador (`Scripts/Character/Player/player.gd`):** movimento em 8 direções, golpe em cone frontal no quadro de impacto, invencibilidade temporária, recuo e `AnimationTree` (`idle`, `walk`, `attack_armed`).
- **Inimigos (`Scripts/Character/Enemy/`):** navegação A* (`mapa_navegacao.gd`), estados de patrulha, perseguição, ataque com aviso e retorno (`inimigo.gd`) e spawn por zonas (`enemy_spawn.gd`, `zona_spawn.gd`).
- **Boss de Petróleo (`boss_petroleo.gd`):** pancada em área, cuspe de petróleo e fúria abaixo de 50% da vida.
- **Interface (`Scripts/UI/`):** HUD, barras de vida, menu, tela de missão, tela de pausa e telas de fim de jogo.
- **Áudio (`Scripts/World/audio_manager.gd`):** Autoload com 8 canais globais e 8 posicionais 2D, nos barramentos de `Sounds/Bus_DeControle.tres` (`Master`, `Music`, `Effect`).
- **Web:** exportação HTML5 sem threads, publicada em `docs/jogo/` pelo GitHub Pages.

---

## 👥 Equipe de Desenvolvimento, Atribuições & Evidências no Repositório

| Integrante | Atribuições Principais | Evidências no Repositório / Código |
| :--- | :--- | :--- |
| **João Vitor Novaes** | Gestão de backlog e sprint no Notion; Level Design da cidade; configuração dos TileSets de terreno, canos, estruturas de mata e óleo; documentação e Landing Page. | Arquitetura de camadas em [`Scene/town.tscn`](beaver-knight-app/Scene/town.tscn), mapeamento de texturas em `Assets/Water` ([`DirtyWaterTexture.tres`](beaver-knight-app/Assets/Water/DirtyWaterTexture.tres)), organização de diretórios e documentações do projeto ([`docs/`](docs/)). |
| **Enzo Schmidt** | Engenharia acústica, curadoria de SFX (Pixabay/geradores 8-bit) e desenvolvimento do controlador geral de áudio. | [`Scripts/World/audio_manager.gd`](beaver-knight-app/Scripts/World/audio_manager.gd), configuração de barramentos em [`Sounds/Bus_DeControle.tres`](beaver-knight-app/Sounds/Bus_DeControle.tres) e roteamento de efeitos globais/posicionais 2D. |
| **João Camargo** | Design de interfaces (UI/UX) do menu principal e estruturação da física base de colisões do ambiente. | [`Scene/main_menu.tscn`](beaver-knight-app/Scene/main_menu.tscn), [`Scripts/UI/main_menu.gd`](beaver-knight-app/Scripts/UI/main_menu.gd), parametrização de nós de colisão e delineamento de máscaras nos TileMaps. |
| **Rafael Vasconcelos** | Ilustração e animação em Pixel Art dos personagens e elementos dinâmicos. | Primeira versão dos spritesheets do castor ([`beaverSprite.png`](https://github.com/novaes11/BeaverKnight/blob/ebea2a28508d026be2eb4d672f07302900603c26/beaver-knight-app/Sprites/beaverSprite.png)), variações de caminhada/ataque, artes do Death Slime, arte dos capangas de petróleo, base visual do boss ([`capanga_petroleopng.png`](beaver-knight-app/Sprites/capanga_petroleopng.png)) e efeitos de corte de espada ([`slash_128.png`](https://github.com/novaes11/BeaverKnight/blob/ebea2a28508d026be2eb4d672f07302900603c26/beaver-knight-app/Sprites/custom/slash_128.png)). |
| **João Tavares e Henrique Cavalari** | Engenharia de gameplay: implementação das físicas de movimentação do jogador, lógica de combate e IA dos inimigos. | [`Scripts/Character/Player/player.gd`](beaver-knight-app/Scripts/Character/Player/player.gd), [`Scripts/Character/Enemy/inimigo.gd`](beaver-knight-app/Scripts/Character/Enemy/inimigo.gd), rotinas de perseguição, knockback e o primeiro protótipo de raycasting (versão histórica) em [`enemy_movement.gd`](https://github.com/novaes11/BeaverKnight/blob/ebea2a28508d026be2eb4d672f07302900603c26/beaver-knight-app/Scripts/Character/Enemy/enemy_movement.gd). |

---

## 📂 Estrutura do Repositório

```text
BeaverKnight/
├── beaver-knight-app/               # Projeto principal na Godot Engine 4.7
│   ├── Assets/                      # TileSets, texturas de água, fontes e UI
│   ├── Scene/                       # main_menu, tela_historia, town, hud, tela_pausa, tela_fim, inimigo, boss_petroleo
│   ├── Scripts/                     # GDScript: Character (Player/Enemy), UI e World
│   ├── Sounds/                      # Barramentos, SFX 8-bit e trilhas
│   ├── Sprites/                     # Folhas do castor e do boss, e arte dos capangas
│   ├── export_presets.cfg           # Preset de exportação Web
│   └── project.godot                # Configuração do projeto
├── contexto/                        # Planos, arquitetura, pendências e histórico do desenvolvimento
├── docs/                            # Landing Page (GitHub Pages)
│   ├── assets/                      # CSS, scripts, fotos da equipe e artes
│   ├── jogo/                        # Build HTML5 do jogo
│   └── index.html                   # Página principal
└── ferramentas/                     # Geradores de sprites e testes automatizados
```

---

## 🚀 Como Executar Localmente

1. **Para rodar o projeto (`beaver-knight-app`)**:
   - Instale a **Godot Engine 4.7** (versão padrão, não a .NET).
   - Abra o gerenciador de projetos da Godot, clique em **Importar** e selecione o arquivo `beaver-knight-app/project.godot`.
   - Pressione `F5` para iniciar a partir da cena principal (`Scene/main_menu.tscn`).
2. **Para visualizar a Landing Page (`docs/`)**:
   - Sirva o diretório `docs/` com qualquer servidor HTTP estático (ex.: `python3 -m http.server 8000 --directory docs`) e acesse `http://localhost:8000`. O jogo fica em `http://localhost:8000/jogo/`.
