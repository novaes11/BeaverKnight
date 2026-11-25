# Documentação do Projeto BeaverKnight

Este diretório reúne a documentação oficial do jogo BeaverKnight: Sustentabilidade em 8-Bits, escrita com base na versão final implementada em Godot 4.7 (GDScript) e publicada na Web.

O projeto pode ser acessado pelos links abaixo:

- Versão jogável no navegador: https://novaes11.github.io/BeaverKnight/jogo/index.html
- Landing Page oficial: https://novaes11.github.io/BeaverKnight/
- Código do jogo em Godot: [`beaver-knight-app/`](../beaver-knight-app/)

## Documentos disponíveis

| Documento | Conteúdo principal | Versão para download (PDF) |
| :--- | :--- | :--- |
| [Documento de Visão](visao.md) | Propósito pedagógico, alinhamento às ODS (7, 12 e 15), público, equipe, premissas técnicas e impacto esperado | [visao-beaverknight.pdf](../docs/assets/documents/visao-beaverknight.pdf) |
| [Game Design Document (GDD)](gdd.md) | Narrativa, personagens, inimigos, Boss de Petróleo, progressão em etapas, combate, controles, HUD e áudio | [gdd-beaverknight.pdf](../docs/assets/documents/gdd-beaverknight.pdf) |
| [Fluxo do Jogo e Casos de Uso](fluxo-e-casos-de-uso.md) | Atores, diagrama e tabela de casos de uso, navegação entre cenas, máquinas de estado e interações | [fluxo-e-casos-de-uso-beaverknight.pdf](../docs/assets/documents/fluxo-e-casos-de-uso-beaverknight.pdf) |
| [Relatório de Desenvolvimento](relatorio-desenvolvimento.md) | Evolução técnica, arquitetura em GDScript, soluções de colisão/IA/áudio/Web, testes headless e entregáveis | [relatorio-desenvolvimento-beaverknight.pdf](../docs/assets/documents/relatorio-desenvolvimento-beaverknight.pdf) |

## Ficha técnica resumida

| Item | Especificação atual |
| :--- | :--- |
| Vínculo acadêmico | Projeto de Extensão Universitária, Ciência da Computação (UniFil, 2026) |
| Gênero | Ação e aventura top-down 2D em Pixel Art |
| Engine e linguagem | Godot 4.7 padrão (GL Compatibility) e GDScript |
| Resolução | Base 320×180 px ampliada para 1280×720 px (`canvas_items`, filtro Nearest) |
| Plataforma alvo | Web/HTML5 sem threads (GitHub Pages) e Desktop |
| Duração da partida | 5 a 8 minutos (3 etapas contínuas no mesmo mapa) |
| Controles | Setas direcionais ou D-Pad (movimento), botão esquerdo do mouse (ataque), `Esc` ou `P` (pausa) |

## Equipe e frentes de trabalho

| Integrante | Frente principal |
| :--- | :--- |
| João Vitor Novaes | Gestão de backlog e sprint (Notion), level design da cidade, TileSets, documentação e Landing Page |
| Enzo Schmidt | Engenharia acústica, curadoria de efeitos sonoros 8-bit e controlador de áudio (`AudioManager`) |
| João Camargo | UI/UX do menu principal e configuração inicial das colisões nos TileMaps |
| Rafael Vasconcelos | Ilustração e animação em Pixel Art dos personagens e elementos visuais base |
| João Tavares | Engenharia de gameplay: movimentação, combate, IA dos inimigos e testes de cena |
| Henrique Cavalari | Engenharia de gameplay: movimentação, combate, IA dos inimigos e sistema de spawn |
