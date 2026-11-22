# 01 — Regras de Atuação do Claude

Estas regras valem para **toda** tarefa neste repositório. Em caso de dúvida, elas têm prioridade sobre qualquer comportamento padrão do Claude.

## 1. Idioma

- Toda comunicação, documentação, comentários de código e mensagens de commit devem ser em **português do Brasil (PT-BR)**.
- Nomes de nós, variáveis e funções seguem o padrão já existente no projeto (mistura de PT-BR e inglês — ex.: `take_damage`, `tocar_SFXPasso`, `tipo_terreno`). Não renomear itens existentes sem que isso esteja no plano aprovado.

## 2. Fluxo obrigatório de trabalho

Nenhum código é alterado sem passar por este fluxo:

```
1. Ler o contexto  →  2. Criar o plano  →  3. Aguardar validação  →  4. Implementar  →  5. Documentar  →  6. Commitar (somente se pedido)
```

### Passo 1 — Ler o contexto
- Ler os arquivos da pasta `contexto/` (ver [README.md](README.md)) antes de qualquer ação.
- Ler os scripts e cenas envolvidos na tarefa antes de propor mudanças.

### Passo 2 — Criar o plano de implementação
- Criar um arquivo em `contexto/planos/` usando o modelo [`planos/_MODELO-plano.md`](planos/_MODELO-plano.md).
- O plano deve conter: objetivo, diagnóstico (causa do bug ou motivo da funcionalidade), arquivos afetados, passos, riscos e como testar no Godot.
- Status inicial do plano: **`Aguardando validação`**.

### Passo 3 — Aguardar validação do usuário
- **Nunca implementar antes da aprovação explícita do usuário.**
- Se o usuário pedir ajustes, atualizar o plano e aguardar nova validação.
- Ao ser aprovado, mudar o status do plano para **`Aprovado`**.

### Passo 4 — Implementar
- Implementar **somente** o que está no plano aprovado. Se surgir algo fora do escopo, parar e avisar o usuário (propor um novo plano ou um ajuste).
- Preferir alterar scripts `.gd`. Arquivos `.tscn` são gerados pelo editor da Godot e muito grandes (`town.tscn` tem ~11 mil linhas de dados de TileMap): editar apenas trechos pequenos e pontuais, e avisar o usuário quando uma mudança for melhor feita pelo editor.
- Não commitar mudanças incidentais do editor em `project.godot` (ex.: troca de versão em `config/features`).

### Passo 5 — Documentar
Após implementar, no mesmo trabalho:
1. Criar o arquivo em `contexto/implementacoes/` usando o modelo [`implementacoes/_MODELO-implementacao.md`](implementacoes/_MODELO-implementacao.md).
2. Adicionar uma linha em [06-historico-pos-implantacao.md](06-historico-pos-implantacao.md).
3. Atualizar [05-estado-atual-e-pendencias.md](05-estado-atual-e-pendencias.md) (marcar o item como resolvido / remover).
4. Atualizar [04-arquitetura-e-organizacao.md](04-arquitetura-e-organizacao.md) se a arquitetura mudou.
5. Mudar o status do plano para **`Implementado`**.

### Passo 6 — Commitar
- Só commitar quando o usuário pedir.
- Seguir **obrigatoriamente** o [02-padrao-de-commits.md](02-padrao-de-commits.md).

## 3. Testes

O projeto não possui testes automatizados nem linter. A verificação é feita executando o jogo na Godot. O Claude deve:
- Descrever no plano e na documentação de implementação **o passo a passo para testar manualmente** no jogo.
- A Godot 4.7.1 do usuário fica em `%USERPROFILE%\Downloads\Godot_v4.7.1-stable_win64.exe\Godot_v4.7.1-stable_win64_console.exe` (não está no PATH). Use-a em modo `--headless` para checar erros de console, por exemplo com `ferramentas/testes/teste_player_headless.gd` (ver CLAUDE.md).
- Ao validar uma correção, **compare a saída com a versão do HEAD** (mesmo roteiro de teste) para provar que o erro sumiu e que nenhum erro novo apareceu.
- Visual, som e sensação de jogo continuam sendo validados pelo usuário com a janela aberta.
- Nunca afirmar que algo "funciona" sem ter verificado; deixar claro o que foi e o que não foi testado.

## 4. O que o Claude não deve fazer

- Implementar sem plano aprovado.
- Incluir-se como autor ou coautor de commits (ver [02-padrao-de-commits.md](02-padrao-de-commits.md)).
- Fazer `push`, abrir PR, fazer merge ou trocar de branch sem pedido explícito.
- Alterar a pasta `docs/` (Landing Page) sem que isso esteja no plano.
- Apagar assets, cenas ou scripts sem confirmação.
