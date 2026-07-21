# AltKeeper

AltKeeper is een native iOS-app in SwiftUI voor het veilig beheren van meerdere game-accounts. De app bewaart **geen wachtwoorden** — alleen accountmetadata zoals platform, gebruikersnaam, e-mailadres en loginherinneringen.

<p align="center">
  <img src="AltKeeper/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png" alt="AltKeeper app icon" width="120" />
</p>

## Functies

- **Dashboard** — overzicht van accounts, platforms, aankomende herinneringen en accounts zonder 2FA
- **Accountoverzicht** — gegroepeerd per platform met zoeken, filteren en sorteren
- **Accountdetail** — volledige metadata, kopieeracties, loginflow en status
- **Toevoegen/bewerken** — formulier met validatie en duplicaatdetectie
- **Loginflow** — kopieer gegevens, open officiële loginpagina (Safari), optioneel platform-app
- **Lokale herinneringen** — UserNotifications met instelbare intervallen
- **Beveiliging** — optionele Face ID / Touch ID / toegangscode
- **iCloud-synchronisatie** — optionele CloudKit-sync via SwiftData
- **Import/export** — versieerbaar JSON-formaat
- **Unit tests** — herinneringsberekening, status, import/export, duplicaten, CloudKit-migratie

## Installatie (unsigned IPA)

Download de nieuwste **unsigned IPA** uit [Releases](https://github.com/Ventspew/AltKeeper/releases/latest) en sideload via AltStore of Sideloadly.

→ Zie [INSTALL.md](INSTALL.md) voor gedetailleerde stappen.

## Ontwikkeling

### Vereisten

- Xcode 16+
- iOS 18.0+
- Swift 5.10+

### Project openen

```bash
git clone https://github.com/Ventspew/AltKeeper.git
cd AltKeeper
open AltKeeper.xcodeproj
```

Selecteer het **AltKeeper**-scheme en run op simulator of apparaat. Kies je Development Team onder Signing & Capabilities.

### Unsigned IPA bouwen (macOS)

```bash
./scripts/build-unsigned-ipa.sh
# → build/AltKeeper-unsigned.ipa
```

### Release via GitHub Actions

```bash
git tag v1.0.0
git push origin v1.0.0
```

Dit triggert automatisch een macOS-build die `AltKeeper-unsigned.ipa` als release-asset publiceert.

## Architectuur

```
AltKeeper/
├── AltKeeperApp.swift          # App entry, SwiftData container, app lock
├── Models/                     # GameAccount, GamePlatform, enums
├── Services/                   # Business logic (status, reminders, notifications)
├── ViewModels/                 # MVVM view models
├── Views/                      # SwiftUI views per scherm
└── Utilities/                  # Platform config, extensions
```

**Patronen:** MVVM, SwiftData, async/await, geen externe dependencies.

## Datamodel

Het `GameAccount`-model slaat metadata op: platform, displayName, username, emailAddress, region, lastLoginDate, nextLoginReminderDate, 2FA-status, enz. Wachtwoorden worden **niet** opgeslagen.

## Debug-voorbeelddata

In **DEBUG**-builds worden automatisch vijf voorbeeldaccounts toegevoegd als de database leeg is:

- PlayStation Hoofdaccount Nederland
- PlayStation Verenigde Staten
- PlayStation Japan
- Steam Hoofdaccount
- Xbox Testaccount

## CloudKit-synchronisatie

AltKeeper ondersteunt optionele iCloud-synchronisatie via SwiftData + CloudKit.

### Setup in Xcode

1. Open `AltKeeper.xcodeproj`
2. Selecteer het **AltKeeper**-target → **Signing & Capabilities**
3. Kies je **Development Team**
4. Controleer dat **iCloud** met **CloudKit** actief is (container: `iCloud.com.altkeeper.app`)
5. Entitlements staan in `AltKeeper/AltKeeper.entitlements`

### Gebruik

1. Ga naar **Instellingen → iCloud-synchronisatie**
2. Schakel synchronisatie in — lokale accounts worden bij de volgende start naar iCloud gekopieerd
3. **Sluit de app volledig af** en open opnieuw (via app-switcher)
4. Accounts synchroniseren automatisch tussen iPhone, iPad en Mac (zelfde Apple ID)

### Technische details

- CloudKit-container: `iCloud.com.altkeeper.app`
- Lokale store: `AltKeeperLocal` (zonder sync)
- Cloud store: `AltKeeperCloud` (private CloudKit-database)
- Account-UUID's zijn `@Attribute(.unique)` voor betrouwbare deduplicatie
- Geen wachtwoorden in CloudKit — alleen accountmetadata

### Migratie

Bij inschakelen worden lokale accounts eenmalig gekopieerd naar iCloud. Bestaande cloud-records met dezelfde UUID worden overgeslagen.

## Tests uitvoeren

```bash
xcodebuild test \
  -project AltKeeper.xcodeproj \
  -scheme AltKeeper \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Exportformaat

```json
{
  "schemaVersion": 1,
  "exportDate": "2026-07-21T12:00:00Z",
  "accounts": [ ... ]
}
```

Exportbestanden kunnen gevoelige metadata bevatten. Bewaar ze veilig.

## Licentie

Apache License 2.0 — zie [LICENSE](LICENSE).
