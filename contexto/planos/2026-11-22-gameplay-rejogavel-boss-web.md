# Plano: Gameplay rejogável, Boss da Poluição e build Web

| Campo | Valor |
| :--- | :--- |
| Data | 2026-11-22 |
| Tipo | `feat` (gameplay) + `fix` (áudio e combate) + `chore` (exportação) |
| Pendências | B01, B02, B06, F02, F03, F05, F06, L03, L05 + novas F08, F09, L09 |
| Status | `Implementado` — testado e aprovado pelo usuário em 2026-11-22 |

## 1. Objetivo

Transformar o que já existe em uma partida curta, completa e rejogável, atendendo aos requisitos do trabalho:

- [x] **Build final exportado para HTML5/Web.**
- [x] **Mecânica cíclica/rejogável, permitindo múltiplas partidas.**

**Missão do jogador:** derrotar os slimes da poluição e o Boss de Petróleo para limpar a cidade e manter o equilíbrio ecológico.

## 2. O ciclo do jogo

```text
Menu → Como Jogar (opcional) → História/Objetivo → PARTIDA
                                                     │
        ┌────────────────────────────────────────────┘
        ▼
  1. Limpar a Praia       derrotar 6 slimes → caverna abre, vida restaurada
        ▼
  2. Limpar a Refinaria   derrotar 10 slimes → boss desperta, vida restaurada
        ▼
  3. Boss de Petróleo    derrotar o chefe
        │
        ├── venceu  → Tela de Vitória → Jogar Novamente / Menu
        └── morreu  → Tela de Derrota → Tentar Novamente / Menu
```

- **Duração estimada:** 5 a 8 minutos por partida.
- **Rejogar:** recarrega a cena da cidade, zerando vida, inimigos, progresso e boss.
- **Motivo para jogar de novo:** as telas finais mostram tempo e inimigos derrotados. O melhor tempo fica salvo no navegador.
- **Cidade:** continua segura, como ponto de partida.

## 3. O que já existe e o que muda

| Sistema | Hoje | Depois |
| :--- | :--- | :--- |
| Inimigo comum | Slime verde | **Mantido**, com barra de vida e efeito de morte |
| Chefe | Não existe | **Boss de Petróleo**, com sprites novos |
| Spawn | Reposição infinita | Quantidade **finita** por objetivo |
| Morte do jogador | Respawn imediato | Tela de Derrota |
| Caverna | Sempre aberta | Abre ao limpar a praia, com aviso se estiver fechada |
| Vida | Invisível | HUD e barras nos inimigos |
| Golpe | Dano no momento do clique | Dano no quadro de impacto da animação |
| Mapa, escada, A*, IA, zonas | Funcionando | **Mantidos** |

## 4. Implementação

### Fase 1: Base e correções (`fix`)
- **B01:** `play_sfx` toca o som em vários canais; adicionar o `return`.
- **B02:** registrar `Bus_DeControle.tres` como layout de áudio, para os volumes de música e efeitos funcionarem.
- **B06:** garantir que o jogador nunca fique travado se morrer no meio de um ataque.
- **L05:** remover os `print()` de debug.

### Fase 2: Partida e objetivos (`feat`)
- Novo nó `Partida` (`Scripts/World/partida.gd`) na cidade, controlando as etapas, a contagem, a abertura da caverna, o boss e o fim de jogo.
- Zonas de spawn passam a ter **total de inimigos** e só ficam ativas na sua etapa.

### Fase 3: Combate (`feat`)

| Item | Valor inicial |
| :--- | :--- |
| Vida do jogador | 100 |
| Dano da espada | 25 (slime morre em 2 golpes) |
| Invencibilidade após dano | 0,7 s, com sprite piscando |
| Empurrão ao receber dano | Curto, sem entrar em água ou paredes |
| Golpe | Dano aplicado no quadro de impacto |
| Morte do slime | Encolhe e desaparece com flash, sem sprites novos |
| Impacto | Tremida curta da câmera |

