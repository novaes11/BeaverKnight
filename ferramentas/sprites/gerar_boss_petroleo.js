// Gerador do sprite do Boss de Petróleo (design original do projeto).
// Uso: node ferramentas/sprites/gerar_boss_petroleo.js            (folha completa)
//      node ferramentas/sprites/gerar_boss_petroleo.js --prototipo (só o quadro aprovado)
// Quadro: 96x96 px, base da gosma em y = 90.

const fs = require('fs');
const path = require('path');
const zlib = require('zlib');

const QUADRO = 96;

// Paleta de 15 cores + transparente
const PALETA = {
  k: [5, 4, 8],          // contorno
  a: [9, 8, 12],        // gosma sombra
  b: [17, 15, 22],       // gosma base
  c: [29, 25, 35],       // gosma média
  d: [50, 44, 60],       // gosma clara
  e: [122, 114, 138],    // brilho oleoso
  f: [216, 208, 232],    // brilho forte
  r: [96, 10, 20],       // vermelho escuro
  R: [220, 28, 40],      // vermelho
  O: [255, 124, 72],     // olho quente
  m: [38, 5, 12],        // interior da boca
  t: [190, 178, 160],    // dentes
  u: [122, 66, 32],      // ferrugem
  U: [186, 110, 50],     // ferrugem clara
  p: [120, 132, 146],    // cano
};

const novoQuadro = () => Array.from({ length: QUADRO }, () => Array(QUADRO).fill('.'));
const dentro = (x, y) => x >= 0 && y >= 0 && x < QUADRO && y < QUADRO;
const elipse = (x, y, cx, cy, rx, ry) => ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 <= 1;

// --- Silhueta -------------------------------------------------------------
function topoCorpo(x) {
  const u = Math.abs(x - 48) / 37;
  if (u >= 1) return 200;
  const domo = 84 - 66 * Math.pow(1 - Math.pow(u, 2.5), 0.55);
  return domo + 1.7 * Math.sin(x * 0.42) + 1.1 * Math.sin(x * 0.17 + 1);
}

function naSilhueta(x, y) {
  if (y >= topoCorpo(x) && y <= 84) return true;
  // Poça da base, com lóbulos escorrendo
  const lobulo = 1.8 * Math.sin(x * 0.55) + 1.2 * Math.sin(x * 0.23 + 2);
  if (elipse(x, y, 48, 81, 45, 8.5 + lobulo * 0.35)) return true;
  // Braços de gosma caídos
  if (elipse(x, y, 13, 60, 8.5, 17) || elipse(x, y, 83, 58, 8.5, 18)) return true;
  if (elipse(x, y, 19, 45, 9, 9) || elipse(x, y, 77, 43, 9, 9)) return true;
  // Mãos escorrendo
  if (elipse(x, y, 10, 75, 6.5, 6) || elipse(x, y, 86, 74, 6.5, 6)) return true;
  // Pingos pendurados nos braços
  if (elipse(x, y, 6, 83, 2, 4) || elipse(x, y, 90, 82, 2, 4)) return true;
  return false;
}

// --- Sombreamento ---------------------------------------------------------
function tom(x, y) {
  const nx = (x - 48) / 46;
  const ny = (y - 48) / 46;
  const nz = Math.sqrt(Math.max(0, 1 - nx * nx - ny * ny));
  let luz = -0.5 * nx - 0.68 * ny + 0.54 * nz;
  // Escorridos verticais
  luz += 0.09 * Math.sin(x * 0.95 + Math.sin(y * 0.09) * 1.4) * Math.min(1, (y - 14) / 40);
  if (y > 74) luz -= 0.12;
  if (luz > 0.62) return 'd';
  if (luz > 0.34) return 'c';
  if (luz > 0.02) return 'b';
  return 'a';
}

function linha(q, x0, y0, x1, y1, c) {
  const n = Math.max(Math.abs(x1 - x0), Math.abs(y1 - y0), 1);
  for (let i = 0; i <= n; i++) {
    const x = Math.round(x0 + ((x1 - x0) * i) / n);
    const y = Math.round(y0 + ((y1 - y0) * i) / n);
    if (dentro(x, y)) q[y][x] = c;
  }
}

