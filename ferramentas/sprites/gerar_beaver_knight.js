// Gerador do sprite sheet do BeaverKnight (estilo GBA).
// Uso: node ferramentas/sprites/gerar_beaver_knight.js [--prototipo]
//
// Cada parte do personagem é uma matriz de caracteres (uma letra = uma cor da paleta).
// As partes são desenhadas SEM contorno; o contorno escuro de 1 px é gerado automaticamente.
// Quadro: 48x48 px, pés ancorados no pixel (24, 44).

const fs = require('fs');
const path = require('path');
const zlib = require('zlib');

// ---------------------------------------------------------------------------
// Paleta (15 cores + transparente, como uma paleta de sprite do GBA)
// ---------------------------------------------------------------------------
const PALETA = {
  '.': null,               // transparente
  k: [40, 24, 16],         // contorno
  B: [110, 58, 28],        // pelo sombra
  b: [158, 94, 46],        // pelo base
  l: [212, 150, 92],       // pelo claro (focinho, patas)
  n: [24, 16, 14],         // olhos / nariz
  w: [252, 252, 244],      // dentes / brilho do olho
  G: [26, 70, 40],         // capa (verde escuro)
  g: [72, 158, 66],        // túnica (verde)
  h: [144, 210, 96],       // túnica (verde claro)
  y: [232, 184, 48],       // dourado (fivela, broche, guarda)
  t: [92, 52, 26],         // cinto / cabo da espada
  T: [70, 38, 20],         // cauda escura
  s: [236, 242, 250],      // lâmina clara
  S: [150, 164, 184],      // lâmina sombra
};

const QUADRO = 48;
const COLUNAS = 4;
const LINHAS = 9;

// ---------------------------------------------------------------------------
// Partes (sem contorno)
// ---------------------------------------------------------------------------
const P = {
  // ----- Frente (baixo) -----
  cabeca_frente: [
    '.BlB......BlB.',
    '.BBbbbbbbbbBB.',
    '.bbbbbbbbbbbb.',
    'bbBBbbbbbbBBbb',
    'bbbwnbbbbnwbbb',
    'bbbnnbbbbnnbbb',
    'BbllbllllbllbB',
    'BbllllnnllllbB',
    'BBbllllllllbBB',
    '.BBlllkklllBB.',
    '..BBllwwllBB..',
    '...BBbwwbBB...',
  ],
  corpo_frente: [
    'GgggyhhygggG',
    'GhgggyyggghG',
    'GhgggggggghG',
    'GttttyyttttG',
    'GhgggggggghG',
    'Ghhhh..hhhhG',
  ],
  perna_frente_esq: ['BBb', 'bll'],
  perna_frente_dir: ['bBB', 'llb'],
  cauda_frente: [
    '.BT',
    'BTB',
    'TBT',
    '.B.',
  ],
  braco_frente_erguido: [
    'bl..',
    'bbg.',
    '.ggg',
    '..gg',
  ],
  braco_frente_baixo: [
    'gg',
    'gg',
    'bb',
    'lb',
  ],

  // ----- Costas (cima) -----
  cabeca_costas: [
    '.BlB......BlB.',
    '.BBbbbbbbbbBB.',
    '.bbbbllllbbbb.',
    'bbbbbbllbbbbbb',
    'bbbbbbbbbbbbbb',
    'BbbbbbbbbbbbbB',
    'BbbbbbbbbbbbbB',
    'BBbbbbbbbbbbBB',
    'BBbbbbbbbbbbBB',
    '.BBbbbbbbbbBB.',
    '..BBBbbbbBBB..',
    '...BBBBBBBB...',
  ],
  corpo_costas: [
    'gGGGGGGGGGGg',
    'GGGGGgGGGGGG',
    'GGGGGgGGGGGG',
    'tGGGGgGGGGGt',
    'gGGGGgGGGGGg',
    'hhhhh..hhhhh',
  ],
  perna_costas_esq: ['BBb', 'BBb'],
  perna_costas_dir: ['bBB', 'bBB'],
  cauda_costas: [
    'BTBT',
    'TBTB',
    'BTBT',
  ],
  braco_costas_erguido: [
    '..lb',
    '.gbb',
    'ggg.',
    'gg..',
  ],
  braco_costas_baixo: [
    'gg',
    'gg',
    'bb',
    'bB',
  ],

  // ----- Perfil (direita) -----
  cabeca_perfil: [
    '...BlB..........',
    '..BBbbbbbbb.....',
    '.bbbbbbbbbbbb...',
    'bbbbbbbbbBBbbb..',
    'bbbbbbbbbbwnbbb.',
    'Bbbbbbbbbbnnbbbb',
    'Bbbbbbbbbbllllll',
    'Bbbbbbbbblllllnn',
    'BBbbbbbbbllllll.',
    '.BBbbbbbblkkkk..',
    '..BBBbbbbbbww...',
    '....BBBBBB.ww...',
  ],
  corpo_perfil: [
    'GGggggghy',
    'GGghggggg',
    'GGghggggg',
    'GGtttttyt',
    'GGghggggg',
    'GGhhhhhhh',
  ],
  pernas_perfil: [
    'BBbbbb.',
    'bbblll.',
  ],
  // passo A: perna da frente (clara) adiante; passo C: perna de trás (escura) adiante
  pernas_perfil_A: [
    'BBb..bbb.',
    'BBl..bbll',
  ],
  pernas_perfil_C: [
    'bbb..BBb.',
    'bbl..BBll',
  ],
  cauda_perfil: [
    '.BTBTBTB',
    'BTBTBTBT',
    '.BTBTBTB',
  ],
  braco_perfil_frente: [
    '.ggggbl',
    'gggggbl',
  ],
  braco_perfil_tras: [
    'BB',
    'BB',
  ],
};