### Fase 4: HUD e telas (`feat`)
- **HUD:** barra de vida do jogador, objetivo atual (`Limpe a Praia: 3/6`) e barra grande do boss durante a luta.
- **Inimigos:** barra de vida pequena sobre a cabeça.
- **Menu:** `COMO JOGAR` passa a explicar objetivo, controles e etapas.
- **Início da partida:** tela curta com a história: *a poluição tomou a região; derrote os slimes e o Boss de Petróleo para limpar a cidade e manter o equilíbrio ecológico.*
- **Fim de jogo:** Vitória e Derrota com estatísticas e botões de jogar novamente e voltar ao menu.

### Fase 5: Boss de Petróleo (`feat`)

**Sprites**, com o mesmo fluxo aprovado do castor: **protótipo → sua aprovação → folha completa**.

| Item | Especificação |
| :--- | :--- |
| Visual | **Gosma preta gigante**: corpo largo e pesado que escorre pelo chão, braços de gosma, **olhos vermelhos brilhantes**, boca serrilhada, bolhas tóxicas e brilho oleoso |
| Base | Olhos angulados, boca em zigue-zague e contorno oleoso da arte de `Assets/Inimigos/`, em uma forma nova e maior |
| Identidade | **Design original do projeto.** A referência é a sensação de "monstro de gosma evoluído", sem copiar a silhueta, o rosto ou as cores de personagens de outros jogos. Para reforçar o tema: pedaços de cano e um barril enferrujado presos na gosma |
| Quadro | **96×96**, boss com ~72 px de altura (3× o castor) |
| Paleta | Até 16 cores: pretos, roxos escuros, brilho oleoso, vermelhos |
| Direção | Frente, com espelhamento para os lados |

| Linha | Animação | Quadros |
| :-: | :--- | :-: |
| 0 | Parado | 4 |
| 1 | Andar | 4 |
| 2 | Pancada | 4 |
| 3 | Cuspe de petróleo | 4 |
| 4 | Dano | 2 |
| 5 | Morte | 6 |

**Comportamento** (simples e legível):

| Ataque | Aviso | Efeito |
| :--- | :--- | :--- |
| Pancada | Círculo vermelho no chão por 0,7 s | 20 de dano em área |
| Cuspe | Boss recua e brilha por 0,4 s | 3 gotas em leque, 10 de dano cada |

- **Vida:** 800 (32 golpes), ajustada após a simulação de balanceamento.
- **Fúria (abaixo de 50%):** anda mais rápido, ataca com menos intervalo e cospe 5 gotas.
- **Arena:** pátio em frente à fábrica. Ele não atravessa a caverna.

### Fase 6: Exportação e publicação Web (`chore`)
- Criar o preset **Web** em `export_presets.cfg`, **sem threads**, para rodar em hospedagem simples como o GitHub Pages.
- Excluir do build arquivos que não são usados (`.aseprite`, `.gif`, artes-fonte).
- Esconder `SAIR DO JOGO` na Web, porque o navegador não permite fechar a aba pelo jogo.
- Testar a build em um servidor local, no navegador: áudio, teclado, mouse e várias partidas seguidas.
- Exportar para `docs/jogo/` e adicionar um botão **Jogar Agora** na Landing Page.
- **Publicação:** o site só atualiza quando o conteúdo chegar à branch configurada no GitHub Pages (pelo histórico, a `main`). O push vai para `feature/implantacaoFinal`; o merge na `main` depende da sua autorização.
- **L09/L03:** remover `town.tscn562209570.tmp`, arquivo temporário versionado por engano, e limpar o `TODO.md`.

## 5. Arquivos afetados

