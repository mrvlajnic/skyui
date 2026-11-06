# SkyUI Automotive HMI Audit

Datum: 24. septembar 2026

Verzija audita: `0.3.0-alpha+1`

Konkretna komponenta: Flutter UI / lokalni web simulator

## Veltron Auto kontekst

Veltron Auto je nezavisan automotive R&D studio u Beogradu, predvođen Borisom Vlajnićem, Founder and Automotive Design Director. V1 SportLine je njegov performance concept, a SkyUI predstavlja HMI/digital-cockpit pravac te koncepcije.

Cilj je automotive-grade design i engineering direction. Ovaj audit ne pretvara taj cilj u tvrdnju da je trenutni prototip certificiran ili validiran na vozilu.

## Zaključak

SkyUI je dovoljno funkcionalan kao interni, mock-based HMI prototip za cockpit simulator na landscape baseline-u 1680×720. Nije spreman za povezivanje na vozilo, distribuciju vozačima ili bilo kakvu bezbednosnu tvrdnju. Trenutni kod nema backend, remote telemetry, crash reporting, analytics ili cloud sync.

Najvažnije preostale blokere su:

1. Nema centralne, verifikovane vozačke restrikcije interakcija.
2. Telefonski poziv i media playback nemaju trajni session lifecycle kroz module.
3. Vozilna telemetrija nema provenance, validnost, freshness ili degraded/fault stanja.
4. Android release koristi debug signing i placeholder application identity.
5. Nema TARA/HARA, ISO 26262, UNECE R155/R156, OTA ili CAN command-security evidence.
6. Nema validacije na stvarnom panelu: fizičke mete, čitljivost, fokus, input latency, FPS, memory i background lifecycle ostaju neprovereni.

## Opseg i metod

Audit je izveden nad trenutnim working tree-om, ne nad čistim `HEAD` checkout-om. U vremenu audita postojale su korisničke izmene u Media, Header, test fajlu i novi, ali još untracked `lib/services/drive_mode_service.dart` fajl.

Pregledani su:

- Dart UI, servisi, testovi, resursi i tema;
- Android, iOS, web, Windows, Linux i macOS konfiguracija;
- trenutni web build artefakt;
- launcher i release signing konfiguracija;
- zavisnosti, lockfile, dokumentacija i dostupna Git istorija;
- UX, arhitektura, performanse i sigurnosni profil.

Kriterijum ozbiljnosti:

| Nivo | Značenje |
| --- | --- |
| Blocker | Ne sme se integrisati sa vozilom ili aktuatorom |
| Visoko | Može dovesti do pogrešne vozačke odluke, gubitka session state-a ili neprihvatljivog release identity |
| Srednje | Materijalno kvari pouzdanost, pristupačnost, održavanje ili performanse |
| Nisko | Lokalna nekonzistentnost bez neposrednog safety/security efekta |

## Implementirana poboljšanja

### Navigacija i state koordinacija

- Umesto nezavisnih konkurentnih `reverse()` poziva uveden je jedinstveni destination transition model.
- Tokom tranzicije čuva se poslednja korisnička destinacija; ne otvaraju se dva modula istovremeno.
- Ako se demo poziv aktivira dok Phone već zatvara, prelaz se abortuje i Phone se vraća u otvoreno stanje.
- Android/system Back sada zatvara aktivan modul umesto da zatvori root rutu.
- Dok je demo poziv aktivan, ostali sidebar destination-i imaju disabled Semantics/Tooltip stanje sa razlogom.
- Vehicle i Settings sidebar stavke su eksplicitno disabled jer njihovi ekrani ne postoje.
- Dodatni Vehicle quick action prikazi su disabled i označeni kao unavailable.
- Dodat je regresioni test za brze Media → Phone → Navigation zahteve i system Back.

Fajlovi:

- `lib/screens/home/home_screen.dart`
- `lib/widgets/sidebar/sidebar.dart`
- `lib/widgets/sidebar/sidebar_item.dart`
- `lib/widgets/cards/vehicle_card.dart`
- `test/widget_test.dart`