function poligono(q, pts, c) {
  const ys = pts.map((p) => p[1]);
  for (let y = Math.min(...ys); y <= Math.max(...ys); y++) {
    const cortes = [];
    for (let i = 0; i < pts.length; i++) {
      const [ax, ay] = pts[i];
      const [bx, by] = pts[(i + 1) % pts.length];
      if ((ay <= y && by > y) || (by <= y && ay > y)) cortes.push(ax + ((y - ay) / (by - ay)) * (bx - ax));
    }
    cortes.sort((a, b) => a - b);
    for (let i = 0; i + 1 < cortes.length; i += 2) {
      for (let x = Math.ceil(cortes[i]); x <= Math.floor(cortes[i + 1]); x++) if (dentro(x, y)) q[y][x] = c;
    }
  }
}

const espelhoX = (pts) => pts.map(([x, y]) => [95 - x, y]);

function olho(q, pts, nucleo, brilho) {
  poligono(q, pts.map(([x, y]) => [x, y]), 'r');
  poligono(q, nucleo, 'R');
  for (const [x, y] of brilho) q[y][x] = 'O';
}

function rosto(q) {
  // Cavidades escuras
  const cavidade = [[26, 31], [46, 41], [45, 51], [31, 49], [25, 40]];
  poligono(q, cavidade, 'k');
  poligono(q, espelhoX(cavidade), 'k');
  // Olhos vermelhos angulados
  const olhoE = [[28, 34], [44, 43], [43, 49], [33, 47], [28, 40]];
  const nucleoE = [[31, 37], [42, 44], [41, 47], [34, 45], [31, 41]];
  olho(q, olhoE, nucleoE, [[36, 42], [37, 42], [37, 43], [38, 43], [38, 44], [39, 44]]);
  olho(q, espelhoX(olhoE), espelhoX(nucleoE), [[59, 42], [58, 42], [58, 43], [57, 43], [57, 44], [56, 44]]);

  // Boca larga em zigue-zague
  const topo = [];
  const base = [];
  for (let x = 26; x <= 69; x++) {
    const curva = Math.round(3.5 * Math.pow((x - 47.5) / 21.5, 2));
    topo.push([x, 56 - curva]);
    base.push([x, 70 - curva * 2]);
  }
  poligono(q, [...topo, ...base.reverse()], 'k');
  const topoI = topo.slice(1, -1).map(([x, y]) => [x, y + 1]);
  const baseI = [];
  for (let x = 27; x <= 68; x++) baseI.push([x, 69 - Math.round(3.5 * Math.pow((x - 47.5) / 21.5, 2)) * 2]);
  poligono(q, [...topoI, ...baseI.reverse()], 'm');
  // Dentes de cima e de baixo, irregulares
  for (let x = 28, i = 0; x <= 65; x += 5, i++) {
    const y = 57 - Math.round(3.5 * Math.pow((x + 2 - 47.5) / 21.5, 2));
    const alt = 4 + (i % 3);
    poligono(q, [[x, y], [x + 4, y], [x + 2, y + alt]], 't');
  }
  for (let x = 31, i = 0; x <= 62; x += 5, i++) {
    const y = 68 - Math.round(3.5 * Math.pow((x + 2 - 47.5) / 21.5, 2)) * 2;
    const alt = 3 + ((i + 1) % 2);
    poligono(q, [[x, y], [x + 4, y], [x + 2, y - alt]], 't');
  }
}

function brilhos(q, mascara) {
  const pontos = (lista, c) => { for (const [x, y] of lista) if (dentro(x, y) && mascara[y][x]) q[y][x] = c; };
  // Reflexo oleoso curvo no topo
  for (let i = 0; i < 18; i++) {
    const a = 3.55 + i * 0.045;
    pontos([[Math.round(48 + Math.cos(a) * 25), Math.round(38 + Math.sin(a) * 22)]], 'e');
    if (i > 3 && i < 13) pontos([[Math.round(48 + Math.cos(a) * 24), Math.round(39 + Math.sin(a) * 21)]], 'f');
  }
  pontos([[57, 22], [58, 22], [59, 23], [60, 24]], 'e');
  // Reflexos dos braços e da poça
  pontos([[12, 48], [11, 49], [11, 50], [10, 52], [10, 53]], 'e');
  pontos([[80, 36], [81, 37], [82, 39]], 'e');
  for (const x of [17, 18, 19, 38, 39, 40, 41, 62, 63, 64, 76, 77]) pontos([[x, 80 + (x % 3 === 0 ? 1 : 0)]], 'd');
  pontos([[39, 80], [40, 80], [63, 80]], 'e');
}

