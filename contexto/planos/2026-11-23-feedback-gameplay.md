# Plano: Ajustes do feedback de gameplay

| Campo | Valor |
| :--- | :--- |
| Data | 2026-11-23 |
| Tipo | `fix` (spawn e áudio) + `feat` (boss e pausa) |
| Pendências | B14, B15, F11, F12 |
| Status | `Implementado` — aguardando teste do usuário na Web |

## 1. Objetivo

- O boss deixa de ser vencido ficando parado e batendo.
- O som da versão Web fica forte e claro.
- Na refinaria, os inimigos vão até o jogador e a etapa fica mais longa.
- `Esc` abre uma tela de pausa com continuar, reiniciar e voltar ao menu.

## 2. Diagnóstico

Medições feitas na Godot 4.7.1 e no navegador. Nenhum arquivo do jogo foi alterado.

### 2.1 Boss fraco

O robô de teste, parado ao lado do boss e só atacando, **vence em 19 s com 50 de vida**. Os ataques têm dano baixo e intervalos longos, e a cura da fúria compensa boa parte do dano recebido.

### 2.2 Som baixo na Web

| Trecho (pico) | Desktop | Web |
| :--- | :-: | :-: |
| Música do menu | -40 dB | -28 dB |
| Música de combate | -38 dB | -34 dB |

- **A mixagem do jogo está baixa nas duas versões.** Uma música de jogo costuma ficar perto de -14 dB.
- **O motor não está abaixando o som na Web:** testei também o outro modo de áudio da Godot para Web, e ele não ficou mais alto.
- **Não consegui reproduzir a diferença que você ouve.** A causa provável está fora do jogo, como o volume do navegador no Mixer do Windows, mas isso não foi confirmado.

### 2.3 Inimigos sumidos na refinaria

Com o jogador parado na refinaria por 60 s:

| Medida | Resultado |
| :--- | :-: |
| Inimigos que chegaram perto | **nenhum** |
| Distância média até o jogador | 181 a 248 px |
| Inimigos gerados na zona leste | **0 de 5** |

Três causas se somam:
1. Os slimes nascem a pelo menos 190 px, mas só enxergam a 110 px. Eles nascem e ficam patrulhando longe.
2. A zona leste só ativa com o jogador perto dela. Para concluir a etapa, é preciso atravessar a ponte sem nenhuma indicação.
3. A refinaria é grande, com dois lados separados pelo rio de petróleo.

## 3. Solução

### Fase 1: Refinaria (`fix`)
- Unificar a refinaria em **uma única zona de combate**.
- Slimes da refinaria nascem **em volta do jogador**, fora da tela, e **já partem atrás dele** usando o A*.
- Se o jogador voltar para a praia, eles param e aguardam.
- Meta sobe de **10 para 16 slimes**, com até 5 ao mesmo tempo.

### Fase 2: Boss mais forte (`feat`)

| Atributo | Hoje | Proposta A (recomendada) | Proposta B (difícil) |
| :--- | :-: | :-: | :-: |
| Vida | 800 | **1200** | 1400 |
| Dano da pancada | 18 | **26** | 30 |
| Dano do cuspe | 8 | **12** | 14 |
| Recuperação (normal / fúria) | 1,1 / 0,85 s | **0,9 / 0,7 s** | 0,8 / 0,6 s |
| Intervalo entre ataques (normal / fúria) | 1,5 / 1,1 s | **1,2 / 0,85 s** | 1,0 / 0,75 s |
| Cura ao entrar em fúria | 30 | **20** | 25 |

Resultado simulado:

| Jogador simulado | Hoje | A | B |
| :--- | :-: | :-: | :-: |
| **Parado, só batendo** | vence (vida 50) | **perde em 17 s** | perde em 10 s |
| **Desviando da pancada** | vence (vida 92) | **vence (vida 64)** | vence (vida 55) |

O robô não erra golpes e não desvia das gotas, então a luta real tende a ser mais longa.

### Fase 3: Áudio (`fix`)
- Aumentar o volume **só na versão Web**, sem mudar o som do desktop que você aprovou.
- Alvo de pico: música perto de **-14 dB** e efeitos perto de **-3 dB**, sem distorcer.
- Calibrar com o medidor no navegador, durante combate.

### Fase 4: Tela de pausa (`feat`)
- **`Esc` ou `P`** abre e fecha a pausa. O `P` é necessário porque, em tela cheia, o navegador usa o `Esc` para sair da tela cheia.
- Botões: **Continuar**, **Reiniciar Partida** e **Menu Principal**.
- O jogo, os inimigos e o cronômetro param durante a pausa.
- A pausa não abre durante a transição da caverna nem nas telas de vitória e derrota.
- `Como Jogar` e a tela de missão passam a mencionar a pausa.

## 4. Arquivos afetados

| Arquivo | Mudança |
| :--- | :--- |
| `Scripts/Character/Enemy/inimigo.gd` | Modo de caçada |
| `Scripts/Character/Enemy/enemy_spawn.gd`, `zona_spawn.gd` | Nascimento em volta do jogador |
| `Scripts/Character/Enemy/boss_petroleo.gd` | Novos valores |
| `Scripts/World/partida.gd` | Meta da refinaria e estado de pausa |
| `Scripts/World/audio_manager.gd` | Volume da versão Web |
| `Scripts/UI/tela_pausa.gd`, `Scene/tela_pausa.tscn` | **Novos** |
| `Scene/town.tscn` | Zona única e tela de pausa |
| `Scene/main_menu.tscn`, `Scripts/UI/tela_historia.gd` | Instruções |
| `project.godot` | Ação de pausa |
| `export_presets.cfg` | Inclui a tela de pausa |
| `ferramentas/testes/teste_combate_headless.gd` | Novos cenários |
| `docs/jogo/`, `docs/index.html`, `README.md` | Nova build e números atualizados |

## 5. Riscos

- **Áudio:** como não reproduzi a diferença, o resultado final depende do seu teste no navegador.
- **Dificuldade:** a refinaria fica mais intensa com slimes vindo até o jogador. Os valores são ajustáveis.
- **Pausa:** o áudio e os botões precisam continuar respondendo com o jogo pausado.

## 6. Como testar

**Automático:** parado perde para o boss, desviando vence, slimes alcançam o jogador na refinaria, 16 derrotas avançam a etapa, pausa congela e retoma, reiniciar zera a partida.

**Jogando na Web:**
1. Conferir o volume da música, da espada e do dano.
2. Na refinaria, esperar parado: os slimes devem vir até você.
3. Tentar vencer o boss parado, depois desviando.
4. Apertar `Esc` e testar os três botões.

## 7. Commits previstos

```
fix(enemy): faz os slimes da refinaria nascerem perto e caçarem o jogador
feat(boss): aumenta a dificuldade do Boss de Petróleo
fix(audio): aumenta o volume da versão Web
feat(ui): adiciona tela de pausa
chore(web): atualiza a build e a Landing Page
chore(contexto): documenta os ajustes de gameplay
```

## 8. Validação do usuário

- [x] Plano aprovado pelo usuário (2026-11-23)
- **Decisão: força do boss (2026-11-23):** proposta **A**, depois reduzida a pedido do usuário por ter ficado forte demais (valores finais na implementação).
- **Pedido adicional (2026-11-23):** deixar as letras do menu e do HUD mais nítidas.
- Observações/ajustes pedidos:
