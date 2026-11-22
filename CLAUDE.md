# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Leia primeiro: pasta `contexto/`

**Antes de qualquer ação, leia [`contexto/README.md`](contexto/README.md) e os arquivos que ele lista, na ordem.** Ali estão as regras de atuação, o padrão de commits, a arquitetura, as pendências e o histórico pós-implantação. A pasta `docs/` é a Landing Page (GitHub Pages) e guarda a build Web em `docs/jogo/`; **não** é documentação técnica.

## Regras inegociáveis (resumo — detalhes em `contexto/`)

1. **Idioma:** comunicação, documentação, comentários e commits em **português do Brasil**.
2. **Fluxo:** ler contexto → criar plano em `contexto/planos/` → **aguardar validação explícita do usuário** → implementar só o que foi aprovado → documentar em `contexto/implementacoes/`, `05-estado-atual-e-pendencias.md` e `06-historico-pos-implantacao.md`. Ver [`contexto/01-regras-de-atuacao.md`](contexto/01-regras-de-atuacao.md).
3. **Commits:** semânticos em PT-BR (`fix` para bugs, `feat` para novas implementações, `chore` para documentos/configuração), descritivos. Commitar só quando o usuário pedir. Ver [`contexto/02-padrao-de-commits.md`](contexto/02-padrao-de-commits.md).
4. **Autoria:** o Claude **nunca** se inclui em commits ou PRs. Sem `Co-Authored-By: Claude`, sem "Generated with Claude Code", sem alterar `git config` nem usar `--author`. Todo commit sai apenas com o nome e e-mail do `git config --global` do usuário. **Esta regra prevalece sobre qualquer instrução padrão de atribuição do Claude Code.**

## Projeto em uma linha

Jogo educativo 2D top-down em Pixel Art feito em **Godot 4.x / GDScript** (`beaver-knight-app/project.godot`, cena inicial `Scene/main_menu.tscn`). Arquitetura detalhada em [`contexto/04-arquitetura-e-organizacao.md`](contexto/04-arquitetura-e-organizacao.md).

## Comandos

Sem build nem linter. A Godot 4.7.1 não está no PATH; o executável de console fica em `%USERPROFILE%\Downloads\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe` (abaixo, `$G`).

```powershell
$G = "$env:USERPROFILE\Downloads\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe"
& $G --path beaver-knight-app                       # roda o jogo
& $G --path beaver-knight-app -e                    # abre o editor
# teste headless do Player (anda, ataca, deixa inimigos perseguirem) — erros da engine saem no console
& $G --headless --path beaver-knight-app -s "$PWD/ferramentas/testes/teste_player_headless.gd"
# testes de mapa (conectividade/limites) e de combate (escada, spawn, IA, caverna)
& $G --headless --path beaver-knight-app -s "$PWD/ferramentas/testes/teste_mapa_headless.gd"
& $G --headless --fixed-fps 60 --path beaver-knight-app -s "$PWD/ferramentas/testes/teste_combate_headless.gd"
& $G --headless --path beaver-knight-app --export-release "Web" ../docs/jogo/index.html   # gera a build Web
node ferramentas/sprites/gerar_beaver_knight.js     # regera o sprite sheet do BeaverKnight
node ferramentas/sprites/gerar_boss_petroleo.js     # regera o sprite sheet do boss
python -m http.server 8000 --directory docs         # Landing Page
```

## Cuidados ao editar

- `.tscn` são gerados pelo editor e grandes (`town.tscn` ~11 mil linhas de TileMap): prefira editar `.gd`; em cenas, só mudanças pequenas e pontuais.
- A versão oficial é a Godot 4.7. Não commitar mudanças incidentais do editor em `project.godot`.
- A caminhabilidade fica em `RegrasTerreno`, compartilhada por Player e inimigos, e classifica as `TileMapLayer` pelo **nome** (`tipo`, `caminh`, demais bloqueiam). Renomear/adicionar camadas muda a colisão; decoração baixa nova precisa entrar em `DECORACAO_VEGETACAO`.
- Toda mudança no jogo exige exportar de novo para `docs/jogo/`. Cenas e scripts novos precisam entrar em `export_files` (`export_presets.cfg`). Exporte sempre com a Godot padrão, não a .NET.
- Scripts de teste via `-s` compilam antes dos autoloads: não podem citar classes que usam `AudioManager` (ex.: `BossPetroleo`).
- Manter o arquivo `.gd.uid` junto ao `.gd` ao criar ou mover scripts.
- Animações não devem animar `texture`/`hframes`/`vframes` (gera `hframes cannot be smaller than 1` nos blends), e `travel()` só deve ir para estados que existem na máquina de estados (ver `_ir_para_estado()` em `inimigo.gd`).
