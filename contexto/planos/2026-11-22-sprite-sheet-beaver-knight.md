# Plano: Novo sprite sheet do BeaverKnight (estilo GBA)

| Campo | Valor |
| :--- | :--- |
| Data | 2026-11-22 |
| Tipo | `feat` |
| Pendência | nova (relacionada a B05: offset dos "pés" fixo) |
| Status | `Implementado` — Fases 1 e 2 entregues e aprovadas pelo usuário em 2026-11-22 |

## 1. Objetivo

Substituir os sprites atuais do personagem principal por um **sprite sheet único em PNG**, em pixel art estilo Game Boy Advance (referência: Pokémon Fire Red/Leaf Green). O castor deve ser **o mesmo da arte de abertura** (`Assets/UI/BeaverKnight-BG.png`), em proporção chibi e **segurando a espada em todos os quadros**.

## 2. Diagnóstico

**Situação atual** (Player em `Scene/town.tscn`):
- O `Sprite2D` troca de **textura, `hframes`, `vframes`, `offset` e `frame`** a cada animação. Hoje são usadas 3 folhas diferentes no estilo LPC: `Sprites/standard/idle.png` e `walk.png` (quadros 64×64, 13×4) e `Sprites/custom/halfslash_128.png` (quadros 128×128, offset `(-32,-32)`).
- Essas folhas são de um humanoide genérico com cabeça de castor. Não lembram o personagem da abertura e não seguram a espada no idle/walk de forma consistente.
- `Sprites/beaverSprite.png` (77×154, 3×3 quadros) é mais próximo do personagem, mas tem problemas: proporções diferentes entre as direções, sem espada, cauda mal posicionada na visão lateral e quadros desalinhados (77 px não divide em 3 colunas iguais).
- O ponto dos "pés" está fixo no código em `Vector2(30, 41)` (`player.gd`) e o `CollisionShape2D` também, porque dependem do quadro de 64×64 com `centered = false`.

**Referência visual extraída da arte de abertura** (traços que o sprite deve manter):
- Pelo marrom médio com sombra marrom escura; focinho e bochechas creme.
- Orelhas pequenas e redondas, olhos pretos grandes com brilho, nariz preto, **dentes de castor grandes e brancos** visíveis.
- **Túnica verde** com gola, **capa verde mais escura**, **cinto marrom com fivela dourada**, **broche de folha verde** no peito.
- **Cauda achatada marrom escura com textura quadriculada**.
- **Espada de lâmina prateada** com guarda dourada/marrom, segurada na mão direita.

## 3. Especificação do sprite sheet

### Formato

| Item | Valor |
| :--- | :--- |
| Arquivo | `beaver-knight-app/Sprites/beaver_knight/beaver_knight_sheet.png` |
| Tamanho do quadro | **48×48 px** (personagem com ~28 px de altura, aprox. 2 tiles; sobra espaço para o arco da espada no ataque) |
| Grade | **4 colunas × 9 linhas** → imagem de **192×432 px** |
| Âncora | Pés no centro inferior de todo quadro: **pixel (24, 44)**. Assim, no Godot, basta `centered = true` com `offset = (0, -20)` (ou equivalente), sem números "mágicos" |
| Fundo | Transparente |
| Paleta | Até **16 cores** (15 + transparência, como uma paleta de sprite do GBA), contorno escuro de 1 px, sombreamento simples de 2–3 tons por material |
| Esquerda | **Não incluída**: o Godot espelha a linha "direita" com `flip_h` |

### Organização (linhas × colunas)

| Linha | Animação | Quadros usados | Descrição |
| :-: | :--- | :-: | :--- |
| 0 | `idle_down` | 2 | Parado de frente, leve respiração (corpo desce 1 px) |
| 1 | `idle_up` | 2 | Parado de costas (capa e cauda visíveis) |
| 2 | `idle_right` | 2 | Parado de perfil |
| 3 | `walk_down` | 4 | Passo esq. → neutro → passo dir. → neutro (3 poses únicas, ciclo de 4, igual ao GBA) |
| 4 | `walk_up` | 4 | Idem, de costas |
| 5 | `walk_right` | 4 | Idem, de perfil, com balanço da cauda |
| 6 | `attack_down` | 4 | Preparação (espada erguida) → impacto (golpe para baixo, com rastro do corte) → recuperação → volta à guarda |
| 7 | `attack_up` | 4 | Idem, golpeando para cima |
| 8 | `attack_right` | 4 | Idem, golpeando para a direita |

Quadros não usados (colunas 2–3 das linhas de idle) ficam transparentes.

A espada aparece em **todos** os quadros: no idle e no walk ela fica na mão direita, apontada para cima/frente (na visão de costas aparece a ponta acima do ombro).

