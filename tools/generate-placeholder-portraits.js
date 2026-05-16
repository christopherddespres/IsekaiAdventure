const fs = require("fs");
const path = require("path");

const outDir = path.join(__dirname, "..", "Media", "Portraits");
fs.mkdirSync(outDir, { recursive: true });

const size = 256;
const companions = [
  { id: "elyria", hair: [255, 170, 225], bg1: [86, 45, 84], bg2: [36, 59, 84], eye: [100, 60, 88] },
  { id: "mika", hair: [132, 222, 255], bg1: [45, 86, 112], bg2: [42, 43, 96], eye: [42, 86, 118] },
  { id: "sera", hair: [164, 239, 166], bg1: [42, 93, 68], bg2: [35, 58, 76], eye: [50, 105, 70] },
  { id: "kaori", hair: [255, 126, 112], bg1: [117, 47, 55], bg2: [70, 43, 64], eye: [120, 55, 58] },
  { id: "rin", hair: [255, 215, 104], bg1: [108, 82, 35], bg2: [48, 59, 83], eye: [109, 75, 42] },
  { id: "lyra", hair: [188, 157, 255], bg1: [72, 54, 112], bg2: [39, 47, 78], eye: [80, 62, 122] },
];

function lerp(a, b, t) {
  return Math.round(a + (b - a) * t);
}

function blend(base, overlay, alpha) {
  return [
    lerp(base[0], overlay[0], alpha),
    lerp(base[1], overlay[1], alpha),
    lerp(base[2], overlay[2], alpha),
  ];
}

function insideEllipse(x, y, cx, cy, rx, ry) {
  const dx = (x - cx) / rx;
  const dy = (y - cy) / ry;
  return dx * dx + dy * dy <= 1;
}

function createPortrait(config) {
  const data = Buffer.alloc(size * size * 4);

  for (let y = 0; y < size; y++) {
    for (let x = 0; x < size; x++) {
      const t = (x + y) / (size * 2);
      let color = [
        lerp(config.bg1[0], config.bg2[0], t),
        lerp(config.bg1[1], config.bg2[1], t),
        lerp(config.bg1[2], config.bg2[2], t),
      ];

      const glow = Math.max(0, 1 - Math.hypot(x - 128, y - 60) / 72);
      color = blend(color, [255, 224, 170], glow * 0.35);

      if (insideEllipse(x, y, 128, 200, 82, 78)) {
        color = [31, 19, 34];
      }
      if (insideEllipse(x, y, 72, 138, 30, 84) || insideEllipse(x, y, 184, 138, 30, 84)) {
        color = blend(config.hair, [255, 255, 255], 0.12);
      }
      if (insideEllipse(x, y, 128, 116, 64, 76)) {
        color = config.hair;
      }
      if (insideEllipse(x, y, 128, 120, 48, 56)) {
        color = [255, 208, 185];
      }

      const smile = Math.abs(y - (146 + Math.pow((x - 128) / 34, 2) * 11)) < 2 && x > 91 && x < 165;
      if (smile) {
        color = config.eye;
      }

      const idx = (y * size + x) * 4;
      data[idx + 0] = color[2];
      data[idx + 1] = color[1];
      data[idx + 2] = color[0];
      data[idx + 3] = 255;
    }
  }

  const header = Buffer.alloc(18);
  header[2] = 2;
  header.writeUInt16LE(size, 12);
  header.writeUInt16LE(size, 14);
  header[16] = 32;
  header[17] = 0x28;

  fs.writeFileSync(path.join(outDir, `${config.id}.tga`), Buffer.concat([header, data]));
}

for (const companion of companions) {
  createPortrait(companion);
}

console.log(`Generated ${companions.length} portrait placeholders in ${outDir}`);
