# Captura de Screenshots — Swing Brasília

As screenshots enviadas à App Store devem ser capturas reais do build final. Nunca envie artes de referência.

## Preparação

1. Execute o app no Simulator (iPhone 6.7", ex.: iPhone 15 Pro Max) ou em um iPhone real.
2. Gere o projeto com `xcodegen generate` e rode via `xcodebuild`.
3. Certifique-se de iniciar com o age gate visível (apague os dados do app para resetar o `UserDefaults`).

## Telas a capturar (retrato, 1290x2796)

| # | Tela | O que mostrar |
|---|---|---|
| 1 | Age gate | Tela 18+ com o botão "Tenho 18 anos ou mais" |
| 2 | Início | Hero "Brasília além do convencional" |
| 3 | Explorar | Diretório com busca e chips de filtro |
| 4 | Ficha | Detalhe de um local (ex.: Fun Haus Club) |
| 5 | Comunidade | Regras com as duas confirmações e o botão do WhatsApp |

## Comandos úteis

```sh
# Resetar o age gate no Simulator
xcrun simctl erase booted
```

## Observações

- Capture após o build estar `VALID` no App Store Connect.
- Mantenha o texto legível; as fontes devem aparecer com contraste AA.
- Não inclua capturas com conteúdo explícito (o app não possui).