| Arquivo | Mudança |
| :--- | :--- |
| `Scripts/World/partida.gd` | **Novo:** etapas e fim de jogo |
| `Scripts/UI/hud.gd`, `Scene/hud.tscn` | **Novos:** HUD |
| `Scripts/UI/tela_fim.gd`, `Scene/tela_fim.tscn` | **Novos:** vitória/derrota |
| `Scripts/UI/tela_historia.gd`, `Scene/tela_historia.tscn` | **Novos:** história e objetivo |
| `Scripts/Character/Enemy/boss_petroleo.gd`, `Scene/boss_petroleo.tscn` | **Novos:** boss |
| `Scripts/Character/Enemy/projetil_petroleo.gd`, `Scene/projetil_petroleo.tscn` | **Novos:** cuspe |
| `Scripts/UI/barra_vida.gd` | **Novo:** barra sobre os inimigos |
| `ferramentas/sprites/gerar_boss_petroleo.js` | **Novo:** geração da folha do boss |
| `Sprites/boss/` | **Novo:** folha do boss |
| `player.gd`, `inimigo.gd`, `enemy_spawn.gd`, `zona_spawn.gd`, `passagem_caverna.gd`, `audio_manager.gd`, `main_menu.gd` | Ajustes |
| `town.tscn`, `inimigo.tscn`, `main_menu.tscn` | Novos nós e textos |
| `project.godot` | Layout de áudio |
| `export_presets.cfg` | **Novo:** preset Web |
| `docs/jogo/`, `docs/index.html` | **Novos/ajuste:** build publicada e botão Jogar Agora |

## 6. Riscos

- **Templates de exportação:** a pasta de templates da Godot está **vazia**. É preciso instalar os templates da versão **4.7.1** (download grande), pelo editor: *Editor → Gerenciar Modelos de Exportação*. Vou pedir sua confirmação antes de qualquer download.
- **Godot .NET:** a Web não aceita a versão Mono. A exportação precisa usar a **Godot padrão**, que você já tem. O projeto não possui scripts C# dentro de `beaver-knight-app`.
- **Áudio na Web:** navegadores só liberam som depois de um clique, então a música do menu pode começar após a primeira interação.
- **Tamanho:** há duas músicas MP3 (4,8 MB) e artes grandes. O tamanho final será medido na build.
- **Sprite do boss:** é desenhado por código, então o acabamento depende das suas rodadas de aprovação.
- **Escopo:** é a maior entrega até aqui. Por isso, cada fase é testada e pode virar um commit separado.

## 7. Como testar

**Automático:** testes headless atualizados para a partida completa: etapas, caverna, boss, vitória, derrota e **3 partidas seguidas sem erro**.

**Jogando (desktop e navegador):**
1. Ler `COMO JOGAR` e iniciar.
2. Limpar a praia e conferir a abertura da caverna.
3. Limpar a refinaria e enfrentar o boss.
4. Vencer e clicar em Jogar Novamente.
5. Morrer de propósito e clicar em Tentar Novamente.
6. Repetir na build Web, abrindo pelo botão **Jogar Agora**.

## 8. Commits previstos

```
fix(audio): corrige reprodução duplicada e barramentos de áudio
fix(player): evita travamento ao morrer durante o ataque
feat(partida): adiciona etapas, objetivos e ciclo de partidas
feat(combate): adiciona invencibilidade, impacto e dano no golpe
feat(ui): adiciona HUD, barras de vida e telas de história e fim de jogo
feat(boss): adiciona o Boss de Petróleo
chore(web): configura exportação HTML5
feat(docs): publica o jogo na Landing Page
chore(contexto): documenta o modelo de gameplay
```

## 9. Validação do usuário

- [x] Plano aprovado pelo usuário (2026-11-22)
- **Decisão 1, inimigos (2026-11-22):** manter o slime verde e adicionar apenas um boss novo, preto, grande e com aparência de gosma, baseado na arte de petróleo existente.
- **Decisão 2, derrota (2026-11-22):** recomeçar a partida inteira.
- **Decisão 3, publicação (2026-11-22):** exportar e publicar no GitHub Pages, com link na Landing Page.
- Observações/ajustes pedidos:
  - **Teste do usuário (2026-11-22):** fundo do HUD agora acompanha o texto. Espada e dano estavam quase inaudíveis porque a correção do B01 removeu o som duplicado (que somava volume) e o barramento Effect (-10,6 dB) passou a valer; os volumes dos efeitos foram recalibrados.
