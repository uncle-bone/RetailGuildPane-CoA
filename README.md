# RetailGuildPane-CoA

**A Retail-inspired Guild & Communities interface for Ascension Conquest of Azeroth / Conquest Reborn.**

RetailGuildPane-CoA aims to bring the cleaner layout and easier guild navigation of modern World of Warcraft to Conquest Reborn's **WoW 3.3.5a-based client**. It is a standalone addon: no Retail client files or server modifications are required.

> **Development status:** v1.0.0 experimental preview. The source is available, but in-game functionality and compatibility have **not yet been verified**. This is not a stable release.

## Current v1.0.0 features

- Custom, movable guild window with a modern-inspired layout.
- Guild roster with player names, levels, ranks, zones, and online indicators.
- Search by member name and toggle visibility of offline members.
- Guild information and message-of-the-day display.
- Guild chat view with messages captured while the addon is running, plus a message input.
- Manual roster refresh.
- Shortcut to the original Blizzard guild interface.
- Saved preferences for roster search and offline filtering.
- Uses legacy guild APIs rather than depending on Retail Communities APIs.

## Planned improvements

- Closer Retail Guild & Communities visual design, including refined tabs, textures, and member details.
- Sorting and scrolling for large guild rosters.
- Rank and permission-aware guild management.
- Better chat formatting, history behavior, and context menus.
- Guild events, calendar, activity, and guild-bank integration where supported by the client.
- Verified support for all **21 Ascension classes**, including their proper colors and icons.
- Compatibility testing with **Blizzard UI, DragonUI, and ElvUI-CoA**.
- In-game settings and optional guild-keybind integration.

Modern Retail features that require unavailable client or server systems will be adapted where feasible rather than advertised as working.

## Installation

1. Download the repository ZIP from GitHub.
2. Extract it.
3. Copy the inner **RetailGuildPane-CoA** folder (the folder containing `RetailGuildPane-CoA.toc`) to `Conquest Reborn/Interface/AddOns/`.
4. Restart the game or reload the interface.
5. Type **`/rgp`** to toggle the experimental guild window.

The original guild interface remains accessible from the addon's **Original guild UI** button.

## Research and compatibility

Development uses the [RetailGuildPane-CoA client research package](https://github.com/uncle-bone/CoA-Research/tree/main/research/local-client-extracts/2026-10-31/RetailGuildPane-CoA-Research) as a preliminary reference. That package documents possible guild APIs and includes a safe diagnostic addon, but **static documentation is not runtime verification**. Guild roster behavior, custom class tokens, events, and installed-addon conflicts still require testing inside Conquest Reborn.

## Feedback and development

Found a bug or have a feature suggestion? Open a [GitHub issue](https://github.com/uncle-bone/RetailGuildPane-CoA/issues) with the client version, enabled UI addons, steps to reproduce, and any Lua error text.

**Maintainer:** Uncle Bone  
**Repository:** https://github.com/uncle-bone/RetailGuildPane-CoA

This project is an independent fan-made addon and is not affiliated with Blizzard Entertainment or Project Ascension. World of Warcraft names and assets belong to their respective owners.