### Telefon

- Uklonjeni su Contacts i Voicemail tabovi koji nisu menjali sadržaj.
- Dialer i Recent Calls sada imaju različit, stvarni sadržaj.
- Izbor recenta samo popunjuje broj; poziv zahteva eksplicitan Call korak.
- Prazan broj i kontrole van validnog call stanja prikazuju se kao disabled.
- Mute je omogućen samo tokom aktivnog demo poziva.
- Dok je poziv aktivan, Home blokira sidebar i system Back prelaz koji bi uništio Phone widget; korisnik prvo mora završiti poziv.
- In-call Keypad no-op kontrola je uklonjena iz aktivnog affordance-a.
- Call kontrola se više ne može ponovo aktivirati tokom postojećeg demo poziva.
- Nerealno početno „Incoming call” stanje je uklonjeno; početno stanje je „Ready to call”.
- Fixtures su zamenjeni sintetičkim imenima i rezervisanim demo brojevima.
- Dodatni keyboard/focus nalazi i najmanje 48 dp hit zone su dodati na ključne kontrole.

Fajlovi:

- `lib/screens/phone/phone_screen.dart`
- `lib/widgets/cards/phone_card.dart`
- `test/widget_test.dart`

### Navigacija i performanse

- Uklonjen je beskonačni flow controller čiji izlaz nije uticao na mapu, a ipak je izazivao repaint.
- Putanja animacije više ne poziva `setState` nad celim Navigation state-om na svaki frame.
- Zoom, Recenter i 3D kontrole su disabled jer prethodno nisu menjale mapu.
- Slobodan map tap je uklonjen jer je menao samo demo target, ali nije menjao izabranu destinaciju, rutu ili ETA.
- Recalculate više ne tvrdi da menja rutni policy; prikaz je označen kao „Demo route” i „Simulated”.
- Map kontrole imaju eksplicitne Semantics labele, enabled/toggled stanje i 48 dp hit zone.
- Voice toggle ima 48 dp hit zonu i spoken toggle semantics.

Fajlovi:

- `lib/screens/navigation/navigation_screen_content.dart`
- `test/widget_test.dart`

### Media

- Playback timer više ne radi periodično dok je playback pauziran.
- Uklonjen je ugnježdeni `setState` pri prelasku pesme.
- Spectrum od 24 widgeta zamenjen je jednim CustomPainter-om.
- Source kontrole imaju veću hit zonu i selected Semantics stanje.
- Prethodno postojeći DriveModeService media guard je zadržan; browsing se sakriva dok je demo režim `driving`.
- Dodatni test potvrđuje da se playback position ne menja dok je pauziran.

Fajlovi:

- `lib/screens/media/media_screen_content.dart`
- `lib/services/drive_mode_service.dart`
- `test/widget_test.dart`

### Tema i jasnoća demo podataka

- `AppTheme.theme()` je sada povezan sa aplikacijom umesto paralelnog inline `ThemeData`.
- Osnovni AppColors tokeni su usklađeni sa dark UI paletom.
- Vehicle kartica ima vidljivu `DEMO DATA` oznaku.
- Header connectivity i clock status imaju Semantics oznake da su simulirani.
- Phone kartica više ne prikazuje stvarno ime/broj uređaja.

Fajlovi:

- `lib/main.dart`
- `lib/core/theme/colors.dart`
- `lib/core/theme/theme.dart`
- `lib/widgets/cards/vehicle_card.dart`
- `lib/widgets/header/header.dart`
- `lib/widgets/cards/phone_card.dart`

### Lokalni launcher i web hardening

