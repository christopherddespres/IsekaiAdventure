# Isekai Adventure

A World of Warcraft Retail addon prototype for voiced isekai companions.

The addon shows a companion frame, assigns a companion per zone, reacts when you accept quests, occasionally comments after kills, and plays idle chatter while you adventure.

## Install

Place this folder at:

```text
World of Warcraft\_retail_\Interface\AddOns\IsekaiAdventure
```

Then enable **Isekai Adventure** in the in-game addon list.

## Commands

```text
/isekai
/isekai options
/isekai start
/isekai test
/isekai show
/isekai hide
/isekai enable
/isekai disable
/isekai lock
/isekai unlock
/isekai mute
/isekai unmute
/isekai scale 1.2
/isekai chance kill 20
/isekai chance quest 100
/isekai idleinterval 10 50
/isekai status
/isekai diagnose
/isekai bond
/isekai companion seraphine
```

The in-game options panel includes controls for chatter chances/cooldowns, dialogue box opacity and RGB color, subtitle text size, voice playback channel, layout tools, tests, and resetting saved settings.

Companion production status lives in [docs/companion-checklist.md](docs/companion-checklist.md).

Companions also track bond progress from quest completion, leveling, manual summons, and time spent adventuring together. Bond thresholds can unlock special dialogue keys such as `bond_2`, `bond_4`, `bond_6`, `bond_8`, and `bond_10`.

## Voice files

WoW addons cannot call ElevenLabs, OpenAI, or any web API while the game is running. Generate audio ahead of time and put it under:

```text
Media\Voice\Elyria\quest_accept_01.ogg
Media\Voice\Elyria\kill_01.ogg
Media\Voice\Elyria\idle_01.ogg
```

The dialogue table in `Data\Dialogue.lua` already points at these filenames. If a file is missing, WoW simply will not play that voice line, but the subtitle still appears.

Recommended export format: `.ogg` or `.mp3`.

## Portraits

The first version includes generated `.tga` placeholder portraits. To use custom art, replace or add files in:

```text
Media\Portraits\
```

Then update each companion's `portrait` field in `Data\Companions.lua`, for example:

```lua
portrait = "Interface\\AddOns\\IsekaiAdventure\\Media\\Portraits\\elyria.blp"
```

WoW supports `.blp` and commonly supports `.tga`; modern clients also support many `.png` textures, but `.blp` is still the safest addon format.

## Adding quest-specific lines

Add a key like this under a companion in `Data\Dialogue.lua`:

```lua
quest_78319 = {
    { text = "This one feels important. Let us give it everything.", audio = "quest_78319_01.ogg", duration = 4.8 },
},
```

When that quest is accepted, the specific line is used instead of the generic quest line.
