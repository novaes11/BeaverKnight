# Implementação: Ajustes do feedback de gameplay

| Campo | Valor |
| :--- | :--- |
| Data | 2026-11-23 |
| Tipo | `fix` (spawn e áudio) + `feat` (boss e pausa) |
| Pendências | B14, B15, F11, F12 |
| Plano | [`planos/2026-11-23-feedback-gameplay.md`](../planos/2026-11-23-feedback-gameplay.md) |
| Commit(s) | _(preencher após o commit)_ |

## O que foi feito

### Refinaria
- As duas zonas viraram **uma só** (`ZonaRefinaria`), com **16 slimes** e até 5 ao mesmo tempo.
- `nascer_perto`: o slime nasce a 190–280 px do jogador, fora da tela, com caminho de até 460 px.
- `cacar_jogador`: o slime já nasce indo atrás do jogador pelo A*. Se não houver rota (jogador na praia), ele para e aguarda.

### Boss

A proposta A ficou forte demais no teste do usuário (3 derrotas seguidas). Os valores abaixo são o ajuste final: a pancada continua punindo quem fica parado, mas tem aviso maior, e o restante da luta ficou mais justo.

| Atributo | Original | Proposta A | **Final** |
| :--- | :-: | :-: | :-: |
| Vida | 800 | 1200 | **1050** |
| Dano da pancada | 18 | 26 | **27** |
| Dano do cuspe | 8 | 12 | **7** |
| Aviso da pancada | 0,8 s | 0,8 s | **1,0 s** |
| Recuperação (normal / fúria) | 1,1 / 0,85 s | 0,9 / 0,7 s | **1,1 / 0,9 s** |
| Intervalo (normal / fúria) | 1,5 / 1,1 s | 1,2 / 0,85 s | **1,4 / 1,05 s** |
| Cura na fúria | 30 | 20 | **35** |

### Áudio
- Só na Web, `AudioManager` soma **+14 dB** ao barramento `Music` e **+8 dB** ao `Effect`. O som do desktop não muda.
- O `AudioManager` agora roda com `PROCESS_MODE_ALWAYS`, para a música e os botões continuarem nas telas pausadas.

### Nitidez das letras
- `window/stretch/mode` mudou de `viewport` para `canvas_items`. Antes o jogo desenhava tudo em 320×180 e ampliava a imagem, borrando o texto. Agora o texto é renderizado na resolução real da tela, e a pixel art continua com filtro Nearest.

### Tremor ao andar (efeito colateral da nitidez)
- **Causa:** com `canvas_items`, o sprite continua preso ao pixel do mundo (`snap_2d_transforms_to_pixel`), mas a câmera passou a aceitar frações. A 100 px/s, o castor oscilava até 2,67 px reais na tela em todos os quadros. A lógica de movimento não havia mudado.
- **Correção:** `player.gd` alinha a posição local da `Camera2D` ao mesmo arredondamento do sprite, logo após `move_and_slide()`. O texto continua nítido.
- **Medição (120 quadros, nos dois sentidos da horizontal e na vertical):** quadros com tremor foram de **119 para 0**, e a rolagem do mapa voltou ao mesmo padrão do modo `viewport`.

### Tela de pausa
- `Esc` ou `P` (ação `pausar`) abre `Scene/tela_pausa.tscn`, com **Continuar**, **Reiniciar Partida** e **Menu Principal**.
- Não abre na transição da caverna, com o jogador morto nem nas telas finais.
- `Como Jogar` e a tela de missão mencionam a pausa.

## Verificação

| Medida | Antes | Depois |
| :--- | :-: | :-: |
| Slimes alcançam o jogador parado na refinaria | nunca em 60 s | **sim** |
| Boss, jogador parado só batendo | vence (vida 50) | **perde em 21 s** |
| Boss, robô desviando da pancada | vence (vida 92) | **vence em 29 s (vida 86)** |
| Boss, simulação com reação humana (erra 25% dos desvios) | — | **8 de 8 vitórias, vida média 64** |
| Boss, simulação de iniciante (erra 50% dos desvios) | — | **5 de 8 vitórias** |
| Pico da música na Web (menu / combate) | -28 / -34 dB | **-14 / -20 dB** |
| Pico da espada na Web | -11 dB | **-3,5 dB** |

Picos dos demais efeitos na Web: dano -6,3 dB, morte do inimigo -4,1 dB, respawn -7,6 dB e passo -23,3 dB, todos sem saturar.

Testes de partida, mapa e jogador sem erros, incluindo pausa, retomada, reinício e bloqueio na tela final.

**Pendente de teste pelo usuário:** volume percebido no navegador, dificuldade real do boss e ritmo da refinaria.

## Pontos de atenção

- Cenas e scripts novos precisam entrar em `export_files`.
- Em tela cheia, o navegador usa `Esc` para sair da tela cheia; nesse caso use `P`.
- Os ganhos da Web ficam em `GANHO_WEB_MUSICA` e `GANHO_WEB_EFEITOS`, em `audio_manager.gd`.