- Server je vezan samo na `127.0.0.1`, ne na sve interfejse.
- Koristi se privremeni port; fiksni port 8080 više nije deljeni interfejs.
- Socket se uspešno bind-uje pre pokretanja browsera.
- Browser se traži samo u poznatim instalacionim putanjama, ne kroz nepouzdani `PATH` lookup imena `chrome.exe`.
- Nevalidan `Host` header dobija HTTP 403.
- Dodati su CSP, `nosniff`, anti-framing, same-origin, no-referrer i no-store header-i.
- Uklonjen je CPU busy-loop; shutdown čeka na `Event`.
- Android backup je eksplicitno isključen za ovaj prototip.
- Web build koristi custom Flutter bootstrap sa lokalnim `canvaskit/` izvorom.
- `run_app.py` pri svakom pokretanju pokreće `flutter build web --release --no-web-resources-cdn --csp` i upisuje hash-based build stamp.
- `run_app.bat` obezbeđuje da se build pokreće iz root direktorijuma projekta.
- Launcher odbija build bez lokalnog CanvasKit/CSP konfiguracije ili sa zastarelim bundle hash-om umesto da otvori prazan ili netačan bundle.
- Headless Chrome smoke test potvrdio je da dashboard renderuje pod novim CSP-om na 1680×720.

Fajlovi:

- `run_app.py`
- `run_app.bat`
- `web/flutter_bootstrap.js`
- `android/app/src/main/AndroidManifest.xml`
- `README.md`

## Preostali UX blokeri

### U-01: Nema centralne vozačke restrikcije

**Ozbiljnost: Blocker za povezano vozilo**

Trenutni `DriveModeService` je demo/debug mehanizam. Samo Media koristi njegovo stanje za zabranu browsiranja. Telefon, navigacija, climate i ostale kontrole nemaju zajedničku interakcijnu politiku.

Potrebna je odobrena klasifikacija akcija:

- allowed;
- locked with visible reason;
- deferred;
- voice-only;
- safety-independent/pasive.

Ne treba koristiti debug toggle kao trust source za buduće bezbednosne odluke.

### U-02: Call session nije trajan

**Ozbiljnost: Visoko**

Demo poziv počinje i traje unutar `PhoneScreen`. Home trenutno blokira module i Back dok je poziv aktivan, ali session i dalje nije trajan kroz app lifecycle ili buduće rute. Nema pozivnog HUD-a, minimizacije, accept/reject modela, prekida veze, država `held`, `failed`, `disconnected` ni perzistentnog service owner-a.

Pre izgradu `CallSessionService` potrebni su lifecycle state machine i odluka šta radi X/Back tokom poziva.

### U-03: Vozačka zona nije konfigurabilna

**Ozbiljnost: Visoko za novi proizvod**

Fiksni 7:4:5 grid stavlja Navigation na krajnju desnu stranu. Nema LHD/RHD konfiguracije, primary driver zone, seat calibration, arm reach merenja ni odluke o tome koje informacije nikada ne smeju nestati.

Za povezani vozilo potrebno je potvrditi hijerarhiju: next maneuver/current speed, navigacija, kontakt zvuka i climate prema domaćem vozaču.

### U-04: Nekontrolisani session state i demo kontrole

**Ozbiljnost: Visoko**

Playback, izabrana pesma, volume, call state i navigation selection žive u ekranskim `State` klasama. Zatvaranje overlay-a ih uništava. Dashboard kartice imaju odvojeno stanje.

Pre backend/session integracijom potrebni su:

- `MediaSessionService` sa trvnim playback state-om;
- `CallSessionService` sa eksplicitnim stanjima;
- navigation route/session model;
- dogovor da li se stanje čuva kroz module i suspend/resume.

Media shuffle/repeat i sound-stage kontrole i dalje menjaju samo lokalni UI state; moraju biti povezane sa audio HAL-om ili eksplicitno označene kao demo izbori.

### U-05: Nema failure/loading/empty/stale modela

**Ozbiljnost: Visoko za povezani prototip**

Moduli nemaju standardna stanja:

- loading;
- empty;
- offline;
- stale;
- error;
- retry;
- unavailable;
- degraded/fault.