// ---------------------------------------------------------------------------
// Desenho
// ---------------------------------------------------------------------------
function novaCamada() {
  return Array.from({ length: QUADRO }, () => Array(QUADRO).fill('.'));
}

function espelhar(parte) {
  return parte.map((linha) => linha.split('').reverse().join(''));
}

// Desenha uma parte na camada (sem contorno)
function carimbar(camada, parte, x, y) {
  parte.forEach((linha, dy) => {
    for (let dx = 0; dx < linha.length; dx++) {
      const c = linha[dx];
      if (c === '.') continue;
      const px = x + dx, py = y + dy;
      if (px >= 0 && py >= 0 && px < QUADRO && py < QUADRO) camada[py][px] = c;
    }
  });
}

// Compõe uma camada sobre o quadro, gerando contorno 'k' em volta (4-vizinhança).
// modoContorno: 'sobre' = contorno pinta por cima de tudo; 'sob' = só onde o quadro está vazio.
function compor(quadro, camada, modoContorno = 'sobre') {
  const contorno = [];
  for (let y = 0; y < QUADRO; y++) {
    for (let x = 0; x < QUADRO; x++) {
      if (camada[y][x] !== '.') continue;
      const viz = [[1, 0], [-1, 0], [0, 1], [0, -1]].some(([dx, dy]) => {
        const nx = x + dx, ny = y + dy;
        return nx >= 0 && ny >= 0 && nx < QUADRO && ny < QUADRO && camada[ny][nx] !== '.';
      });
      if (viz) contorno.push([x, y]);
    }
  }
  for (const [x, y] of contorno) {
    if (modoContorno === 'sobre' || quadro[y][x] === '.') quadro[y][x] = 'k';
  }
  for (let y = 0; y < QUADRO; y++)
    for (let x = 0; x < QUADRO; x++)
      if (camada[y][x] !== '.') quadro[y][x] = camada[y][x];
}

// Desenha uma parte com contorno automático
function parte(quadro, nome, x, y, opcoes = {}) {
  const camada = novaCamada();
  carimbar(camada, opcoes.espelhar ? espelhar(P[nome]) : P[nome], x, y);
  compor(quadro, camada, opcoes.contorno || 'sobre');
}

