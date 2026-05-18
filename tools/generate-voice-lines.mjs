import fs from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, "..");
const trackerPath = path.join(repoRoot, "docs", "voice-line-tracker.xlsx");
const defaultLiveAddonPath = "C:\\Program Files (x86)\\World of Warcraft\\_retail_\\Interface\\AddOns\\IsekaiAdventure";

function parseArgs(argv) {
  const args = {
    dryRun: false,
    force: false,
    copyLive: false,
    noTrackerSave: false,
    liveAddonPath: defaultLiveAddonPath,
    limit: null,
    row: null,
    companion: null,
    category: null,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    const next = () => argv[++index];

    if (arg === "--dry-run") args.dryRun = true;
    else if (arg === "--force") args.force = true;
    else if (arg === "--copy-live") args.copyLive = true;
    else if (arg === "--no-tracker-save") args.noTrackerSave = true;
    else if (arg === "--live-addon-path") args.liveAddonPath = next();
    else if (arg === "--limit") args.limit = Number(next());
    else if (arg === "--row") args.row = Number(next());
    else if (arg === "--companion") args.companion = String(next() || "").toLowerCase();
    else if (arg === "--category") args.category = String(next() || "").toLowerCase();
    else if (arg === "--help" || arg === "-h") args.help = true;
    else throw new Error(`Unknown argument: ${arg}`);
  }

  return args;
}

function printHelp() {
  console.log(`Usage:
  node tools/generate-voice-lines.mjs [options]

Options:
  --dry-run                    Show selected rows without calling ElevenLabs.
  --limit <n>                  Generate at most n rows.
  --row <excelRow>             Generate one exact Excel row number from Voice Lines.
  --companion <id>             Filter by Companion ID, for example seraphine.
  --category <key>             Filter by Category, for example kill or subzone_goldshire.
  --force                      Overwrite existing files and regenerate Created=Yes rows.
  --copy-live                  Copy generated files to the live Retail addon folder.
  --no-tracker-save            Generate/copy audio without saving tracker changes.
  --live-addon-path <path>     Override live addon path for --copy-live.
  --help                       Show this help.

Requires ELEVENLABS_API_KEY in the environment.
`);
}

function headerIndex(headers) {
  return Object.fromEntries(headers.map((header, index) => [header, index]));
}

function cell(row, indexes, name) {
  return row[indexes[name]];
}

function boolValue(value, defaultValue = false) {
  if (typeof value === "boolean") return value;
  if (value == null || value === "") return defaultValue;
  const normalized = String(value).trim().toLowerCase();
  return normalized === "true" || normalized === "yes" || normalized === "1";
}

function numberValue(value, defaultValue) {
  const number = Number(value);
  return Number.isFinite(number) ? number : defaultValue;
}

function estimateMp3DurationSeconds(byteLength, outputFormat = "mp3_44100_128") {
  const match = String(outputFormat || "").match(/_(\d+)$/);
  const bitrateKbps = match ? Number(match[1]) : 128;
  const bitrate = Number.isFinite(bitrateKbps) && bitrateKbps > 0 ? bitrateKbps * 1000 : 128000;
  return Math.ceil((byteLength * 8 / bitrate) * 10) / 10;
}

function toRepoPath(expectedPath) {
  return String(expectedPath || "").replace(/[\\/]+/g, path.sep);
}

function toDisplayPath(filePath) {
  return path.relative(repoRoot, filePath).replace(/[\\/]+/g, "\\");
}

async function exists(filePath) {
  try {
    await fs.access(filePath);
    return true;
  } catch {
    return false;
  }
}

function rowToJob(row, excelRow, indexes) {
  const expectedPath = cell(row, indexes, "Expected Path");
  const outputPath = path.join(repoRoot, toRepoPath(expectedPath));
  return {
    excelRow,
    row,
    companion: String(cell(row, indexes, "Companion ID") || "").toLowerCase(),
    category: String(cell(row, indexes, "Category") || "").toLowerCase(),
    text: cell(row, indexes, "Dialogue Text"),
    expectedPath,
    outputPath,
    voiceId: cell(row, indexes, "ElevenLabs Voice ID"),
    modelId: cell(row, indexes, "ElevenLabs Model ID") || "eleven_multilingual_v2",
    outputFormat: cell(row, indexes, "Output Format") || "mp3_44100_128",
    created: String(cell(row, indexes, "Created") || "").toLowerCase() === "yes",
    voiceSettings: {
      stability: numberValue(cell(row, indexes, "Stability"), 0.5),
      similarity_boost: numberValue(cell(row, indexes, "Similarity Boost"), 0.75),
      style: numberValue(cell(row, indexes, "Style"), 0),
      use_speaker_boost: boolValue(cell(row, indexes, "Use Speaker Boost"), true),
      speed: numberValue(cell(row, indexes, "Speed"), 1),
    },
  };
}

function validateJob(job) {
  const missing = [];
  if (!job.text) missing.push("Dialogue Text");
  if (!job.expectedPath) missing.push("Expected Path");
  if (!job.voiceId) missing.push("ElevenLabs Voice ID");
  if (!job.modelId) missing.push("ElevenLabs Model ID");
  if (!job.outputFormat) missing.push("Output Format");
  return missing;
}

