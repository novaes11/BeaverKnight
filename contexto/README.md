# Contexto do Projeto BeaverKnight (para o Claude)

Esta pasta é a **fonte de contexto obrigatória** para o Claude Code neste repositório.
**Antes de qualquer ação** (responder, planejar, implementar, commitar), o Claude deve ler os arquivos abaixo, na ordem indicada.

> A pasta `docs/` (na raiz) é a **Landing Page do GitHub Pages** e não faz parte deste contexto.
> Toda a documentação de planejamento e de implementação fica aqui em `contexto/`.

## Ordem de leitura

| # | Arquivo | Conteúdo |
| :-: | :--- | :--- |
| 1 | [01-regras-de-atuacao.md](01-regras-de-atuacao.md) | Como o Claude deve agir: fluxo obrigatório plano → validação → implementação → documentação |
| 2 | [02-padrao-de-commits.md](02-padrao-de-commits.md) | Padrão de commits em PT-BR e a regra de autoria (o Claude **nunca** aparece nos commits) |
| 3 | [03-visao-geral-do-projeto.md](03-visao-geral-do-projeto.md) | O que é o jogo, tecnologias, como executar |
| 4 | [04-arquitetura-e-organizacao.md](04-arquitetura-e-organizacao.md) | Estrutura de pastas, cenas, scripts e como os sistemas conversam entre si |
| 5 | [05-estado-atual-e-pendencias.md](05-estado-atual-e-pendencias.md) | Bugs conhecidos, funcionalidades faltando e backlog |
| 6 | [06-historico-pos-implantacao.md](06-historico-pos-implantacao.md) | Registro de tudo que foi adicionado/corrigido após a implantação |

## Subpastas

| Pasta | Uso |
| :--- | :--- |
| [`planos/`](planos/) | Planos de implementação, um arquivo por tarefa. Criados **antes** de qualquer código. Modelo: [`planos/_MODELO-plano.md`](planos/_MODELO-plano.md) |
| [`implementacoes/`](implementacoes/) | Documentação do que foi efetivamente implementado, um arquivo por tarefa concluída. Modelo: [`implementacoes/_MODELO-implementacao.md`](implementacoes/_MODELO-implementacao.md) |

## Convenção de nomes dos arquivos

- Planos: `planos/AAAA-MM-DD-nome-curto.md` (ex.: `planos/2026-11-22-corrige-audio-manager.md`)
- Implementações: `implementacoes/AAAA-MM-DD-nome-curto.md` (mesmo nome do plano correspondente)

## Manutenção desta pasta

Sempre que uma implementação mudar algo descrito aqui (arquitetura, pendências, comandos), o Claude deve **atualizar o arquivo correspondente** no mesmo trabalho, para que o contexto nunca fique desatualizado.
