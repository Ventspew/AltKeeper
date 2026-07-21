# AltKeeper installeren (unsigned IPA)

De releases bevatten een **unsigned IPA** (`AltKeeper-unsigned.ipa`). Deze kun je sideloaden op je iPhone of iPad.

## Vereisten

- iOS 18+
- Een sideload-tool, bijvoorbeeld:
  - [AltStore](https://altstore.io/)
  - [Sideloadly](https://sideloadly.io/)
  - [StosVPN + LiveContainer](https://github.com/LiveContainer/LiveContainer) (geavanceerd)

## Stappen

1. Download `AltKeeper-unsigned.ipa` uit de [latest release](https://github.com/Ventspew/AltKeeper/releases/latest).
2. Open je sideload-tool op Mac of Windows.
3. Verbind je iPhone/iPad via USB (of via Wi-Fi, afhankelijk van de tool).
4. Selecteer het `.ipa`-bestand en je Apple ID.
5. Wacht tot de installatie voltooid is.
6. Ga op je apparaat naar **Instellingen → Algemeen → VPN en apparaatbeheer** en vertrouw het developer-certificaat.

## Opmerkingen

- Unsigned builds verlopen meestal na **7 dagen** (gratis Apple ID) of **365 dagen** (betaald developer-account via AltStore).
- Herinstalleer of refresh de app voordat het certificaat verloopt.
- Voor iCloud-sync: log in met je Apple ID op het apparaat en schakel iCloud in de app in.

## Zelf bouwen (macOS)

```bash
chmod +x scripts/build-unsigned-ipa.sh
./scripts/build-unsigned-ipa.sh
# Output: build/AltKeeper-unsigned.ipa
```

## GitHub Actions

Elke git tag `v*` (bijv. `v1.0.0`) triggert automatisch een unsigned IPA-build die als release-asset wordt gepubliceerd.

```bash
git tag v1.0.0
git push origin v1.0.0
```