async function generateAudio(job, apiKey) {
  const url = new URL(`https://api.elevenlabs.io/v1/text-to-speech/${job.voiceId}`);
  url.searchParams.set("output_format", job.outputFormat);

  const response = await fetch(url, {
    method: "POST",
    headers: {
      "xi-api-key": apiKey,
      "Accept": "audio/mpeg",
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      text: job.text,
      model_id: job.modelId,
      voice_settings: job.voiceSettings,
    }),
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`ElevenLabs ${response.status}: ${errorText.slice(0, 500)}`);
  }

  const bytes = Buffer.from(await response.arrayBuffer());
  if (bytes.length < 1000) {
    throw new Error(`Generated audio is unexpectedly small: ${bytes.length} bytes`);
  }

  await fs.mkdir(path.dirname(job.outputPath), { recursive: true });
  await fs.writeFile(job.outputPath, bytes);
  return bytes.length;
}

async function copyToLive(job, liveAddonPath) {
  const destination = path.join(liveAddonPath, toRepoPath(job.expectedPath));
  await fs.mkdir(path.dirname(destination), { recursive: true });
  await fs.copyFile(job.outputPath, destination);
  return destination;
}

async function main() {
  let FileBlob;
  let SpreadsheetFile;
  try {
    ({ FileBlob, SpreadsheetFile } = await import("@oai/artifact-tool"));
  } catch {
    throw new Error("Missing @oai/artifact-tool. In Codex, run tools\\setup-voice-generator-runtime.ps1 once, then retry.");
  }

  const args = parseArgs(process.argv.slice(2));
  if (args.help) {
    printHelp();
    return;
  }

  if (args.limit != null && (!Number.isInteger(args.limit) || args.limit < 1)) {
    throw new Error("--limit must be a positive integer");
  }
  if (args.row != null && (!Number.isInteger(args.row) || args.row < 2)) {
    throw new Error("--row must be an Excel row number of 2 or greater");
  }

  const apiKey = process.env.ELEVENLABS_API_KEY;
  if (!apiKey && !args.dryRun) {
    throw new Error("ELEVENLABS_API_KEY is missing. Set it before generating audio.");
  }

  const workbook = await SpreadsheetFile.importXlsx(await FileBlob.load(trackerPath));
  const sheet = workbook.worksheets.getItem("Voice Lines");
  const range = sheet.getUsedRange();
  const values = range.values;
  const headers = values[0];
  const indexes = headerIndex(headers);

  const requiredHeaders = [
    "Companion ID",
    "Category",
    "Dialogue Text",
    "Expected Path",
    "Created",
    "Voice Status",
    "ElevenLabs Voice ID",
    "ElevenLabs Model ID",
    "Output Format",
    "Duration Sec",
  ];

  for (const header of requiredHeaders) {
    if (indexes[header] == null) {
      throw new Error(`Tracker is missing required column: ${header}`);
    }
  }

  async function saveTracker() {
    if (args.noTrackerSave) return;
    range.values = values;
    const output = await SpreadsheetFile.exportXlsx(workbook);
    await output.save(trackerPath);
  }

  let jobs = values
    .slice(1)
    .map((row, index) => rowToJob(row, index + 2, indexes))
    .filter((job) => {
      if (args.row != null && job.excelRow !== args.row) return false;
      if (args.companion && job.companion !== args.companion) return false;
      if (args.category && job.category !== args.category) return false;
      if (!args.force && job.created) return false;
      return true;
    });

  const filtered = [];
  for (const job of jobs) {
    const fileExists = await exists(job.outputPath);
    if (!args.force && fileExists && !job.created) {
      job.row[indexes["Created"]] = "Yes";
      job.row[indexes["Voice Status"]] = "Audio exists";
      continue;
    }
    filtered.push(job);
  }
  jobs = filtered;

  if (args.limit != null) {
    jobs = jobs.slice(0, args.limit);
  }

  console.log(`Selected ${jobs.length} row(s).`);
  for (const job of jobs) {
    const missing = validateJob(job);
    const marker = missing.length ? ` MISSING: ${missing.join(", ")}` : "";
    console.log(`- Row ${job.excelRow}: ${job.companion} ${job.category} -> ${toDisplayPath(job.outputPath)}${marker}`);
  }

  if (args.dryRun || jobs.length === 0) {
    if (!args.dryRun && !args.noTrackerSave) {
      range.values = values;
      const output = await SpreadsheetFile.exportXlsx(workbook);
      await output.save(trackerPath);
    }
    return;
  }

  for (const job of jobs) {
    const missing = validateJob(job);
    if (missing.length) {
      console.warn(`Skipping row ${job.excelRow}: missing ${missing.join(", ")}`);
      continue;
    }

    const fileExists = await exists(job.outputPath);
    if (fileExists && !args.force) {
      const stat = await fs.stat(job.outputPath);
      job.row[indexes["Created"]] = "Yes";
      job.row[indexes["Voice Status"]] = "Audio exists";
      job.row[indexes["Duration Sec"]] = estimateMp3DurationSeconds(stat.size, job.outputFormat);
      console.log(`Skipped existing file for row ${job.excelRow}: ${toDisplayPath(job.outputPath)}`);
      await saveTracker();
      continue;
    }

    console.log(`Generating row ${job.excelRow}: ${toDisplayPath(job.outputPath)}`);
    const size = await generateAudio(job, apiKey);
    job.row[indexes["Created"]] = "Yes";
    job.row[indexes["Voice Status"]] = "Audio exists";
    job.row[indexes["Duration Sec"]] = estimateMp3DurationSeconds(size, job.outputFormat);
    job.row[indexes["Generation Notes"]] = `Generated ${new Date().toISOString()} (${size} bytes)`;

    if (args.copyLive) {
      const destination = await copyToLive(job, args.liveAddonPath);
      console.log(`Copied to live addon: ${destination}`);
    }

    await saveTracker();
  }

  if (args.noTrackerSave) {
    console.log("Skipped tracker save because --no-tracker-save was set.");
  } else {
    console.log("Updated docs\\voice-line-tracker.xlsx");
  }
}

main().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});
