# Documentos & Materiais para Alunos — BeaverKnight

Este diretório (`docs/assets/documents/`) centraliza os documentos de apoio pedagógico e técnico do projeto **BeaverKnight** publicados via GitHub Pages para acesso direto dos alunos e educadores.

## Como disponibilizar novos documentos na Landing Page

1. **Adicione o arquivo** (ex.: `.pdf`, `.md` ou guia de aula) dentro desta pasta `docs/assets/documents/` (preferencialmente sem espaços no nome, por exemplo: `cartilha-sustentabilidade.pdf` ou `gdd-beaver-knight.pdf`).
2. **Adicione ou atualize um card** na seção `<section id="documentos">` em `docs/index.html` apontando para o caminho relativo:
   ```html
   <a href="assets/documents/cartilha-sustentabilidade.pdf" target="_blank" rel="noopener noreferrer" class="btn-secondary">
       Baixar PDF ↗
   </a>
   ```
   Ou com o atributo `download` para download imediato com 1 clique:
   ```html
   <a href="assets/documents/cartilha-sustentabilidade.pdf" download class="btn-primary">
       Baixar Cartilha (PDF)
   </a>
   ```
3. **Faça o commit e push** para a branch publicada no GitHub Pages — os arquivos passam a ficar acessíveis diretamente pelo navegador dos alunos.