Vozilni podaci ne mogu prikazati poslednju vrednost bez vremena prijema, validity intervala, izvora ili fault statusa.

### U-06: Fokus, fizičke mete i input nisu validirani

**Ozbiljnost: Visoko**

Dio kontrola je pretvoren u 48 dp programmatic minimum i dodat je Semantics, ali sledeće nije provereno:

- fizičke milimetre mete;
- rukavice, mokri prsti i vibracije;
- rotary knob, steering-wheel controls i funkcijske tastere;
- Android Back na svim platformama;
- keyboard traversal i focus restoration;
- TalkBack, VoiceOver ili head-unit screen reader;
- focus ring kontrast i reduced-motion ponašanje.

### U-07: Responzivnost nije dokazana van baseline-a

**Ozbiljnost: Visoko**

Testovi i vizuelni smoke test koriste 1680×720. Fiksne širine i visine phone/media/navigation layout-a nisu testirane na najmanjoj podržanoj rezoluciji, portrait fallback-u, text scaler-u 1.3/1.5/2.0, RLT ili dugim lokalizacijama.

Ne treba tvrditi „responsive” dok rezoluciona i text-scale matrica ne prođu bez overflow-a i gubitka kritičnih kontrola.

### U-08: Čitljivost i kontrast traže optičko testiranje

**Ozbiljnost: Srednje do visoko**

Mnogo sekundarnog teksta koristi 8–12 px i opacity boje. Statički proračun za česte kombinacije daje približno 3.2–4.5:1, što je marginalno za mali tekst. Nema rezultata merenja na stvarnom panelu pri:

- direktnom suncu;
- noćnom režimu;
- viewing angle-u;
- lokalnom dimu;
- udaljenosti očiju vozača;
- vibracijama.

Finalne veličine moraju biti određene optical testom, ne nasumičnim povećanjem font size-a.

### U-09: Climate nema vozilo-specifične limite

**Ozbiljnost: Visoko pre HVAC integracije**

Temperaturama i fanu nisu dati min/max, kvantizacija, unit policy, stale/fault state ni command confirmation. Ne sme se vezati za stvarni HVAC dok vozilo/CAN vlasnik ne potvrdi validne range i safety behavior.

## Preostali arhitektonski rizici

### A-01: Widgeti i dalje drže poslovnu i session logiku

`MediaScreenContent`, `PhoneScreen`, `NavigationScreenContent` i `ClimateBar` imaju velike `State` klase. Modeli za media, call i route nisu izdvojeni u `models/`, a servisi ne postoje za većinu domena.

Ovo je tehnički dug za male module, ali velika regresiona površina. Ne preporučuje se novi state framework samo zato što postoji; prvo treba izdvojiti čiste domenske state/value objekte i testirati ih bez pumpanja celog UI-a.

### A-02: Prekoračenje veličine fajlova

Pre izmena:

- Home: približno 700 linija;
- Media: približno 1200 linija;
- Navigation: približno 1420 linija;
- Phone: približno 1580 linija;
- Climate: približno 475 linija.

Ovo je u suprotnosti sa pravilom u `docs/architecture.md` da jedan widget bude približno do 300 linija. Ne treba raditi veliki rewrite; deliti prirodne sekcije kada se sledeći put menjaju.

### A-03: Dizajn sistem je samo delimično runtime izvor

`AppTheme` je sada povezan, ali ekrani i dalje pretežno koriste inline `Color`, `TextStyle`, radius i spacing vrednosti. Design tokens i dalje nisu jedini izvor istine. Uveden je samo deo standardizacije.

### A-04: Nema jedinstvenog data-state ugovora

Safety-relevant podaci nemaju verzionisan schema, valid range, unit, timestamp, freshness, source, authority ili fault code. UI ne može dokazati da je prikazana vrednost došla iz odobrenog izvora.

## Preostali performansni rizici

### P-01: Navigacija i dalje ima skup blur stack

