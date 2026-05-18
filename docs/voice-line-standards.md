# Voice Line Standards

Use `docs/voice-line-tracker.xlsx` as the working production sheet. One row equals one spoken or subtitle line.

## Full Companion Target

Default launch target: **42 core/relationship lines per companion**, plus **one subzone line per supported subzone**.

| Category | Target | Purpose | Filename pattern |
| --- | ---: | --- | --- |
| `summon` | 1 | Manual companion select / first contact | `summon_01.mp3` |
| `zone_intro` | 2 | Zone arrival flavor | `zone_intro_01.mp3` |
| `quest_accept` | 3 | Generic quest accepted reactions | `quest_accept_01.mp3` |
| `quest_complete` | 3 | Quest turn-in reactions | `quest_complete_01.mp3` |
| `kill` | 3 | Post-combat encouragement | `kill_01.mp3` |
| `bond_kill_2` | 1 | Added to kill pool at 2 hearts | `bond_kill_02.mp3` |
| `bond_kill_4` | 1 | Added to kill pool at 4 hearts | `bond_kill_04.mp3` |
| `bond_kill_6` | 1 | Added to kill pool at 6 hearts | `bond_kill_06.mp3` |
| `bond_kill_8` | 1 | Added to kill pool at 8 hearts | `bond_kill_08.mp3` |
| `bond_kill_10` | 1 | Added to kill pool at 10 hearts | `bond_kill_10.mp3` |
| `idle` | 3 | Random travel / personality chatter | `idle_01.mp3` |
| `bond_idle_1` | 1 | Added to idle pool at 1 heart | `bond_idle_01.mp3` |
| `bond_idle_3` | 1 | Added to idle pool at 3 hearts | `bond_idle_03.mp3` |
| `bond_idle_5` | 1 | Added to idle pool at 5 hearts | `bond_idle_05.mp3` |
| `bond_idle_7` | 1 | Added to idle pool at 7 hearts | `bond_idle_07.mp3` |
| `bond_idle_9` | 1 | Added to idle pool at 9 hearts | `bond_idle_09.mp3` |
| `level_up` | 2 | Level-up celebration | `level_up_01.mp3` |
| `bond_2` | 1 | Two-heart relationship scene | `bond_02_01.mp3` |
| `bond_4` | 1 | Four-heart relationship scene | `bond_04_01.mp3` |
| `bond_6` | 1 | Six-heart relationship scene | `bond_06_01.mp3` |
| `bond_8` | 1 | Eight-heart relationship scene | `bond_08_01.mp3` |
| `bond_10` | 1 | Ten-heart capstone scene | `bond_10_01.mp3` |

## Romance Target

Romance is gated by bond, but progresses separately when the player clicks the romance button.

| Category | Target | Purpose | Filename pattern |
| --- | ---: | --- | --- |
| `romance_2` | 1 | First romantic opening at 2 hearts | `romance_02_01.mp3` |
| `romance_4` | 1 | Warmer romantic scene at 4 hearts | `romance_04_01.mp3` |
| `romance_6` | 1 | Clear affection scene at 6 hearts | `romance_06_01.mp3` |
| `romance_8` | 1 | Near-confession scene at 8 hearts | `romance_08_01.mp3` |
| `romance_10` | 1 | Commitment / capstone romance scene | `romance_10_01.mp3` |
| `romance_not_ready` | 1 | Response when bond is too low for the next romance rank | `romance_not_ready_01.mp3` |
| `romance_repeat` | 1 | Response after all romance ranks are complete | `romance_repeat_01.mp3` |
| `romance_stop` | 1 | Response when the player ends the romance route | `romance_stop_01.mp3` |

## Danger And Location Target

| Category | Target | Purpose | Filename pattern |
| --- | ---: | --- | --- |
| `low_health` | 1 | Emergency line below 25% health | `low_health_01.mp3` |
| `death` | 1 | Player death line | `death_01.mp3` |
| `subzone_<name>` | 1 each | First addon visit to each supported subzone | `subzone_<name>.mp3` |

## Intro Narrator Target

Elune uses the same tracker/generator format, but she is a special narrator instead of a zone romance companion.

| Category | Target | Purpose | Filename pattern |
| --- | ---: | --- | --- |
| `intro` | 9 | Opening reincarnation scene, played sequentially once on first startup | `intro_01.mp3` through `intro_09.mp3` |

## Optional / Future Categories

| Category | Target | Purpose |
| --- | ---: | --- |
| `quest_<id>` | As needed | Quest-specific reactions for iconic quests. |

## Practical Rule

For a prototype companion, write enough to feel alive: 1 summon, 1 zone intro, 3 quest accept lines, 3 quest complete lines, 3 kill lines, 3 idle lines, 2 level-up lines, and the five bond scenes.

For a finished route companion, fill the full 42-line standard before generating voice. Then add one `subzone_<name>` line for every supported subzone in that companion's zone.

## Generation Columns

The `Voice Lines` sheet includes production columns for ElevenLabs generation:

| Column | Purpose |
| --- | --- |
| `Audio Filename` | Expected output filename for this line. |
| `Expected Path` | Where the generated audio should be saved in the addon tree. |
| `Created` | `Yes` when the expected file exists locally, otherwise `No`. |
| `ElevenLabs Voice ID` | Voice ID copied from ElevenLabs after casting the character voice. |
| `ElevenLabs Model ID` | Default is `eleven_multilingual_v2`; change per companion if needed. |
| `Output Format` | Default is `mp3_44100_128`. |
| `Stability` | ElevenLabs voice setting, default `0.5`. |
| `Similarity Boost` | ElevenLabs voice setting, default `0.75`. |
| `Style` | ElevenLabs voice setting, default `0`. |
| `Use Speaker Boost` | ElevenLabs voice setting, default `TRUE`. |
| `Speed` | ElevenLabs voice setting, default `1`. |
| `Enable Logging` | Text-to-speech API option, default `TRUE`. |
