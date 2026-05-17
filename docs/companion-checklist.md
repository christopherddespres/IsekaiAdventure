# Companion Content Checklist

Use this as the production tracker for zone companions. Keep `Companion ID` aligned with `Data/Companions.lua`, keep map IDs aligned with `addon.mapCompanions`, and mark asset status after files are copied into the addon tree.

Status key:

- `Done`: usable in game now.
- `Partial`: exists, but needs more polish, coverage, or assets.
- `Planned`: selected, but not implemented.
- `TBD`: not chosen yet.

## Active Zone Companions

| Zone | Map IDs | Companion ID | Character | Race | Gender | Portrait | Voice | Dialogue | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Elwynn Forest | `37` | `seraphine` | Seraphine Applebrook | Human | Female | Done | Done | Done | Female Elwynn route. Uses full art and MP3 voice files. |
| Elwynn Forest | `37` | `cedric` | Cedric Applebrook | Human | Male | Done | Planned | Done | Male Elwynn route. Portrait imported; needs voice files. |
| Northshire | `425` | `seraphine` | Seraphine Applebrook | Human | Female | Done | Done | Done | Female Northshire route. Shares Elwynn companion. |
| Northshire | `425` | `cedric` | Cedric Applebrook | Human | Male | Done | Planned | Done | Male Northshire route. Shares Elwynn companion. |
| Westfall | `52` | `maribel` | Maribel Dustwhisper | Human | Female | Done | Done | Done | Voice folder is `Media\Voice\Meribel\` to match current files. |
| Exile's Reach | `1409` | `elyria` | Elyria Dawnspell | Human | Female | Partial | Planned | Partial | Placeholder portrait/dialogue. Needs final art and voice. |
| Stormwind City | `84` | `elyria` | Elyria Dawnspell | Human | Female | Partial | Planned | Partial | City fallback/guide role. |
| Orgrimmar | `85` | `mika` | Mika Starbloom | Draenei | Female | Partial | Planned | Partial | Temporary mapping; decide if Horde capital should use a Horde-appropriate companion. |
| The Waking Shores | `2022` | `sera` | Sera Moonvale | Night Elf | Female | Partial | Planned | Partial | Dragon Isles placeholder. |
| Ohn'ahran Plains | `2023` | `kaori` | Kaori Emberheart | Blood Elf | Female | Partial | Planned | Partial | Dragon Isles placeholder. |
| The Azure Span | `2024` | `rin` | Rin Gearwhisper | Gnome | Female | Partial | Planned | Partial | Dragon Isles placeholder. |
| Thaldraszus | `2025` | `lyra` | Lyra Ashpetal | Void Elf | Female | Partial | Planned | Partial | Dragon Isles placeholder. |
| Valdrakken | `2112` | `mika` | Mika Starbloom | Draenei | Female | Partial | Planned | Partial | City placeholder. |
| Isle of Dorn | `2248` | `rin` | Rin Gearwhisper | Gnome | Female | Partial | Planned | Partial | War Within placeholder. |
| The Ringing Deeps | `2214` | `elyria` | Elyria Dawnspell | Human | Female | Partial | Planned | Partial | War Within placeholder. |
| Hallowfall | `2215` | `sera` | Sera Moonvale | Night Elf | Female | Partial | Planned | Partial | War Within placeholder. |
| Azj-Kahet | `2255` | `kaori` | Kaori Emberheart | Blood Elf | Female | Partial | Planned | Partial | War Within placeholder. |

## Near-Term Backlog

| Zone | Map IDs | Companion ID | Character | Race | Gender | Portrait | Voice | Dialogue | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Redridge Mountains | TBD | TBD | TBD | TBD | Female | Planned | Planned | Planned | Natural Alliance progression after Westfall. |
| Duskwood | TBD | TBD | TBD | TBD | Female | Planned | Planned | Planned | Strong candidate for gothic/horror companion. |
| Loch Modan | TBD | TBD | TBD | TBD | Female | Planned | Planned | Planned | Good fit for explorer, mountaineer, or engineer type. |
| Teldrassil | TBD | TBD | TBD | Night Elf | Female | Planned | Planned | Planned | Needs route decision for current Retail accessibility/timeline. |
| Darkshore | TBD | TBD | TBD | Night Elf | Female | Planned | Planned | Planned | Pair with Teldrassil or post-Teldrassil story tone. |

## Per-Companion Done Criteria

| Asset | Done when |
| --- | --- |
| Companion entry | `Data/Companions.lua` has `id`, display name, title, race, gender, color, portrait or character art, and voice path. |
| Map assignment | `addon.mapCompanions` maps each supported zone map ID to the companion ID. |
| Portrait | Final image exists under `Media\Portraits\`, preferably with a safe `.tga` copy for WoW. |
| Voice | Every referenced dialogue audio file exists under the companion voice folder. |
| Dialogue | Has at least `summon`, `zone_intro`, `quest_accept`, `idle`, `kill`, and `level_up`. |
| Bond dialogue | Has optional threshold scenes for `bond_2`, `bond_4`, `bond_6`, `bond_8`, and `bond_10`. |
| Test pass | `/isekai companion <id>`, `/isekai test`, `/isekai idle`, `/isekai kill`, and zone switching all work after `/reload`. |