## 4. Como a arte será produzida

Não há ferramenta de desenho no ambiente, então o Claude vai **desenhar os pixels por código**:
- Um script Node.js (o Node 22 já está instalado; o Python não está) com cada quadro definido como uma **matriz de caracteres**, em que cada letra é uma cor da paleta. Isso deixa a arte legível e editável em texto.
- O script gera o PNG sem dependências externas (encoder PNG com o `zlib` nativo do Node).
- Também gera uma **prévia ampliada 6×** com grade e rótulos das linhas, para facilitar a sua revisão.

Local dos arquivos:

| Arquivo | Conteúdo |
| :--- | :--- |
| `ferramentas/sprites/gerar_beaver_knight.js` | Script gerador (fora do projeto Godot, para não ser importado) |
| `beaver-knight-app/Sprites/beaver_knight/beaver_knight_sheet.png` | Sprite sheet final |
| `contexto/implementacoes/imagens/beaver_knight_preview_6x.png` | Prévia ampliada para revisão |

**Limitação honesta:** pixel art desenhada por código, pixel a pixel, depende do olho de quem desenha. O resultado será um sprite coerente e limpo, mas pode não ter o acabamento de um artista. Por isso a entrega é feita **em etapas, com sua aprovação em cada uma** (seção 5), e a matriz de texto permite que o Rafael ou qualquer um da equipe ajuste quadros depois, ou use o PNG como base no Aseprite.

## 5. Passos de implementação

**Fase 1 — Protótipo (para validar o visual)**
1. Definir a paleta de 16 cores a partir da arte de abertura.
2. Desenhar só os 3 quadros de idle (`down`, `up`, `right`) e gerar a prévia ampliada.
3. **Parar e pedir sua aprovação** do visual (proporções, cores, espada). Ajustar até você aprovar.

**Fase 2 — Sprite sheet completo**
4. Desenhar os demais quadros: idle (2º quadro), walk e attack nas 3 direções.
5. Gerar `beaver_knight_sheet.png` + prévia e pedir sua revisão.

**Fase 3 — Integração no Godot → movida para um plano separado**

Decisão do usuário (2026-11-22): a integração será feita em um plano próprio, criado depois que a folha da Fase 2 for aprovada. Os passos abaixo ficam só como referência para esse plano futuro.

6. No `town.tscn`, apontar todas as animações do Player para a nova textura única (`hframes = 4`, `vframes = 9`), atualizar as tracks de `frame`, remover as trocas de textura/offset e usar `flip_h` para a esquerda.
7. Ajustar o `CollisionShape2D` e o ponto dos pés em `player.gd` para a nova âncora (resolve B05).
8. Manter as tracks de método existentes (`set_move` no fim do ataque e `tocar_SFXPasso` nos passos).

> As folhas antigas (`Sprites/standard/`, `Sprites/custom/`, `beaverSprite.png`) **não serão apagadas**; ficam até você decidir.

## 6. Riscos e impactos

- **Fases 1 e 2** só adicionam arquivos novos; nada no jogo muda.
- **Fase 3** mexe nas animações do Player em `town.tscn` (arquivo grande, gerado pelo editor). Risco de quebrar animações, o tempo do `set_move` ou a colisão com o terreno. Alternativa mais segura: fazer a Fase 3 pelo editor da Godot seguindo um passo a passo que eu escrevo.
- O personagem novo é menor (~28 px) que o atual; o alcance do ataque (12/28 px) e o tamanho da colisão podem precisar de ajuste fino.

## 7. Como testar

- **Fases 1 e 2:** abrir a prévia ampliada e conferir cada linha; abrir o PNG na Godot (Sprite2D com `hframes = 4`, `vframes = 9`) e percorrer os quadros.
- **Fase 3:** rodar o jogo (`F5`), andar nas 4 direções (conferir o espelhamento da esquerda), atacar nas 4 direções, verificar se o movimento volta após o ataque, se o som de passo continua sincronizado e se o castor ainda para nas margens da água no ponto certo.

## 8. Commits previstos

```
feat(player): adiciona sprite sheet do BeaverKnight no estilo GBA
```

```
chore(contexto): documenta novo sprite sheet do BeaverKnight
```

## 9. Validação do usuário

- [ ] Plano aprovado pelo usuário
- Decisões do usuário (2026-11-22):
  - Tamanho do quadro: **48×48** confirmado.
  - **Fase 3** (integração no Godot): **separada** em outro plano, após a aprovação da folha. Este plano cobre só as Fases 1 e 2, e o commit previsto é apenas o da folha + documentação.
- Observações/ajustes pedidos:
