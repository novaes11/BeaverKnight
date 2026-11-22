# Implementação: Gameplay rejogável, Boss de Petróleo e build Web

| Campo | Valor |
| :--- | :--- |
| Data | 2026-11-22 |
| Tipo | `feat` (gameplay) + `fix` (áudio e combate) + `chore` (exportação) |
| Pendências | B01, B02, B06, F02, F03, F05, F06, F08, F09, L03, L05, L09 |
| Plano | [`planos/2026-11-22-gameplay-rejogavel-boss-web.md`](../planos/2026-11-22-gameplay-rejogavel-boss-web.md) |
| Commit(s) | `32bc19f` (áudio) · `0c90e4f` (partida) · `edb9dd7` (UI) · `c920ce7` (boss) · `1a1a246` (Web) · `a6eade3` (publicação) |

## O que foi feito

### Ciclo da partida

```text
Menu → Sua Missão → Praia (6 slimes) → Caverna abre → Refinaria (10 slimes)
     → Boss de Petróleo → Vitória ou Derrota → Jogar Novamente / Menu
```

- `Partida` controla etapas, contagem, tempo, vitória, derrota e recorde (`user://recorde.cfg`).
- Rejogar recarrega a cena e zera tudo. A derrota recomeça a partida inteira.
- A vida é restaurada ao concluir a praia e a refinaria.

### Combate
- Dano no quadro de impacto (`aplicar_golpe`, 0,08 s), com trava de segurança de 0,5 s para o jogador nunca ficar preso no ataque.
- Invencibilidade de 0,7 s com sprite piscando, recuo ao levar dano e tremida de câmera.
- Slimes com barra de vida, surgimento animado e efeito de morte.

### Boss de Petróleo
Design original do projeto, baseado na arte de petróleo existente. Folha de 576×576 (6×6 quadros de 96 px), gerada por `ferramentas/sprites/gerar_boss_petroleo.js`.

| Atributo | Valor | Atributo | Valor |
| :--- | :-: | :--- | :-: |
| Vida | 800 (32 golpes) | Dano da pancada | 18 |
| Aviso da pancada | 0,8 s | Dano do cuspe | 8 por gota |
| Aviso do cuspe | 0,55 s | Gotas | 3 (5 em fúria) |
| Recuperação | 1,1 s (0,85 s em fúria) | Cura ao entrar em fúria | +30 |

De perto alterna duas pancadas e um cuspe; de longe, cospe. Encostar nele não causa dano. Todos os valores são `@export`.

### HUD e telas
- Vida, objetivo, avisos e barra do boss. O fundo do HUD acompanha a largura do texto.
- `COMO JOGAR` reescrita e nova tela `Sua Missão`.
- Telas de vitória e derrota com tempo, inimigos e melhor tempo.

### Áudio
- `play_sfx` tocava em vários canais (B01). Com a correção e o barramento `Effect` (-10,6 dB) ativo (B02), os efeitos ficaram quase inaudíveis e **todos os volumes foram recalibrados**.

### Web
- Preset **Web** sem threads em `beaver-knight-app/export_presets.cfg`, exportando só cenas, scripts e dependências.
- Build em `docs/jogo/` e botões **Jogar Agora** na Landing Page.
- `SAIR DO JOGO` fica oculto na Web.
- **Corrigidos para a exportação:** o TileSet da grama usava uma textura embutida que não entrava na build, e a música do menu tinha um UID inválido e ficava de fora.

## Principais arquivos

| Arquivo | O que é |
| :--- | :--- |
| `Scripts/World/partida.gd` | Ciclo da partida |
| `Scripts/Character/Enemy/boss_petroleo.gd`, `projetil_petroleo.gd` | Boss e cuspe |
| `Scripts/UI/hud.gd`, `tela_fim.gd`, `tela_historia.gd`, `barra_vida.gd`, `estilo_ui.gd` | Interface |
| `Scene/boss_petroleo.tscn`, `projetil_petroleo.tscn`, `hud.tscn`, `tela_fim.tscn`, `tela_historia.tscn` | Cenas novas |
| `Sprites/boss/boss_petroleo_sheet.png` | Folha do boss |
| `export_presets.cfg`, `docs/jogo/` | Exportação e build |

## Como gerar a build de novo

```powershell
$G = "$env:USERPROFILE\Downloads\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe"
& $G --headless --path beaver-knight-app --export-release "Web" ../docs/jogo/index.html
```

Use a Godot **padrão**, não a versão .NET. Ao criar uma cena ou script novo, adicione-o a `export_files` no preset.

## Verificação

- `teste_combate_headless.gd`, no projeto e **no pacote exportado**: 3 fluxos de partida e 6 lutas de balanceamento, sem nenhum `ERROR`.
- `teste_mapa_headless.gd` e `teste_player_headless.gd`: sem erros.
- Navegador (localhost, sem COOP/COEP, como o GitHub Pages): build carrega, menu, missão, movimento e ataque funcionam, console sem erros, botão Jogar Agora abre o jogo.
- Simulação do boss: venceu desviando (21 s, vida 92) e sem desviar (19 s, vida 50). O robô não erra golpes; uma pessoa deve levar mais tempo.
- HUD e sons aprovados pelo usuário no jogo desktop.

**Testado e aprovado pelo usuário** na build Web, sem travamentos (2026-11-22).

## Pontos de atenção

- A build ocupa ~47 MB em `docs/jogo/` (o `index.wasm` tem ~39,5 MB, abaixo do limite de 100 MB por arquivo do GitHub).
- Toda alteração no jogo exige exportar de novo para atualizar `docs/jogo/`.
- Navegadores só liberam áudio depois da primeira interação.