Expanded navigation koristi više `BackdropFilter` slojeva: destination card, turn banner, svaki destination chip, map controls, telemetry bar i close control. Crossfade dodaje opacity layere. Stvarni GPU/raster trošak mora se meriti.

Pre optimizacije ne treba nasumično dodavati `RepaintBoundary`; prvo snimiti Flutter DevTools timeline i layer tree na ciljnom GPU-u.

### P-02: Home overlay i dalje gradi ceo content subtree u animation builderu

`AnimatedBuilder` postoji oko svakog overlay-a. Proveriti da li `child` i state tokom tranzicije stvaraju nepotrebne layout/paint pass-e. Ne menjati bez profila.

### P-03: Custom map i dalje alocira Paint/Path svaki repaint

VectorMapPainter nije keširao statičke putanje, blokove i shader-e. Ukinuti neproduktivni flow controller je smanjenje, ali mapni repaint i dalje ima prostor za lokalni profil.

### P-04: Phone call timer rebuilduje ceo PhoneScreen

Timer je pravilno cancel-ovan na `dispose`, ali svaka sekunda active call poziva `setState` nad celim ekranom. Prebaciti trajanje u lokalni `ValueNotifier` ili izdvojeni call HUD tek kada se stabilizuje call session.

### P-05: Media scrubbing i volume i dalje rebuilduju ceo hero

Slider callback-i menjaju parent state. Proveriti broj build/layout pass-eva u profile trace-u pre uvođenja lokalnih notifiera.

### P-06: Web startup i font fallback

CanvasKit je sada lokalno vezan za `canvaskit/`, a CSP-compatible build je uspešno generisan. Međutim Flutter web i dalje podrazumevano koristi `https://fonts.gstatic.com/s/` za fallback fontove; CSP dozvoljava samo taj font domen.

Za potpuno offline automotive runtime potrebno je bundlovati odobren font u repo/bundle i postaviti lokalni `fontFallbackBaseUrl` ili `fontFamily`. To nije urađeno u ovom auditu jer bi izbor i licenca fonta morala biti odobrena.

### P-07: Slika vozila nema ciljnu decode veličinu

`car_render.png` je 1198×576 i prikazuje se bez `cacheWidth`/`cacheHeight`. Proveriti decoded memory i first-frame cost na svakom ciljnom DPR-u.

## Preostali sigurnosni blokeri

### S-01: Android release koristi debug signing

**Ozbiljnost: Blocker za svaki deljeni release artifact**

Trenutno:

- `namespace = "com.example.skyui"`;
- `applicationId = "com.example.skyui"`;
- release build koristi `signingConfigs.getByName("debug")`.

Potrebni su ownership-definisan reverse-DNS identitet, produkcioni keystore van repozitorijuma, fail-closed release config i verifikacija potpisa artefakta. Ne kreirati ključeve bez vlasničkog i release procesa.

### S-02: Placeholder identitet je prisutan i na drugim platformama

Android package, Kotlin package, iOS/macOS bundle ID i Linux application ID nisu potvrđeni kao Veltron-owned identiteti. Promena application ID-a može prekinuti update path.

### S-03: Mock telemetrija mora ostati fail-closed

Baterija, range, doors, speed, tire values, connectivity i climate su fixture podaci. Za eventualni vehicle build:

- ne prikazivati mock safety telemetry kao pouzdanu vrednost;
- uvesti `source`, `receivedAt`, `validUntil`, `quality`, `fault` i `isSimulated`;
- odbaciti ili eksplicitno degradirati stale podatak;
- ne dozvoliti UI sloju da bude gateway prema aktuatorima.

### S-04: Demo kontakti moraju ostati sintetički

Stari source, README, changelog, Git history i prethodni web artefakti mogu sadržati imena/brojeve koji izgledaju kao stvarni podaci. Novi Dart fixture-i su sintetički, ali stari podaci se ne mogu ukloniti iz istorije običnim novim commitom.