function bolha(q, cx, cy, r) {
  for (let y = cy - r; y <= cy + r; y++) {
    for (let x = cx - r; x <= cx + r; x++) {
      const d = Math.hypot(x - cx, y - cy);
      if (!dentro(x, y) || d > r + 0.2) continue;
      q[y][x] = d > r - 0.8 ? 'd' : 'a';
    }
  }
  if (dentro(cx - 1, cy - 1)) q[cy - 1][cx - 1] = 'f';
}

function barril(q) {
  // Barril enferrujado afundado na gosma
  poligono(q, [[17, 66], [31, 63], [33, 79], [20, 82]], 'k');
  poligono(q, [[18, 67], [30, 64], [32, 78], [21, 81]], 'u');
  poligono(q, [[20, 67], [24, 66], [26, 79], [23, 80]], 'U');
  linha(q, 18, 71, 31, 68, 'k');
  linha(q, 20, 76, 32, 73, 'k');
  // Gosma escorrendo por cima
  poligono(q, [[17, 66], [31, 63], [30, 68], [27, 67], [26, 72], [24, 68], [21, 70], [19, 68]], 'b');
}

function cano(q) {
  // Pedaço de cano saindo do ombro
  poligono(q, [[66, 17], [79, 8], [83, 14], [71, 25]], 'k');
  poligono(q, [[67, 18], [79, 10], [81, 14], [71, 23]], 'p');
  linha(q, 68, 18, 79, 11, 'e');
  poligono(q, [[77, 7], [80, 6], [86, 14], [83, 16]], 'k');
  poligono(q, [[78, 8], [80, 8], [84, 14], [83, 15]], 'u');
  // Base do cano coberta de gosma
  poligono(q, [[62, 19], [69, 15], [74, 22], [70, 28], [64, 27]], 'b');
  linha(q, 66, 17, 71, 21, 'd');
}

function desenharParado() {
  const q = novoQuadro();
  const mascara = novoQuadro().map((l) => l.map(() => false));
  for (let y = 0; y < QUADRO; y++) {
    for (let x = 0; x < QUADRO; x++) {
      if (y <= 90 && naSilhueta(x, y)) {
        mascara[y][x] = true;
        q[y][x] = tom(x, y);
      }
    }
  }
  cano(q);
  barril(q);
  for (let y = 0; y < QUADRO; y++) for (let x = 0; x < QUADRO; x++) if (q[y][x] !== '.') mascara[y][x] = true;
  rosto(q);
  brilhos(q, mascara);
  bolha(q, 68, 34, 3);
  bolha(q, 22, 34, 2);
  bolha(q, 73, 66, 2);
  bolha(q, 46, 76, 2);

  // Contorno externo de 1 px
  const borda = [];
  for (let y = 0; y < QUADRO; y++) {
    for (let x = 0; x < QUADRO; x++) {
      if (q[y][x] !== '.') continue;
      if ([[1, 0], [-1, 0], [0, 1], [0, -1]].some(([a, b]) => dentro(x + a, y + b) && q[y + b][x + a] !== '.')) borda.push([x, y]);
    }
  }
  for (const [x, y] of borda) q[y][x] = 'k';
  return q;
}