// Espada procedural.
// (hx, hy) = pixel do cabo na mão; (dx, dy) = direção da lâmina (-1..1); comp = comprimento da lâmina.
function espada(quadro, hx, hy, dx, dy, comp = 10, opcoes = {}) {
  const camada = novaCamada();
  const pinta = (x, y, c) => {
    if (x >= 0 && y >= 0 && x < QUADRO && y < QUADRO) camada[y][x] = c;
  };
  const diagonal = dx !== 0 && dy !== 0;
  const largura = diagonal ? [1, 0] : dx === 0 ? [1, 0] : [0, 1];
  const perp = [-dy, dx];

  // cabo e pomo
  pinta(hx, hy, 't');
  pinta(hx + largura[0], hy + largura[1], 't');
  pinta(hx - dx, hy - dy, 't');
  pinta(hx - dx + largura[0], hy - dy + largura[1], 't');
  if (opcoes.pomo !== false) pinta(hx - 2 * dx, hy - 2 * dy, 'y');

  // guarda
  const gx = hx + dx, gy = hy + dy;
  const ini = diagonal ? -1 : -2, fim = diagonal ? 1 : 3;
  for (let k = ini; k <= fim; k++) pinta(gx + perp[0] * k, gy + perp[1] * k, 'y');

  // lâmina (2 px: clara + sombra) e ponta
  for (let i = 2; i < 2 + comp; i++) {
    const bx = hx + dx * i, by = hy + dy * i;
    pinta(bx, by, 's');
    pinta(bx + largura[0], by + largura[1], 'S');
  }
  pinta(hx + dx * (2 + comp), hy + dy * (2 + comp), 's');

  compor(quadro, camada, opcoes.contorno || 'sobre');
}

// ---------------------------------------------------------------------------
// Quadros
// ---------------------------------------------------------------------------
// Braço procedural: manga verde do ombro até a mão (pincel 2x2), com contorno.
function braco(quadro, sx, sy, hx, hy) {
  const camada = novaCamada();
  const passos = Math.max(Math.abs(hx - sx), Math.abs(hy - sy), 1);
  for (let i = 0; i <= passos; i++) {
    const x = Math.round(sx + ((hx - sx) * i) / passos);
    const y = Math.round(sy + ((hy - sy) * i) / passos);
    for (const [ox, oy] of [[0, 0], [1, 0], [0, 1], [1, 1]]) {
      const px = x + ox, py = y + oy;
      if (px >= 0 && py >= 0 && px < QUADRO && py < QUADRO) camada[py][px] = 'g';
    }
  }
  compor(quadro, camada, 'sobre');
}

// Pata segurando o cabo: cobre o cabo da espada (mesma geometria da função espada).
function pata(quadro, hx, hy, dx, dy) {
  const camada = novaCamada();
  const diagonal = dx !== 0 && dy !== 0;
  const largura = diagonal ? [1, 0] : dx === 0 ? [1, 0] : [0, 1];
  const pts = [
    [hx, hy, 'l'], [hx + largura[0], hy + largura[1], 'b'],
    [hx - dx, hy - dy, 'b'], [hx - dx + largura[0], hy - dy + largura[1], 'B'],
  ];
  for (const [x, y, c] of pts) if (x >= 0 && y >= 0 && x < QUADRO && y < QUADRO) camada[y][x] = c;
  compor(quadro, camada, 'sob');
}

