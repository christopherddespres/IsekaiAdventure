# Voice Line Standards

Use `docs/voice-line-tracker.xlsx` as the working production sheet. One row equals one spoken or subtitle line.

## Full Companion Target

Default launch target: **25 core lines per companion**, plus **7 romance lines** for romance-enabled companions.

| Category | Target | Purpose | Filename pattern |
| --- | ---: | --- | --- |
| `summon` | 1 | Manual companion select / first contact | `summon_01.mp3` |
| `zone_intro` | 2 | Zone arrival flavor | `zone_intro_01.mp3` |
| `quest_accept` | 5 | Generic quest accepted reactions | `quest_accept_01.mp3` |
| `kill` | 4 | Post-combat encouragement | `kill_01.mp3` |
| `idle` | 6 | Random travel / personality chatter | `idle_01.mp3` |
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

## Optional / Future Categories

| Category | Target | Purpose |
| --- | ---: | --- |
| `quest_<id>` | As needed | Quest-specific reactions for iconic quests. |
| `quest_complete` | 3 | Turn-in reactions if we add a voiced quest-complete event. |
| `low_health` | 2 | Combat danger flavor if we add low-health triggers. |

## Practical Rule

For a prototype companion, write enough to feel alive: 1 summon, 1 zone intro, 3 quest lines, 2 kill lines, 3 idle lines, 1 level-up line, and the five bond scenes.

For a finished route companion, fill the full 25-line core target before generating voice. For romance-enabled companions, add the 7 romance lines before calling the route complete.