Vlasnik podataka mora potvrditi da su prethodne vrednosti bile sintetičke. Ako nisu, potreban je incident/privacy proces i odluka o sanitizaciji history-ja.

### S-05: Android backup je onemogućen, ali data-extraction mora biti potvrđena na ciljnoj OS verziji

`android:allowBackup="false"` je dodat. Za Android 12+ i automotive device-management policy treba validirati merged manifest, device-owner/kiosk ponašanje i backup/data-extraction pravila na konkretnom OS-u.

### S-06: Nema CI, SBOM ni release provenance gate-a

Nema potvrđenog CI workflow-a, dependency scan gate-a, SBOM-a, commit provenance-a ni obavezne clean release komande. Treba dodati:

- `flutter pub get --enforce-lockfile`;
- format check;
- analyze;
- test;
- web/native release build;
- dependency/vulnerability scan;
- secret scan;
- SBOM;
- artifact hash i signing verification.

### S-07: Gradle wrapper provenance nije potvrđena

Trenutni wrapper config ne sadrži `distributionSha256Sum`, a verzija lokalnog wrapper JAR-a nije proverena against oficijalnim checksum-om. Ne treba pretpostaviti da je lokalni cache tačan.

### S-08: Nema povezanog backend/CAN/IPC attack surface-a

Dart kod trenutno nema network client, MethodChannel, EventChannel, WebView, storage, contacts, Bluetooth, GPS, CAN/OBD, audio HAL ili OTA integraciju. Zato nije moguće auditovati:

- backend authentication/authorization;
- TLS i key rotation;
- command authorization;
- CAN gateway injection;
- replay/sequence protection;
- OTA signing i anti-rollback;
- secure boot i rollback;
- data retention i consent.

To nije dokaz da ti slojevi neće postojati. Pre integracije moraju imati TARA/HARA, data-flow model i odvojenu security boundary od infotainment HMI-ja.

### S-09: Nijedan pronađeni secret nije dokaz bezbednog release-a

Nisu pronađeni API ključevi, JWT-ovi, privatni key-evi, lozinke ili cloud credentials u tekstualnom source-u i dostupnoj Git istoriji. Ovo ne pokriva bespoke formate, ignored lokalne cache-e, native binary dependency-e ili organizacioni secret store.

## Šta nije moglo da se proveri iz ovog repozitorijuma

1. Stabilnost 60 FPS, p50/p95/p99 frame time, missed frames, UI/raster/GPU workload i input latency.
2. CPU, memory, image cache, GPU buffer i long-running memory growth na ciljnom automotive SoC-u.
3. Fizička veličina touch meta u milimetrima i razdvajanje kontrola.
4. Rukavice, mokri prsti, vibracije, slepi putnici i 5./95. percentil korisnika.
5. Čitljivost na stvarnom panelu, direktno sunce, noćni režim, gamma, viewing angle i lokalni dim.
6. Funkcionalni tasteri, rotary controller, steering-wheel commands i voice fallback.
7. Android Back, keyboard focus, Escape/Enter/Space, TalkBack/VoiceOver i focus restoration na uređaju.
8. Screen off/on, suspend/resume, app switch, service restart, poziv pre navigacije i playback continuity.
9. CAN/OBD/LIN/AVB signal validity, stale/fault handling, gateway trust i command authorization.
10. Bluetooth, LTE, Wi-Fi, GPS, contacts, telephony, DTMF, audio HAL i HVAC komande.
11. OTA signed manifest, anti-rollback, A/B update, rollback, secure boot i key management.
12. Android/iOS/macOS/Windows/Linux release artifact, merged manifest, runtime permissions, signing i notarization.
13. Browser CSP/COOP/COEP runtime na svim ciljnim browserima; potvrđen je samo headless Chrome smoke na lokalnom bundle-u.
14. Potpuno offline web startup za font fallback; trenutni dozvoljeni fallback je `fonts.gstatic.com`.
15. Backend API, TLS, autentikacija, authorization, token rotation, storage i cloud retention jer ne postoje u projektu.
16. Organizacioni code ownership, branch protection, CI audit log, remote security posture i developer machine hardening.
17. ISO 26262, SOTIF, UNECE R155/R156, ISO/SAE 21434 i druge compliance/assurance aktivnosti.
18. Bezbednosna HARA/TARA, safety case, hazard analysis i dokaz odvajanja HMI-ja od safety-critical funkcija.
19. Zaštita privatnosti i retention za kontakte, pozive, GPS, glas, slike, profil i dijagnostiku.
20. Pravni status placeholder identiteta, debug/release ključeva i prethodno objavljenih imena/brojeveva.
21. Funkcionalni heat, power, memory i storage test na stvarnoj automobilskoj jedinici tokom dugog rada.
22. Validacija verzije 1680×720 kao fizičkog DPI, brightness i panel refresh-rate profila.