// --- PNG ------------------------------------------------------------------
const TABELA = Array.from({ length: 256 }, (_, n) => {
  let c = n;
  for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
  return c >>> 0;
});
function crc32(buf) {
  let c = 0xffffffff;
  for (const b of buf) c = TABELA[(c ^ b) & 255] ^ (c >>> 8);
  return (c ^ 0xffffffff) >>> 0;
}
function bloco(tipo, dados) {
  const tam = Buffer.alloc(4);
  tam.writeUInt32BE(dados.length);
  const t = Buffer.from(tipo, 'ascii');
  const crc = Buffer.alloc(4);
  crc.writeUInt32BE(crc32(Buffer.concat([t, dados])));
  return Buffer.concat([tam, t, dados, crc]);
}
function salvarPNG(arquivo, q) {
  const bruto = Buffer.alloc((QUADRO * 4 + 1) * QUADRO);
  let o = 0;
  for (let y = 0; y < QUADRO; y++) {
    bruto[o++] = 0;
    for (let x = 0; x < QUADRO; x++) {
      const rgb = PALETA[q[y][x]];
      bruto[o++] = rgb ? rgb[0] : 0;
      bruto[o++] = rgb ? rgb[1] : 0;
      bruto[o++] = rgb ? rgb[2] : 0;
      bruto[o++] = rgb ? 255 : 0;
    }
  }
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(QUADRO, 0);
  ihdr.writeUInt32BE(QUADRO, 4);
  ihdr[8] = 8;
  ihdr[9] = 6;
  fs.mkdirSync(path.dirname(arquivo), { recursive: true });
  fs.writeFileSync(arquivo, Buffer.concat([
    Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]),
    bloco('IHDR', ihdr), bloco('IDAT', zlib.deflateSync(bruto, { level: 9 })), bloco('IEND', Buffer.alloc(0)),
  ]));
  console.log('gerado:', path.relative(process.cwd(), arquivo));
}

const RAIZ = path.resolve(__dirname, '..', '..');
// --- Animações -----------------------------------------------------------
// Todos os quadros nascem do desenho aprovado, deformado a partir da base (y = 90).
const BASE_Y = 90;

function deformar(base, o = {}) {
  const { sx = 1, sy = 1, inclina = 0, onda = 0, fase = 0, dx = 0 } = o;
  const q = novoQuadro();
  for (let y = 0; y < QUADRO; y++) {
    const altura = (BASE_Y - y) / 80;
    const desvio = inclina * altura + onda * Math.sin(y * 0.28 + fase) * Math.max(0, altura);
    for (let x = 0; x < QUADRO; x++) {
      const ox = Math.round(48 + (x - 48 - desvio - dx) / sx);
      const oy = Math.round(BASE_Y + (y - BASE_Y) / sy);
      if (dentro(ox, oy)) q[y][x] = base[oy][ox];
    }
  }
  return q;
}

const trocar = (q, mapa) => q.map((l) => l.map((c) => mapa[c] || c));
const CLARO = { a: 'c', b: 'd', c: 'd', d: 'e', k: 'a', r: 'R', R: 'O' };
const APAGADO = { R: 'r', O: 'R' };

// Boca aberta do cuspe, com brilho vermelho e gota de petróleo.
function bocaAberta(q, cx, cy, rx, ry, comGota) {
  for (let y = cy - ry - 1; y <= cy + ry + 1; y++) {
    for (let x = cx - rx - 1; x <= cx + rx + 1; x++) {
      if (!dentro(x, y)) continue;
      if (elipse(x, y, cx, cy, rx, ry)) q[y][x] = elipse(x, y, cx, cy + 1, rx * 0.55, ry * 0.5) ? 'r' : 'm';
      else if (elipse(x, y, cx, cy, rx + 1, ry + 1)) q[y][x] = 'k';
    }
  }
  for (let x = cx - rx + 2; x <= cx + rx - 3; x += 5) poligono(q, [[x, cy - ry + 1], [x + 3, cy - ry + 1], [x + 1, cy - ry + 4]], 't');
  if (comGota) {
    for (let y = cy - 4; y <= cy + 4; y++) {
      for (let x = cx - 4; x <= cx + 4; x++) if (elipse(x, y, cx, cy, 4, 4)) q[y][x] = 'a';
    }
    q[cy - 2][cx - 1] = 'e';
    q[cy - 1][cx - 2] = 'd';
  }
  return q;
}

