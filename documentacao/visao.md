# Documento de Visão: BeaverKnight

| Campo | Informação |
| :--- | :--- |
| Projeto | BeaverKnight: Sustentabilidade em 8-Bits |
| Instituição | Centro Universitário Filadélfia (UniFil), Ciência da Computação |
| Natureza | Projeto de Extensão Universitária |
| Versão do jogo documentada | Versão final publicada em Godot 4.7 / HTML5 |
| Última atualização | 24/11/2026 |

## 1. Introdução

O BeaverKnight aproxima estudantes do ensino básico e médio de temas ligados à sustentabilidade por meio de um jogo digital educativo. Em uma aventura top-down 2D em Pixel Art, o jogador controla o Cavaleiro Castor na missão de conter a poluição que ameaça a região ao redor da cidade, da praia e da refinaria.

A narrativa coloca o jogador frente a problemas concretos de preservação da água, contaminação por petróleo e equilíbrio ecológico. O projeto se alinha a três Objetivos de Desenvolvimento Sustentável (ODS) da ONU. O ODS 7 (Energia Limpa e Acessível) contrapõe o avanço da refinaria e das estruturas fósseis à presença de turbinas eólicas e painéis solares na identidade visual do menu inicial. O ODS 12 (Consumo e Produção Responsáveis) traz à tona os efeitos do descarte industrial sem controle sobre os ecossistemas locais. O ODS 15 (Vida Terrestre) associa a limpeza das regiões invadidas por lodo tóxico e petróleo à preservação da fauna e dos rios.

Por rodar diretamente no navegador sem exigir instalação, o jogo funciona como recurso didático gratuito para aulas, oficinas universitárias e uso doméstico.

## 2. Público e participantes do projeto

### 2.1 Equipe e atribuições

O jogo foi desenvolvido por alunos de Ciência da Computação da UniFil sob orientação docente, com divisão de responsabilidades por frentes técnicas:

| Integrante | Responsabilidades no projeto |
| :--- | :--- |
| João Vitor Novaes | Gestão ágil de backlog e sprints (Notion), level design da cidade, configuração dos TileSets de terreno, canos, vegetação e petróleo, documentação técnica e desenvolvimento da Landing Page |
| Enzo Schmidt | Engenharia acústica, curadoria de trilhas e efeitos sonoros 8-bit, configuração dos barramentos (`Bus_DeControle.tres`) e implementação do `AudioManager` |
| João Camargo | Design de interface (UI/UX) do menu principal (`main_menu.tscn`, `main_menu.gd`) e parametrização inicial das colisões nos TileMaps |
| Rafael Vasconcelos | Ilustração e animação em Pixel Art dos personagens iniciais, artes do Death Slime, arte conceitual dos capangas de petróleo e efeitos de corte |
| João Tavares | Engenharia de gameplay: física de movimentação do jogador, combate direcional e inteligência artificial dos inimigos |
| Henrique Cavalari | Engenharia de gameplay: movimentação do jogador, lógica de combate, estados de IA e spawn por zonas |

Os professores orientadores acompanham o andamento pedagógico, revisam as entregas acadêmicas e apoiam a aplicação do projeto na comunidade externa.

### 2.2 Público e experiência de jogo

O jogo atende prioritariamente estudantes de 11 a 17 anos (Ensino Fundamental II e Médio) e professores que procuram materiais interativos sobre meio ambiente, além de entusiastas de jogos retro em Pixel Art.

As partidas duram entre 5 e 8 minutos, tempo pensado para caber dentro de uma aula ou oficina escolar com espaço para debate depois da atividade. A progressão segue três etapas contínuas no mesmo mapa: limpar a praia enfrentando 6 slimes tóxicos para desbloquear a passagem da caverna, atravessar a caverna para derrotar 16 slimes que caçam o jogador na refinaria e vencer o Boss de Petróleo no pátio da fábrica.

Ao término de cada partida (vitória ou derrota), a tela final mostra o tempo total, o número de inimigos derrotados e o melhor tempo salvo localmente, incentivando o aluno a jogar novamente para superar seu próprio registro.

## 3. Visão geral do produto

O BeaverKnight é um jogo de ação top-down 2D em Pixel Art colorida, com estética inspirada em clássicos de consoles portáteis (estilo GBA/16-bits) e interface enxuta. O mapa contínuo usa camadas (`tipo_terreno`, `caminho_terreno`, `vegetação_layer` e `construções_layer`), onde a geografia separa a cidade preservada (área segura com grama, árvores e rios limpos) das zonas tomadas pela poluição (praia invadida por slimes e refinaria cercada por rios de petróleo).

