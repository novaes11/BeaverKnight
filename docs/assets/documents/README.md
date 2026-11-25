# Documentos e Materiais — BeaverKnight

Este diretório (`docs/assets/documents/`) centraliza os documentos oficiais do projeto **BeaverKnight** em PDF publicados via GitHub Pages para acesso direto de alunos e educadores. As versões editáveis em Markdown ficam em [`documentacao/`](../../../documentacao/).

## Documentos publicados

| Arquivo | Descrição |
| :--- | :--- |
| `visao-beaverknight.pdf` | Documento de Visão: propósito educacional, ODS (7, 12 e 15), equipe e premissas técnicas |
| `gdd-beaverknight.pdf` | Game Design Document (GDD): narrativa, personagens, inimigos, Boss de Petróleo, fases, HUD e áudio |
| `fluxo-e-casos-de-uso-beaverknight.pdf` | Fluxo do Jogo e Casos de Uso: diagramas, casos de uso, fluxo entre telas e máquinas de estado |
| `relatorio-desenvolvimento-beaverknight.pdf` | Relatório de Desenvolvimento: evolução técnica, arquitetura GDScript, testes headless e entregas |

## Como disponibilizar novos documentos na Landing Page

1. Adicione o arquivo `.pdf` em `docs/assets/documents/` sem espaços no nome.
2. Adicione ou atualize o card correspondente na seção `<section id="documentos">` em `docs/index.html`:
   ```html
   <a href="assets/documents/meu-documento.pdf" target="_blank" rel="noopener noreferrer" class="btn-doc-pdf">
       Abrir PDF ↗
   </a>
   ```
3. Faça commit e push para a branch publicada no GitHub Pages.
