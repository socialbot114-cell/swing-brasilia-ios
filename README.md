# Swing Brasília — iOS

Guia editorial offline da comunidade liberal de Brasília, para iPhone. O app porta o portal `swingbrasilia.fun` para SwiftUI nativo, sem conta, sem anúncios, sem rede e sem coleta de dados.

- Bundle identifier: `br.com.swingbrasilia.fun`
- App Store Connect ID: `6813728967`
- Team: `SRN7AW424S`
- iOS 17+, somente iPhone, 18+ (age gate na primeira abertura)

## Telas

- **Início** — hero, "Comece no seu ritmo", prévia do guia e ponte B2B.
- **Explorar** — diretório offline de 25 locais com busca e filtros (casas, motéis, sex shops, iniciantes).
- **Comunidade** — regras de consentimento e privacidade com aceite consciente antes do WhatsApp.
- **Tecnologia** — soluções para casas, eventos e negócios +18.

## Desenvolvimento (macOS)

```sh
brew install xcodegen
cd iosApp
xcodegen generate
xcodebuild -project SwingBrasilia.xcodeproj -scheme SwingBrasilia \
  -sdk iphonesimulator -configuration Debug build CODE_SIGNING_ALLOWED=NO
```

No Linux, valide o conteúdo com `python3 scripts/validate_content.py`.

## Estrutura

- `iosApp/` — app SwiftUI + XcodeGen (`project.yml`), `Sources/`, `Resources/` e `Tests/`.
- `scripts/` — validação de conteúdo e criação de bundle/cert/profile no App Store Connect.
- `.github/workflows/` — `ios.yml` (build/test) e `ios-release.yml` (TestFlight).
- `docs/` — pacote de submissão, captura de screenshots e créditos de imagem.

## CI / TestFlight

Os segredos do repositório (`APPLE_API_KEY_P8`, `APPLE_API_KEY_ID`, `APPLE_API_ISSUER_ID`, `APPLE_DISTRIBUTION_CERT`, `APPLE_DISTRIBUTION_KEY`, `APPLE_PROVISIONING_PROFILE`) são usados pelo `ios-release.yml`, que arquiva, exporta e envia o IPA ao TestFlight via `altool`.