### 3.1 Funcionalidades implementadas

O jogador movimenta o castor livremente em 8 direções, respeitando regras unificadas de terreno para água limpa, petróleo, pontes, escadas e objetos altos. O combate ocorre com golpes de espada em cone frontal que aplicam recuo (knockback) nos inimigos, acompanhados de invencibilidade temporária quando o protagonista sofre dano.

Os slimes comuns patrulham suas zonas, calculam rotas por A* para contornar obstáculos, piscam em vermelho antes de atacar e evitam se empilhar. No confronto final, o Boss de Petróleo alterna pancadas em área (marcadas com um círculo vermelho crescente no chão) e cuspes de gotas de petróleo, entrando em fúria quando cai abaixo de 50% da vida.

A interface cobre todo o ciclo de uso: menu principal, painel Como Jogar, tela de missão, HUD em partida (vida, objetivo atual, avisos e barra do chefe), tela de pausa (`Esc` ou `P`) e tela de vitória ou derrota com recorde. A trilha sonora e os efeitos de passo, espada, dano, clique e morte rodam em 16 canais (8 globais e 8 posicionais 2D) com reforço automático de volume para navegadores.

### 3.2 Fluxo de uma partida

O jogador começa na tela de título (`main_menu.tscn`), onde pode consultar os comandos em Como Jogar ou clicar em Iniciar Jogo para ler o resumo da missão (`tela_historia.tscn`). Na cidade (`town.tscn`), a área inicial não tem inimigos para que o jogador experimente o movimento e o ataque com calma antes de subir a escada de madeira até a praia.

Depois de derrotar os 6 slimes da praia, a vida volta ao máximo e a caverna ao norte se abre com um aviso na tela. Ao cruzar a caverna (com transição em fade), o jogador entra na refinaria, onde 16 slimes nascem nas proximidades e passam a persegui-lo. Limpar a refinaria restaura novamente a vida do castor e desperta o Boss de Petróleo no pátio leste da fábrica. Vencer o chefe encerra a partida e grava o melhor tempo caso o recorde anterior seja batido.

## 4. Recursos tecnológicos

O projeto foi construído sobre ferramentas gratuitas e de código aberto. A engine escolhida foi a Godot 4.7 (edição padrão), adotada pela leveza em 2D, controle direto sobre `TileMapLayer` e `AnimationTree`, além da exportação nativa para HTML5. Todo o código do jogo foi escrito em GDScript.

Como apoio de arte, dois scripts em Node.js (`gerar_beaver_knight.js` e `gerar_boss_petroleo.js`) geram as folhas de sprites do protagonista e do chefe pixel a pixel com paleta controlada. O código e os assets ficam versionados em Git e GitHub, que também hospeda a Landing Page em HTML, CSS e JavaScript (`docs/index.html`) e a versão jogável em `docs/jogo/`.

## 5. Premissas e restrições técnicas

Para funcionar em laboratórios de informática escolares e máquinas modestas, o sistema segue cinco restrições de projeto:

1. Opera 100% no cliente (client-side), sem servidor backend, banco de dados remoto ou APIs externas. O recorde de melhor tempo é salvo localmente em `user://recorde.cfg` (`localStorage`/IndexedDB no navegador).
2. Usa exportação Web sem threads (`thread_support=false`), permitindo hospedagem direta no GitHub Pages sem depender de cabeçalhos `COOP`/`COEP`.
3. Mantém resolução base compacta (`320×180 px`) com texturas em filtro `Nearest`, reduzindo consumo de memória em navegadores.
4. Empacota somente as cenas, scripts e recursos listados em `export_presets.cfg`, mantendo o tamanho da build em cerca de 47 MB dentro de `docs/jogo/`.
5. Exige apenas setas direcionais (ou D-Pad), botão esquerdo do mouse e `Esc`/`P`, facilitando o uso em desktops escolares padrão.

## 6. Impacto educacional e social esperado

Ao traduzir problemas de poluição hídrica e industrial para uma partida curta no navegador, o BeaverKnight oferece aos professores um ponto de partida prático para aulas e oficinas de educação ambiental. Os estudantes observam o contraste entre áreas preservadas e zonas contaminadas por óleo, vivenciam o papel de defesa do ecossistema e levam essas referências para debates sobre conservação da água e transição energética.

Para a equipe de Ciência da Computação da UniFil, o projeto aplica na prática conceitos de engenharia de software, busca de caminho com A*, máquinas de estado, design de interfaces, áudio digital e publicação Web em software aberto disponível à comunidade.
