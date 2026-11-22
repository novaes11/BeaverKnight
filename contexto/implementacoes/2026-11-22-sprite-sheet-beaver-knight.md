# Implementação: Novo sprite sheet do BeaverKnight (estilo GBA)

| Campo | Valor |
| :--- | :--- |
| Data | 2026-11-22 |
| Tipo | `feat` |
| Pendência | nova (prepara a solução de B05) |
| Plano | [`planos/2026-11-22-sprite-sheet-beaver-knight.md`](../planos/2026-11-22-sprite-sheet-beaver-knight.md) |
| Commit(s) | `40fee7d` |

## O que foi feito

Foi criado um sprite sheet único do castor cavaleiro em pixel art estilo GBA, baseado na arte de abertura (`Assets/UI/BeaverKnight-BG.png`): orelhas redondas, sobrancelhas determinadas, dentões, túnica verde com barra clara, capa verde-escura, cinto com fivela dourada, broche, cauda quadriculada e espada em todos os quadros.

**O jogo ainda não usa esta folha.** A integração no `town.tscn` será feita em um plano separado.

## Arquivos

| Arquivo | O que é |
| :--- | :--- |
| `beaver-knight-app/Sprites/beaver_knight/beaver_knight_sheet.png` | Sprite sheet final (192×432) |
| `ferramentas/sprites/gerar_beaver_knight.js` | Script gerador (Node.js, sem dependências) |
| `contexto/implementacoes/imagens/beaver_knight_sheet_previa_4x.png` | Prévia da folha ampliada 4× |
| `contexto/implementacoes/imagens/beaver_knight_prototipo_6x.png` / `_2x.png` | Prévias dos 3 idles aprovados no protótipo |

## Especificação da folha

- Quadro **48×48**, grade **4 colunas × 9 linhas**, fundo transparente, 15 cores + transparência.
- **Âncora dos pés:** pixel **(24, 44)** em todos os quadros.
- Índice do quadro no Godot (`Sprite2D.frame` com `hframes = 4`, `vframes = 9`): `linha * 4 + coluna`.
- **Esquerda** = linha "right" com `flip_h = true`.

| Linha | Animação | Quadros (índices) | Sequência |
| :-: | :--- | :--- | :--- |
| 0 | `idle_down` | 0, 1 | guarda → respiração (espada/braço descem 1 px, cauda balança) |
| 1 | `idle_up` | 4, 5 | idem |
| 2 | `idle_right` | 8, 9 | idem |
| 3 | `walk_down` | 12, 13, 14, 15 | passo esq. → neutro → passo dir. → neutro |
| 4 | `walk_up` | 16, 17, 18, 19 | idem |
| 5 | `walk_right` | 20, 21, 22, 23 | idem (pernas abertas alternando a perna da frente) |
| 6 | `attack_down` | 24, 25, 26, 27 | preparação → impacto (com rastro) → recuperação → guarda |
| 7 | `attack_up` | 28, 29, 30, 31 | idem |
| 8 | `attack_right` | 32, 33, 34, 35 | idem |

Quadros 2, 3, 6, 7, 10 e 11 (colunas 2–3 das linhas de idle) ficam vazios.

## Como o script funciona

- Cada parte do corpo (cabeça, corpo, pernas, cauda, braços) é uma **matriz de letras** no objeto `P`; cada letra é uma cor da `PALETA`. As partes são desenhadas **sem contorno**, e o contorno escuro de 1 px é gerado automaticamente em volta de cada parte, o que separa as camadas como em sprites do GBA.
- A **espada**, o **braço de ataque** e o **rastro do golpe** são procedurais (`espada()`, `braco()`, `pata()`, `rastro()`), configurados por coordenadas em cada quadro do objeto `QUADROS`.
- `montarFrente`, `montarCostas` e `montarPerfil` montam o quadro na ordem certa de camadas a partir de opções (posição das pernas, braço livre, cauda, espada, rastro).

Comandos:

```powershell
node ferramentas/sprites/gerar_beaver_knight.js                 # gera a folha + prévia 4x
node ferramentas/sprites/gerar_beaver_knight.js --prototipo     # prévias dos 3 idles
node ferramentas/sprites/gerar_beaver_knight.js --quadros=attack_down_0,attack_down_1 --saida=previa.png   # prévia 6x de quadros específicos
```

Para ajustar a arte, edite as matrizes em `P` ou as coordenadas em `QUADROS` e rode o script de novo.

## Decisões tomadas

- Ajustes pedidos no protótipo: segundo braço (livre, abaixado) de frente e de costas, túnica mais visível (verde mais claro, dobras e barra clara), sobrancelhas, nuca com brilho, cauda frontal menor e espada do perfil afastada do peito.
- No perfil o braço de trás fica escondido pelo corpo (padrão de sprites laterais do GBA).
- Nos ataques de frente e de costas o golpe é feito pelo lado da mão da espada, sem cruzar o corpo, para manter a leitura do sprite.
- Rastro do golpe só aparece no quadro de impacto e é pintado apenas em pixels vazios (fica "atrás" do personagem).

## Como testar

1. Abrir `contexto/implementacoes/imagens/beaver_knight_sheet_previa_4x.png` e conferir as 9 linhas.
2. Na Godot: criar um `Sprite2D` com a textura `Sprites/beaver_knight/beaver_knight_sheet.png`, `hframes = 4`, `vframes = 9`, filtro **Nearest**, e percorrer `frame` de 0 a 35.

## Verificação

- **Testado pelo Claude:** o script gera o PNG de 192×432 sem erros; os quadros foram revisados visualmente nas prévias ampliadas.
- **Aprovado pelo usuário:** visual da folha completa (2026-11-22).
- **Pendente:** importação na Godot (o editor gera o `.import` ao abrir o projeto) e ver as animações rodando em jogo, o que acontece na integração (F07).

## Pontos de atenção

- A animação de walk é sutil (pés alternando 1 px, braço e cauda balançando), no padrão GBA. Se ficar pouco perceptível em jogo, dá para exagerar o movimento.
- Integração no Godot (próximo plano): trocar as 3 texturas atuais por esta folha, refazer as tracks de `frame`, usar `flip_h` para a esquerda e ajustar `CollisionShape2D` e o ponto dos pés em `player.gd` para a nova âncora (resolve B05).
