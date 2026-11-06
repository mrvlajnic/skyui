# Audi A4 B9 (8W) — Infotainment / MMI Walkthrough Reference

> Purpose: visual reference for the SkyUI in-cabin HMI work. One document, one picture per menu,
> so the SkyUI screens can be compared icon-by-icon and layout-by-layout against the factory system.
> **Car chosen:** Audi A4 B9 (8W), 2017, MMI Navigation plus with MMI **touch** (MIB II High)
> and full-screen **Audi virtual cockpit** style MID figures from the instrument cluster.

## Sources

| Source | What it gave us |
|---|---|
| Audi A4 2017 (US) Owner's Manual — 386 pages, page images fetched from ManualsLib (`/manual/4255256/Audi-A4-2017`) | factory screenshots of every MMI menu (`images/*.png`, names below) |
| Kenemation "A4 B9" BeamNG.drive mod (`C:\Users\Gamer\Downloads\A4BYGORILLA`) | a full SVG replica of the MMI screen + boot screen used in-game (`source_navi_screen.svg`, `images/90_mod-replica-*`) |

All images live in `images/` and are **gitignored** (see `.gitignore` at repo root):
`docs/reference/audi-a4-b9-mmi/images/`.

## How the MMI is operated (for HMI comparison context)

- The screen is a **10" touch display** (MMI touch). Hard fallback: control knob with touchpad,
  left/right control buttons, `[MENU]`, `[BACK]`, `[NAV/MAP]`, `[RADIO]`, `[MEDIA]`, `[TEL]` shortcut keys
  (see `10_mmi-control-panel.png`).
- The manual distinguishes **display version A** (clean) and **display version B** (with car/map/album
  art as floating 3D content, e.g. the main menu with the parked car) — see `11_mmi-main-menu.png`.

## Menu walkthrough (one screen per menu)

### Driver information system (instrument cluster / virtual cockpit)
| Menu screen | Manual page (printed / site page) | Image |
|---|---|---|
| Instrument cluster overview | p. 10 (site 12) | `01_instrument-cluster-overview.png` |
| MID tabs (all info tabs at once) | p. 13 (site 15), fig. 6 | `02_mid-tabs.png` |
| MID fuel-consumption bar | p. 17 (site 19) | `03_mid-fuel-consumption.png` |
| MID navigation — **virtual cockpit map with route guidance** | p. 19 (site 21), fig. 16 | `04_mid-navigation-virtual-cockpit.png` |
| MID map view | p. 20 (site 22) | `05_mid-map-view.png` |
| MID arrow view | p. 22 (site 24) | `06_mid-arrow-view.png` |

### MMI core / shell
| Menu screen | Manual page (printed / site page) | Image |
|---|---|---|
| MMI control panel (hard keys + shortcut keys) | p. 141 (site 143), fig. 139 | `10_mmi-control-panel.png` |
| **Main menu** (car with floating Icons: Vehicles, Sound, Radio, Media, Telephone) | p. 142 (site 144), fig. 144 | `11_mmi-main-menu.png` |
| Selecting/confirming functions (list behaviour) | p. 142 (site 145), fig. 143 | `12_mmi-selecting-functions.png` |
| MMI touch (handwriting on the screen / pad, call list + speller while writing) | p. 144 (site 146), figs. 146–148 | `13_mmi-touch.png` |
| Letter/number speller | p. 148 (site 150), fig. 153 | `14_mmi-speller.png` |
| Menus & symbols (function bar menu tree, part 1/2) | p. 149 (site 151) | `15_mmi-menus-symbols-A.png` |
| Menus & symbols (part 2/2) | p. 150 (site 152) | `16_mmi-menus-symbols-B.png` |
| Voice recognition system (command list screen) | p. 154 (site 155) | `17_voice-recognition.png` |

### Telephone
| Menu screen | Manual page (printed / site page) | Image |
|---|---|---|
| Telephone menu / directory & call list | p. 162 (site 164) | `20_telephone-menu.png` |
| Dialing a telephone number | p. 163 (site 165), fig. 161 | `21_telephone-dialing.png` |

### Audi connect (Infotainment)
| Menu screen | Manual page (printed / site page) | Image |
|---|---|---|
| Audi connect home screen (service tiles) | p. 171 (site 173), fig. 166 | `30_audi-connect-home.png` |
| Audi connect service functions (Read out / Log in …) | p. 174 (site 176) | `31_audi-connect-services.png` |