## Verifikacija izvršena tokom audita

- Baseline pre izmena: `flutter analyze` bez grešaka; postojeći testovi prošli.
- Finalna Dart provera: `flutter analyze` bez grešaka.
- Finalni widget testovi: svih 9 testova prošlo.
- Python launcher syntax: `python -m py_compile run_app.py` prošao.
- Launcher HTTP smoke: dozvoljen loopback Host vratio 200 i CSP/security header-e; nevalidan Host vratio 403.
- Web release build: `flutter build web --release --no-web-resources-cdn --csp` prošao.
- Generisani bootstrap: `canvasKitBaseUrl` je `canvaskit/`; lokalni CanvasKit fajlovi su prisutni.
- Headless Chrome: dashboard je renderovan na 1680×720 pod CSP-om i tekst je vidljiv kada je font fallback domen dostupan.

## Preporučeni release gate

Pre bilo kakvog pilota, povezivanja na vozilo, aktuatora ili javnog puta potrebno je zatvoriti ove gate-ove redom:

1. **Klasifikacija release-a i pravni odobrenje:** potvrditi ciljnu platformu, klasu distribucije, ovlašćeno lice, package/bundle identity, privatnost i operativna ograničenja.
2. **Reproducibilan clean build:** enforce lockfile, format/analyze/test, generisati artifact iz čistog checkout-a i odbiti neodobrene izvore.
3. **Supply-chain kontrole:** SBOM, dependency/vulnerability/secret/license scan, Gradle wrapper verification i artifact provenance.
4. **Produkcioni identitet i potpis:** odobreni identity, potpis van repozitorijuma, verifikacija potpisa, artifact hash i potvrđen update path.
5. **Security i safety engineering:** TARA/HARA, data-flow model, HMI/HAL/CAN trust boundary, threat controls i odgovarajući compliance/safety dokaz.
6. **Driver-interaction i session contract:** odobrena politika parked/driving i trajni call/media/navigation/climate state modeli.
7. **Signal contract:** source, timestamp, freshness, validity range, unit, quality, fault i simulation state pre prikaza ili komande.
8. **Target-platform validacija:** rezolucija, text scale, keyboard, accessibility, fizički touch, performance, memory, thermal, lifecycle i long-duration test.
9. **Offline/runtime validacija:** lokalni fontovi, network trace bez spoljašnjeg fetcha i CSP/COOP/COEP na svim podržanim browserima.
10. **Lab/HIL/non-actuating vehicle validacija:** signal validity, fault handling, restart, suspend/resume, gateway trust i command authorization bez aktuatora.
11. **Safety-instrumented canary:** samo nakon pisanog odobrenja validirane konfiguracije, rollback plana, monitoringa, incident response-a i operativnih ograničenja.

## Konačna preporuka

Trenutnu verziju zadržati kao interni simulator i koristiti za UX iteracije. Ne predstavljati je kao automotive-grade, 60 FPS proverenu, cyber-secure ili sposobnu za povezivanje sa vozilom dok se preostali blokeri ne zatvore i ne potvrde na ciljnoj platformi.
