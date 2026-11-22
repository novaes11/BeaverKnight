# 03 — Visão Geral do Projeto

## O que é

**BeaverKnight — Sustentabilidade em 8-Bits** é um jogo educativo 2D, top-down, em Pixel Art, desenvolvido como **Projeto de Extensão Universitária** do curso de Ciência da Computação da **UniFil**.

O jogador controla o **Cavaleiro Castor**, que defende o ecossistema contra inimigos ligados à poluição (slimes, capangas de petróleo). O objetivo é gamificar a conscientização ambiental: preservação da água, combate a derramamentos de petróleo, reflorestamento e energia limpa.

Landing Page oficial: https://novaes11.github.io/BeaverKnight/

## Tecnologias

| Item | Valor |
| :--- | :--- |
| Engine | Godot 4.x (README cita 4.6; o editor local já marcou `4.7` em `project.godot`) |
| Linguagem | GDScript |
| Renderizador | GL Compatibility |
| Resolução | 320×180 nativa, ampliada para 1280×720 (`stretch/mode = viewport`) |
| Filtro de textura | Nearest (pixel art) + `snap_2d_transforms_to_pixel = true` |
| Grade de tiles | 16 px |
| Física 3D | Jolt (irrelevante — jogo é 2D) |

## Como executar

**Jogo:**
1. Abrir a Godot 4.x → Importar → selecionar `beaver-knight-app/project.godot`.
2. Pressionar `F5` (cena principal: `Scene/main_menu.tscn`).

Ou, com a Godot no PATH:

```powershell
godot --path beaver-knight-app
```

**Landing Page (`docs/`):**

```powershell
python -m http.server 8000 --directory docs
```

Acessar `http://localhost:8000`.

**Build Web:** ver `contexto/implementacoes/2026-11-22-gameplay-rejogavel-boss-web.md`. O jogo publicado fica em `docs/jogo/`.

## Objetivo do jogo

Derrotar os slimes da praia e da refinaria e vencer o Boss de Petróleo para limpar a cidade e manter o equilíbrio ecológico. Ao vencer ou perder, o jogador pode iniciar outra partida.

## Controles

| Comando | Ação |
| :--- | :--- |
| Setas direcionais / D-Pad | Movimentar o castor (8 direções) |
| Botão esquerdo do mouse | Ataque com espada |

Ações definidas no Input Map (`project.godot`): `ui_left`, `ui_right`, `ui_up`, `ui_down`, `attack`.

## Equipe (segundo o README)

| Integrante | Área principal |
| :--- | :--- |
| João Vitor Novaes | Backlog/sprint, level design da cidade, TileSets, documentação e Landing Page |
| Enzo Schmidt | Áudio (SFX, trilhas, `AudioManager`) |
| João Camargo | UI/UX do menu principal, colisões do ambiente |
| Rafael Vasconcelos | Pixel Art e animações |
| João Tavares e Henrique Cavalari | Gameplay: movimentação, combate, IA dos inimigos |

## Branches

- `main` — branch principal (PRs vão para ela).
- `feature/implantacaoFinal` — branch de trabalho atual da fase pós-implantação.