### Navigation
| Menu screen | Manual page (printed / site page) | Image |
|---|---|---|
| Accessing navigation — Enter destination menu (free text, home, last, favorites + mini-map) | p. 187 (site 189), fig. 169 | `40_navigation-enter-destination.png` |
| Destination entry input field with map preview | p. 188 (site 190) | `41_navigation-destination-entry-map.png` |
| Selecting a destination from the map (crosshair tapping) | p. 189 (site 191) | `42_navigation-select-from-map.png` |
| Stopover destination | p. 192 (site 194) | `43_navigation-stopover.png` |
| Personal route assistance / POI search | p. 193 (site 195) | `44_navigation-personal-route.png` |
| Route criteria (eco vs. dynamic) | p. 197 (site 199), fig. 182 | `45_navigation-route-criteria.png` |
| Additional map options (map menu) | p. 198 (site 200) | `46_navigation-map-options.png` |
| Online map update (import list) | p. 201 (site 203) | `47_navigation-online-map-update.png` |

### Radio
| Menu screen | Manual page (printed / site page) | Image |
|---|---|---|
| Opening the radio function (FM/AM lists) | p. 204 (site 206) | `50_radio-open.png` |
| **Radio menu** (Presets SiriusXM alerts SiriusXM FM/AM) | p. 207 (site 209), fig. 189 | `51_radio-menu.png` |
| Radio additional settings (HD Radio, station names) | p. 208 (site 210) | `52_radio-additional-settings.png` |

### Media
| Menu screen | Manual page (printed / site page) | Image |
|---|---|---|
| Media introduction (sources) | p. 209 (site 211) | `53_media-introduction.png` |
| CD/DVD drive (media center folder tree) | p. 211 (site 213) | `54_media-cd-drive.png` |
| Media folders structure | p. 219 (site 221) | `55_media-folders.png` |
| **Playlist** (track/artist/album art) | p. 220 (site 222), fig. 201 | `56_media-playlist.png` |

### Audi smartphone interface & system settings
| Menu screen | Manual page (printed / site page) | Image |
|---|---|---|
| Audi smartphone interface (CarPlay/AAOS screen inside MMI) | p. 227 (site 229) | `60_audi-smartphone-interface.png` |
| Smartphone interface troubleshooting | p. 228 (site 230) | `61_audi-smartphone-interface-troubleshooting.png` |
| System settings — date & time / MMI settings | p. 229 (site 231) | `62_settings-date-time.png` |
| System settings — speech | p. 230 (site 232) | `63_settings-speech.png` |
| System settings — data connection / connection manager | p. 231 (site 233) | `64_settings-data-connection.png` |
| System settings — sound (part 1) | p. 232 (site 234) | `65_settings-sound.png` |
| System settings — sound (part 2) | p. 233 (site 235) | `66_settings-sound-b.png` |

### Parking / camera screens (MMI shows these when shifting into R)
| Menu screen | Manual page (printed / site page) | Image |
|---|---|---|
| Rearview camera — aiming at a parking space (orange orientation lines) | p. 128 (site 130), figs. 125–127 | `70_rearview-camera.png` |
| Peripheral cameras — mode picker (Corner front/rear, Front, Surrounding, Rear) | p. 130 (site 132), figs. 131–134 | `71_peripheral-camera-modes.png` |
| **Parking system plus** — visual distance display on the Infotainment display (red/white segment bars next to the mini map) | p. 126 (site 128), fig. 121 | `72_parking-system-plus-display.png` |

### BeamNG mod replica of the A4 B9 MMI (bonus)
| Image | What it is |
|---|---|
| `90_mod-replica-bootscreen.png` | Audi "four rings" boot screen used by the mod (`navi_screen/AUDI_bootscreen.png`) |
| `91_mod-replica-mmi-sidebar.png` | Replica of the MMI screen as the mod renders it: dark 4:2:1 display, left quick-launch bar (HOME / TEL / RADIO / NAV), clock, Audi-connect QR tile in the corner. Full replica SVG: `source_navi_screen.svg` |
| `source_navi_screen.html` / `.svg` | Extracted screen markup from the BeamNG mod (1024×512, interactive elements are JS-driven; the static SVG frame shows sidebar, clock and QR) |

## Design takeaways for SkyUI

1. Dark charcoal background, thin 1px separators, small all-caps labels, red/orange accent only for
   selected items and warnings — matches the factory MIB II High look.
2. The **main menu is not a grid of icons** — it is a floating-icon "constellation" around a photo of
   the car (Media, Telephone, Radio, Sound, Vehicles). SkyUI's grid layout is the opposite convention.
3. Every menu opens with a **list of text rows**, selection menu (left control button) and options menu
   (right control button) are context-dependent side panels over the list.
4. Camera/rear screens, phone full-screen dialer and radio menu all overlay the "top status strip"
   (time overwritten at top-right), which SkyUI should mimic when comparing states.
5. The instrument cluster MID and virtual cockpit share the exact same navigation map widget as the
   MMI (same POIs/street rendering pipeline) — one map component, two aspect ratios.