function montarFolha() {
  const base = desenharParado();
  const d = (o) => deformar(base, o);
  return [
    // 0: parado
    [d(), d({ sx: 1.015, sy: 0.98 }), d({ sx: 1.03, sy: 0.955 }), d({ sx: 1.015, sy: 0.98 })],
    // 1: andar
    [d({ inclina: -3, sx: 0.98, sy: 1.02 }), d({ sx: 1.03, sy: 0.95, onda: 0.8 }), d({ inclina: 3, sx: 0.98, sy: 1.02 }), d({ sx: 1.03, sy: 0.95, onda: 0.8, fase: 3 })],
    // 2: pancada (prepara, sobe, impacto, recupera)
    [d({ sx: 1.03, sy: 0.88 }), d({ sx: 0.9, sy: 1.08 }), d({ sx: 1.04, sy: 0.72, onda: 1.2 }), d({ sx: 1.03, sy: 0.88 })],
    // 3: cuspe (recua, abre a boca, cospe, fecha)
    [d({ inclina: -4, sy: 1.03 }), bocaAberta(d({ inclina: -2, sy: 1.04 }), 47, 60, 15, 10, false), bocaAberta(d({ inclina: 3, sy: 0.96 }), 49, 64, 17, 11, true), d({ inclina: 1, sy: 0.98 })],
    // 4: dano
    [trocar(d({ sx: 1.03, sy: 0.94 }), CLARO), d({ sx: 0.99, sy: 1.01, inclina: 2 })],
    // 5: morte (derrete até virar poça)
    [
      trocar(d({ sx: 1.02, sy: 0.92, onda: 1 }), CLARO),
      trocar(d({ sx: 1.03, sy: 0.78, onda: 1.5 }), APAGADO),
      trocar(d({ sx: 1.04, sy: 0.6, onda: 2, fase: 1 }), APAGADO),
      trocar(d({ sx: 1.04, sy: 0.42, onda: 2, fase: 2 }), APAGADO),
      trocar(d({ sx: 1.05, sy: 0.25, onda: 1.5 }), APAGADO),
      trocar(d({ sx: 1.05, sy: 0.12 }), APAGADO),
    ],
  ];
}

function salvarFolha(arquivo, linhas) {
  const colunas = 6;
  const folha = Array.from({ length: QUADRO * linhas.length }, () => Array(QUADRO * colunas).fill('.'));
  linhas.forEach((linha, l) => linha.forEach((q, c) => {
    for (let y = 0; y < QUADRO; y++) for (let x = 0; x < QUADRO; x++) folha[l * QUADRO + y][c * QUADRO + x] = q[y][x];
  }));
  const largura = colunas * QUADRO;
  const altura = linhas.length * QUADRO;
  const bruto = Buffer.alloc((largura * 4 + 1) * altura);
  let o = 0;
  for (let y = 0; y < altura; y++) {
    bruto[o++] = 0;
    for (let x = 0; x < largura; x++) {
      const rgb = PALETA[folha[y][x]];
      bruto[o++] = rgb ? rgb[0] : 0;
      bruto[o++] = rgb ? rgb[1] : 0;
      bruto[o++] = rgb ? rgb[2] : 0;
      bruto[o++] = rgb ? 255 : 0;
    }
  }
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(largura, 0);
  ihdr.writeUInt32BE(altura, 4);
  ihdr[8] = 8;
  ihdr[9] = 6;
  fs.mkdirSync(path.dirname(arquivo), { recursive: true });
  fs.writeFileSync(arquivo, Buffer.concat([
    Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]),
    bloco('IHDR', ihdr), bloco('IDAT', zlib.deflateSync(bruto, { level: 9 })), bloco('IEND', Buffer.alloc(0)),
  ]));
  console.log('gerado:', path.relative(process.cwd(), arquivo), largura + 'x' + altura);
}

if (process.argv.includes('--prototipo')) {
  salvarPNG(path.join(RAIZ, 'contexto/implementacoes/imagens/boss_petroleo_prototipo.png'), desenharParado());
} else {
  salvarFolha(path.join(RAIZ, 'beaver-knight-app/Sprites/boss/boss_petroleo_sheet.png'), montarFolha());
}
