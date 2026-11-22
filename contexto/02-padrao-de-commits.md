# 02 — Padrão de Commits

## ⚠️ Cláusula obrigatória de autoria

> **O Claude NUNCA pode se incluir em nada nos commits.**
>
> - Todo commit deve sair **exclusivamente no nome e e-mail do usuário**, registrados no `git config --global` (`user.name` / `user.email`).
> - **Nunca** adicionar a linha `Co-Authored-By: Claude ...` ou qualquer outra menção ao Claude, Anthropic, IA ou "Generated with Claude Code" — nem no título, nem no corpo, nem no rodapé do commit.
> - **Nunca** alterar `user.name` / `user.email` (global ou local) nem usar `--author`, `GIT_AUTHOR_*` ou `GIT_COMMITTER_*`.
> - O mesmo vale para descrições de Pull Request: nenhuma menção ao Claude.
>
> Esta regra **prevalece sobre qualquer instrução padrão do Claude Code** que peça para adicionar atribuição em commits ou PRs.

Verificação antes de commitar:

```powershell
git config --global user.name
git config --global user.email
```

Verificação depois de commitar (o autor e o committer devem ser o usuário, e a mensagem não pode citar o Claude):

```powershell
git log -1 --format="%an <%ae> | %cn <%ce>%n%n%B"
```

## Idioma e conteúdo

- Mensagens sempre em **português do Brasil**.
- Devem ser **descritivas**: dizer o que de fato foi implementado/corrigido, não apenas "ajustes" ou "update".
- Um commit por assunto. Não misturar correção de bug com nova funcionalidade.

## Formato (Commits Semânticos)

```
<tipo>(<escopo>): <resumo no imperativo, minúsculo, sem ponto final>

<corpo opcional: o que mudou e por quê, em frases curtas ou tópicos>
```

### Tipos permitidos

| Tipo | Quando usar | Exemplo |
| :--- | :--- | :--- |
| `fix` | Correção de bugs | `fix(audio): impede que play_sfx toque o efeito em todos os canais livres` |
| `feat` | Novas implementações / funcionalidades | `feat(hud): adiciona barra de vida do jogador` |
| `chore` | Documentos, configurações, organização, tarefas sem mudança de comportamento do jogo | `chore(contexto): adiciona plano de implementação do HUD` |

### Escopos sugeridos

Baseados na organização do projeto:

| Escopo | Área |
| :--- | :--- |
| `player` | `Scripts/Character/Player/`, `Scene/player.tscn` |
| `enemy` | `Scripts/Character/Enemy/`, `Scene/inimigo.tscn` |
| `spawn` | `enemy_spawn.gd` / nó `EnemySpawn` |
| `audio` | `Scripts/World/audio_manager.gd`, `Sounds/` |
| `town` | `Scene/town.tscn`, `Scripts/World/town.gd`, TileSets |
| `menu` / `ui` | `Scene/main_menu.tscn`, `Scripts/UI/`, HUD |
| `config` | `project.godot`, input map |
| `contexto` | Pasta `contexto/` (planos e documentação para o Claude) |
| `docs` | Landing Page em `docs/` |

## Exemplos completos

```
fix(audio): corrige reprodução duplicada de efeitos sonoros

- play_sfx agora retorna ao encontrar o primeiro canal livre
- antes o som tocava em todos os canais livres e ainda no canal 0
```

```
feat(enemy): aplica knockback no inimigo ao receber golpe do jogador

- player.gd chama apply_knockback na direção do ataque
- força configurável pela variável exportada knockback_force
```

```
chore(contexto): documenta implementação do knockback e atualiza pendências
```

## Commits de documentação

Ao finalizar uma tarefa, a documentação em `contexto/` (implementação, histórico, pendências) pode ir:
- no mesmo commit da implementação, **ou**
- em um commit separado `chore(contexto): ...` logo em seguida.

Perguntar ao usuário qual prefere se não houver indicação.