// Rastro do golpe: arco de círculo (graus; 0 = direita, 90 = baixo), sem contorno.
// Só pinta pixels vazios, então fica "atrás" do personagem.
function rastro(quadro, cx, cy, raio, a0, a1) {
  const passo = a1 > a0 ? 1 : -1;
  const total = Math.abs(a1 - a0);
  for (let a = a0; a !== a1 + passo; a += passo) {
    const r = (a * Math.PI) / 180;
    const grosso = Math.abs(a - a0) > total * 0.5; // mais grosso no fim do golpe
    for (let d = 0; d < (grosso ? 3 : 2); d++) {
      const x = Math.round(cx + Math.cos(r) * (raio - d));
      const y = Math.round(cy + Math.sin(r) * (raio - d));
      if (x >= 0 && y >= 0 && x < QUADRO && y < QUADRO && quadro[y][x] === '.') {
        quadro[y][x] = d === 0 ? 'w' : 'S';
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Montagem dos quadros por direção
// ---------------------------------------------------------------------------
// Opções:
//   pernas: [dyEsq, dyDir] (frente/costas) ou 'A' / 'C' (perfil)
//   livre:  deslocamento vertical do braço livre
//   cauda:  deslocamento da cauda
//   arma:   deslocamento vertical da espada na pose de guarda (idle/walk)
//   espada: [hx, hy, dx, dy, comp] + ombro: [x, y]  -> braço procedural (ataque)
//   rastro: [cx, cy, raio, anguloInicial, anguloFinal]

function montarFrente(q, o = {}) {
  const [pe, pd] = o.pernas || [0, 0];
  const dyArma = o.arma || 0;
  parte(q, 'cauda_frente', 31, 39 + (o.cauda || 0));
  parte(q, 'perna_frente_esq', 20, 42 + pe);
  parte(q, 'perna_frente_dir', 25, 42 + pd);
  parte(q, 'corpo_frente', 18, 35);
  parte(q, 'braco_frente_baixo', 30, 35 + (o.livre || 0));
  parte(q, 'cabeca_frente', 17, 22);
  if (o.espada) {
    const [hx, hy, dx, dy, comp] = o.espada;
    braco(q, o.ombro[0], o.ombro[1], hx, hy);
    espada(q, hx, hy, dx, dy, comp);
    pata(q, hx, hy, dx, dy);
  } else {
    espada(q, 13, 31 + dyArma, 0, -1, 10);
    parte(q, 'braco_frente_erguido', 13, 31 + dyArma, { contorno: 'sob' });
  }
  if (o.rastro) rastro(q, ...o.rastro);
}

function montarCostas(q, o = {}) {
  const [pe, pd] = o.pernas || [0, 0];
  const dyArma = o.arma || 0;
  parte(q, 'perna_costas_esq', 20, 42 + pe);
  parte(q, 'perna_costas_dir', 25, 42 + pd);
  parte(q, 'corpo_costas', 18, 35);
  parte(q, 'braco_costas_baixo', 16, 35 + (o.livre || 0));
  parte(q, 'cauda_costas', 22 + (o.cauda || 0), 40);
  parte(q, 'cabeca_costas', 17, 22);
  if (o.espada) {
    const [hx, hy, dx, dy, comp] = o.espada;
    braco(q, o.ombro[0], o.ombro[1], hx, hy);
    espada(q, hx, hy, dx, dy, comp);
    pata(q, hx, hy, dx, dy);
  } else {
    espada(q, 33, 31 + dyArma, 0, -1, 10);
    parte(q, 'braco_costas_erguido', 31, 31 + dyArma, { contorno: 'sob' });
  }
  if (o.rastro) rastro(q, ...o.rastro);
}

function montarPerfil(q, o = {}) {
  const dyArma = o.arma || 0;
  parte(q, 'cauda_perfil', 10, 39 + (o.cauda || 0));
  if (o.pernas === 'A') parte(q, 'pernas_perfil_A', 17, 42);
  else if (o.pernas === 'C') parte(q, 'pernas_perfil_C', 17, 42);
  else parte(q, 'pernas_perfil', 19, 42);
  parte(q, 'corpo_perfil', 18, 35);
  parte(q, 'cabeca_perfil', 15, 22);
  if (o.espada) {
    const [hx, hy, dx, dy, comp] = o.espada;
    braco(q, o.ombro[0], o.ombro[1], hx, hy);
    espada(q, hx, hy, dx, dy, comp);
    pata(q, hx, hy, dx, dy);
  } else {
    espada(q, 32, 38 + dyArma, 1, -1, 8);
    parte(q, 'braco_perfil_frente', 25, 37 + dyArma, { contorno: 'sob' });
  }
  if (o.rastro) rastro(q, ...o.rastro);
}

const QUADROS = {
  // Idle: 2 quadros (no 2º a espada e o braço livre descem 1 px e a cauda balança)
  idle_down_0: (q) => montarFrente(q),
  idle_down_1: (q) => montarFrente(q, { arma: 1, livre: 1, cauda: 1 }),
  idle_up_0: (q) => montarCostas(q),
  idle_up_1: (q) => montarCostas(q, { arma: 1, livre: 1, cauda: 1 }),
  idle_right_0: (q) => montarPerfil(q),
  idle_right_1: (q) => montarPerfil(q, { arma: 1, cauda: 1 }),

  // Walk: passo esq. -> neutro -> passo dir. -> neutro
  walk_down_0: (q) => montarFrente(q, { pernas: [-1, 0], livre: -1, arma: 1, cauda: -1 }),
  walk_down_1: (q) => montarFrente(q),
  walk_down_2: (q) => montarFrente(q, { pernas: [0, -1], livre: 1, arma: -1, cauda: 1 }),
  walk_down_3: (q) => montarFrente(q),
  walk_up_0: (q) => montarCostas(q, { pernas: [-1, 0], livre: 1, arma: -1, cauda: -1 }),
  walk_up_1: (q) => montarCostas(q),
  walk_up_2: (q) => montarCostas(q, { pernas: [0, -1], livre: -1, arma: 1, cauda: 1 }),
  walk_up_3: (q) => montarCostas(q),
  walk_right_0: (q) => montarPerfil(q, { pernas: 'A', arma: -1, cauda: 1 }),
  walk_right_1: (q) => montarPerfil(q),
  walk_right_2: (q) => montarPerfil(q, { pernas: 'C', arma: 1, cauda: 1 }),
  walk_right_3: (q) => montarPerfil(q),

  // Attack: preparação -> impacto (com rastro) -> recuperação -> guarda
  attack_down_0: (q) => montarFrente(q, { ombro: [18, 35], espada: [14, 29, -1, -1, 8] }),
  attack_down_1: (q) => montarFrente(q, { ombro: [18, 35], espada: [14, 39, -1, 1, 4], rastro: [24, 34, 14, 200, 115] }),
  attack_down_2: (q) => montarFrente(q, { ombro: [18, 35], espada: [16, 40, 0, 1, 3] }),
  attack_down_3: (q) => montarFrente(q),
  attack_up_0: (q) => montarCostas(q, { ombro: [29, 35], espada: [34, 29, 1, -1, 8] }),
  attack_up_1: (q) => montarCostas(q, { ombro: [29, 35], espada: [33, 25, 0, -1, 10], rastro: [24, 26, 17, -20, -160] }),
  attack_up_2: (q) => montarCostas(q, { ombro: [29, 35], espada: [33, 27, -1, -1, 7] }),
  attack_up_3: (q) => montarCostas(q),
  attack_right_0: (q) => montarPerfil(q, { ombro: [23, 36], espada: [33, 31, 0, -1, 9] }),
  attack_right_1: (q) => montarPerfil(q, { ombro: [23, 36], espada: [34, 37, 1, 0, 9], rastro: [30, 37, 16, -70, 50] }),
  attack_right_2: (q) => montarPerfil(q, { ombro: [23, 36], espada: [33, 39, 1, 1, 5] }),
  attack_right_3: (q) => montarPerfil(q),
};

// Layout final da folha: linha -> lista de quadros (null = vazio)
const LAYOUT = [
  ['idle_down_0', 'idle_down_1'],
  ['idle_up_0', 'idle_up_1'],
  ['idle_right_0', 'idle_right_1'],
  ['walk_down_0', 'walk_down_1', 'walk_down_2', 'walk_down_3'],
  ['walk_up_0', 'walk_up_1', 'walk_up_2', 'walk_up_3'],
  ['walk_right_0', 'walk_right_1', 'walk_right_2', 'walk_right_3'],
  ['attack_down_0', 'attack_down_1', 'attack_down_2', 'attack_down_3'],
  ['attack_up_0', 'attack_up_1', 'attack_up_2', 'attack_up_3'],
  ['attack_right_0', 'attack_right_1', 'attack_right_2', 'attack_right_3'],
];

function renderizarQuadro(nome) {
  const q = novaCamada();
  if (QUADROS[nome]) QUADROS[nome](q);
  return q;
}

// ---------------------------------------------------------------------------
// PNG (encoder mínimo, RGBA 8 bits)
// ---------------------------------------------------------------------------
const TABELA_CRC = (() => {
  const t = new Uint32Array(256);
  for (let n = 0; n < 256; n++) {
    let c = n;
    for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
    t[n] = c >>> 0;
  }
  return t;
})();

function crc32(buf) {
  let c = 0xffffffff;
  for (const b of buf) c = TABELA_CRC[(c ^ b) & 0xff] ^ (c >>> 8);
  return (c ^ 0xffffffff) >>> 0;
}

function bloco(tipo, dados) {
  const tam = Buffer.alloc(4);
  tam.writeUInt32BE(dados.length);
  const tipoBuf = Buffer.from(tipo, 'ascii');
  const crc = Buffer.alloc(4);
  crc.writeUInt32BE(crc32(Buffer.concat([tipoBuf, dados])));
  return Buffer.concat([tam, tipoBuf, dados, crc]);
}

function salvarPNG(arquivo, largura, altura, pixel) {
  const bruto = Buffer.alloc((largura * 4 + 1) * altura);
  let o = 0;
  for (let y = 0; y < altura; y++) {
    bruto[o++] = 0;
    for (let x = 0; x < largura; x++) {
      const [r, g, b, a] = pixel(x, y);
      bruto[o++] = r; bruto[o++] = g; bruto[o++] = b; bruto[o++] = a;
    }
  }
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(largura, 0);
  ihdr.writeUInt32BE(altura, 4);
  ihdr[8] = 8; ihdr[9] = 6; ihdr[10] = 0; ihdr[11] = 0; ihdr[12] = 0;
  const png = Buffer.concat([
    Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]),
    bloco('IHDR', ihdr),
    bloco('IDAT', zlib.deflateSync(bruto, { level: 9 })),
    bloco('IEND', Buffer.alloc(0)),
  ]);
  fs.mkdirSync(path.dirname(arquivo), { recursive: true });
  fs.writeFileSync(arquivo, png);
  console.log(`gerado: ${path.relative(process.cwd(), arquivo)} (${largura}x${altura})`);
}

function cor(c) {
  const rgb = PALETA[c];
  return rgb ? [...rgb, 255] : [0, 0, 0, 0];
}

// Prévia ampliada: linha de cima em xadrez, linha de baixo sobre grama (como no jogo)
function salvarPrevia(arquivo, nomes, escala) {
  const quadros = nomes.map(renderizarQuadro);
  const larg = nomes.length * QUADRO * escala;
  const alt = 2 * QUADRO * escala;
  salvarPNG(arquivo, larg, alt, (x, y) => {
    const qi = Math.floor(x / (QUADRO * escala));
    const fx = Math.floor((x % (QUADRO * escala)) / escala);
    const linhaPrevia = Math.floor(y / (QUADRO * escala));
    const fy = Math.floor((y % (QUADRO * escala)) / escala);
    if (x % (QUADRO * escala) === 0 || y % (QUADRO * escala) === 0) return [200, 40, 40, 255];
    const c = quadros[qi][fy][fx];
    if (c !== '.') return cor(c);
    if (linhaPrevia === 1) return [92, 148, 64, 255];
    return (Math.floor(fx / 4) + Math.floor(fy / 4)) % 2 ? [214, 214, 214, 255] : [236, 236, 236, 255];
  });
}

// ---------------------------------------------------------------------------
// Execução
// ---------------------------------------------------------------------------
const RAIZ = path.resolve(__dirname, '..', '..');
const prototipo = process.argv.includes('--prototipo');

// --quadros=nome1,nome2 --saida=arquivo.png : prévia 6x só dos quadros indicados (útil para revisar)
const argQuadros = process.argv.find((a) => a.startsWith('--quadros='));
if (argQuadros) {
  const saida = (process.argv.find((a) => a.startsWith('--saida=')) || '--saida=previa_quadros.png').slice(8);
  salvarPrevia(path.resolve(saida), argQuadros.slice(10).split(','), 6);
} else if (prototipo) {
  const nomes = ['idle_down_0', 'idle_up_0', 'idle_right_0'];
  salvarPrevia(path.join(RAIZ, 'contexto/implementacoes/imagens/beaver_knight_prototipo_6x.png'), nomes, 6);
  salvarPrevia(path.join(RAIZ, 'contexto/implementacoes/imagens/beaver_knight_prototipo_2x.png'), nomes, 2);
} else {
  const cache = {};
  const quadroDe = (l, c) => {
    const nome = LAYOUT[l][c];
    if (!nome) return null;
    return (cache[nome] ??= renderizarQuadro(nome));
  };
  salvarPNG(
    path.join(RAIZ, 'beaver-knight-app/Sprites/beaver_knight/beaver_knight_sheet.png'),
    COLUNAS * QUADRO, LINHAS * QUADRO,
    (x, y) => {
      const q = quadroDe(Math.floor(y / QUADRO), Math.floor(x / QUADRO));
      return q ? cor(q[y % QUADRO][x % QUADRO]) : [0, 0, 0, 0];
    },
  );

  // Prévia da folha inteira ampliada 4x (xadrez, grade vermelha entre quadros)
  const escala = 4;
  salvarPNG(
    path.join(RAIZ, 'contexto/implementacoes/imagens/beaver_knight_sheet_previa_4x.png'),
    COLUNAS * QUADRO * escala, LINHAS * QUADRO * escala,
    (x, y) => {
      if (x % (QUADRO * escala) === 0 || y % (QUADRO * escala) === 0) return [200, 40, 40, 255];
      const fx = Math.floor(x / escala), fy = Math.floor(y / escala);
      const q = quadroDe(Math.floor(fy / QUADRO), Math.floor(fx / QUADRO));
      const c = q ? q[fy % QUADRO][fx % QUADRO] : '.';
      if (c !== '.') return cor(c);
      const lx = fx % QUADRO, ly = fy % QUADRO;
      return (Math.floor(lx / 4) + Math.floor(ly / 4)) % 2 ? [214, 214, 214, 255] : [236, 236, 236, 255];
    },
  );
}
