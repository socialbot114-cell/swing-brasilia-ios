# Playbook de Lançamento de Apps iOS

Este documento registra o processo usado para criar, testar, publicar e enviar o Swing Brasília para revisão. Ele serve como checklist reutilizável para o próximo app.

## 1. Antes de Começar

Defina estes dados antes de criar o projeto:

- Nome público do app.
- Bundle ID único, por exemplo `br.com.empresa.app`.
- SKU interno.
- Nome do produto ASCII para evitar problemas de build, por exemplo `MeuApp`.
- Nome exibido, que pode conter acentos.
- Categoria primária e secundária.
- URL de suporte, marketing e política de privacidade.
- Nome, telefone e e-mail do contato de revisão.
- Se o app coleta dados, usa anúncios, analytics, login, pagamentos ou conteúdo gerado por usuários.
- Direitos de todas as imagens, fontes, textos e marcas usados no app.

Não inclua credenciais, certificados privados, tokens ou chaves neste arquivo ou no repositório.

## 2. Criar o Projeto SwiftUI

Estrutura recomendada:

```text
iosApp/
  project.yml
  Sources/
  Resources/
  Tests/
  ExportOptions.plist
docs/
scripts/
.github/workflows/
```

Boas práticas usadas:

- SwiftUI com deployment target iOS 17 ou superior.
- XcodeGen para gerar o `.xcodeproj` de forma reprodutível.
- Catálogo offline em JSON quando o app não precisa de backend.
- `PrivacyInfo.xcprivacy` incluído no bundle.
- `PRODUCT_NAME` somente ASCII.
- Bundle ID fixo e igual ao App ID do Apple Developer.
- Testes unitários para catálogo, filtros e regras de negócio.
- Age gate para apps destinados a adultos.
- Navegação independente dentro de cada aba usando `NavigationStack`.

Gerar o projeto localmente:

```bash
brew install xcodegen
cd iosApp
xcodegen generate --spec project.yml
```

## 3. Validar Conteúdo

Antes do build, valide conteúdo e direitos:

```bash
python3 scripts/validate_content.py
```

Confirme especialmente:

- URLs válidas.
- Texto sem promessas proibidas ou conteúdo explícito desnecessário.
- Classificação 18+ coerente com o conteúdo.
- Créditos e licença das imagens.
- Política de privacidade publicada.
- Nenhuma informação privada no catálogo ou nas notas públicas.

## 4. Configurar Apple Developer

No Apple Developer/App Store Connect:

1. Crie o App ID com o Bundle ID definitivo.
2. Crie uma chave de API do App Store Connect.
3. Crie certificado de distribuição.
4. Crie provisioning profile de distribuição para o Bundle ID.
5. Crie o app no App Store Connect com o SKU correto.
6. Anote o App Store Connect ID.

Para CI, configure estes secrets no GitHub:

```text
APPLE_API_KEY_P8
APPLE_API_KEY_ID
APPLE_API_ISSUER_ID
APPLE_DISTRIBUTION_CERT
APPLE_DISTRIBUTION_KEY
APPLE_PROVISIONING_PROFILE
```

Os arquivos de certificado, chave e profile devem ser codificados em Base64 antes de virar secret. Nunca faça commit desses arquivos.

### Atenção a certificados

Certificados Apple têm limites de quantidade. Revogar um certificado usado por outro app pode quebrar futuras atualizações desse app. Antes de revogar qualquer certificado, identifique todos os projetos que dependem dele e planeje a migração.

## 5. Pipeline de TestFlight

O workflow de release deve executar nesta ordem:

1. Checkout.
2. Validar secrets obrigatórios.
3. Validar conteúdo.
4. Instalar XcodeGen.
5. Gerar o projeto.
6. Validar versão do Xcode/SDK.
7. Rodar testes em Simulator sem assinatura.
8. Restaurar a chave de API.
9. Instalar certificado, chave e provisioning profile em keychain temporário.
10. Fazer archive Release assinado.
11. Validar o `.xcarchive` e o `.ipa`.
12. Enviar para TestFlight com `xcrun altool`.
13. Limpar keychain, profile e arquivos temporários.

Comando para disparar:

```bash
gh workflow run ios-release.yml --repo ORGANIZACAO/REPOSITORIO
```

Verifique no App Store Connect se o build está `VALID` antes de anexá-lo à versão.

## 6. Screenshots com GitHub Actions

O workflow de screenshots deve:

1. Gerar o projeto.
2. Compilar para Simulator sem assinatura.
3. Selecionar e inicializar um iPhone.
4. Instalar o app.
5. Capturar age gate e telas principais.
6. Enviar as imagens como artifact.

Para controlar a tela sem depender de toques frágeis, o app pode ler variáveis de ambiente apenas no modo de captura:

```text
SWING_SKIP_AGE=1
SWING_TAB=0|1|2|3
```

O `simctl` recebe essas variáveis via prefixo `SIMCTL_CHILD_`:

```bash
SIMCTL_CHILD_SWING_SKIP_AGE=1 \
SIMCTL_CHILD_SWING_TAB=1 \
xcrun simctl launch DEVICE_UDID br.com.empresa.app
```

### Tamanhos importantes

O App Store Connect separa screenshots por família de tela. Para o slot de iPhone 6,5", use:

```text
1242 x 2688 px
```

Para o slot de iPhone 6,7", use normalmente:

```text
1290 x 2796 px
```

Alguns runners macOS não possuem o simulador exato de 6,5". Nesse caso, capture a tela no simulador disponível e converta o arquivo para `1242 x 2688` com `sips` no workflow. Verifique o arquivo final com:

```bash
file screenshots/*.png
```

Não basta renomear a extensão. O PNG deve realmente ter as dimensões corretas.

### Conteúdo recomendado

Use entre 3 e 5 imagens que mostrem valor rapidamente:

1. Entrada/age gate.
2. Tela inicial com a proposta principal.
3. Diretório ou catálogo.
4. Detalhe de um item importante.
5. Regras, comunidade ou principal funcionalidade secundária.

Antes do upload, verifique visualmente:

- Nenhum texto cortado nas laterais.
- Nenhum filtro ou botão saindo da tela.
- A tab bar não cobre conteúdo importante.
- O CTA principal está inteiro e legível.
- O tamanho da fonte é legível no screenshot completo.
- As imagens representam o build que será enviado.

### Problemas encontrados neste projeto

- Um `ScrollView` sem `.frame(maxWidth: .infinity)` fez o hero da home ficar largo demais e cortou texto nas laterais.
- A tab bar flutuante do iOS mais recente cobriu o final de algumas telas. Foi necessário adicionar espaço inferior com `.safeAreaPadding(.bottom, 96)`.
- `NavigationLink` e `navigationTitle` precisam estar dentro de `NavigationStack` em cada aba.
- O runner inicialmente gerou `1320 x 2868`, que é 6,9", apesar do seletor tentar priorizar outro modelo. O workflow passou a filtrar modelos preferenciais e também normalizar a dimensão final.

## 7. App Store Connect: Metadados

Na versão iOS do app, preencha:

- Nome.
- Subtítulo.
- Descrição.
- Palavras-chave.
- Texto promocional.
- Copyright.
- URLs.
- Screenshots do tamanho correto.
- Build válido.
- Notas de revisão.
- Informações de contato.
- Forma de lançamento.

O contato de revisão é obrigatório e deve conter nome, sobrenome, telefone e e-mail reais.

O campo `What's New` pode ficar bloqueado pela API em alguns estados. Quando isso acontecer, edite pelo painel web.

## 8. Categoria, Classificação e Direitos

Em `App Information`:

- Escolha uma categoria primária obrigatória, por exemplo `Lifestyle`.
- Escolha uma categoria secundária somente se fizer sentido, por exemplo `Reference`.
- Complete a classificação etária de acordo com o conteúdo real.
- Confirme os direitos de conteúdo e imagens.
- Complete export compliance. Para um app que não implementa criptografia própria, normalmente declare que não usa criptografia não isenta.

Nunca escolha categoria ou classificação apenas para passar na validação. O conteúdo do app, screenshots, descrição e respostas precisam ser coerentes.

## 9. App Privacy

Na página `App Privacy`, responda de acordo com o comportamento real do app.

Para um app offline sem login, analytics, anúncios, backend ou rastreamento:

1. Selecione `No, we do not collect data from this app`.
2. Salve a resposta.
3. Confirme que a política de privacidade está publicada e acessível.

Não declare “Data Not Collected” se qualquer SDK, analytics, publicidade, login ou serviço externo coletar dados.

## 10. Política de Privacidade

A URL informada deve abrir publicamente em HTTPS, sem login. Ela deve explicar, no mínimo:

- Quais dados são coletados.
- Se existe conta ou login.
- Se há analytics, anúncios ou rastreamento.
- Uso de armazenamento local, como confirmação de idade.
- Compartilhamento com terceiros.
- Forma de contato do responsável.
- Como solicitar informações ou exclusão, quando aplicável.

O link precisa estar online antes de enviar para revisão.

## 11. Notas de Revisão

As notas devem permitir que o revisor teste sem adivinhar o fluxo:

```text
O app funciona offline e não exige conta.

1. Abra o app e confirme a idade.
2. Navegue pela tela inicial.
3. Abra o diretório e use busca e filtros.
4. Toque em um item para abrir seus detalhes.
5. Abra Comunidade e leia as regras.
6. Abra Tecnologia para consultar as soluções para negócios.

Não há login, compras, anúncios, permissões especiais, conteúdo gerado por usuários ou conteúdo explícito.
```

Se houver um fluxo difícil de descobrir, explique-o nas notas. Não use dados de teste ou credenciais que não funcionem.

## 12. Checklist Final

- [ ] Bundle ID e SKU definitivos.
- [ ] Build Release assinado enviado ao TestFlight.
- [ ] Build anexado à versão correta.
- [ ] Screenshots do tamanho correto carregadas no slot correto.
- [ ] Nenhuma tela com texto cortado ou CTA escondido.
- [ ] Nome, subtítulo, descrição e keywords revisados.
- [ ] Categoria primária selecionada.
- [ ] Classificação etária concluída.
- [ ] App Privacy concluída.
- [ ] Política de privacidade online.
- [ ] Direitos de conteúdo confirmados.
- [ ] Export compliance respondido.
- [ ] Informações de contato preenchidas.
- [ ] Notas de revisão preenchidas.
- [ ] Forma de lançamento escolhida.
- [ ] Botão `Add for Review` testado.
- [ ] Item submetido e estado alterado para `Waiting for Review`.

## 13. Diagnóstico Rápido

### “É necessário carregar uma captura de tela para telas do iPhone de 6,5 polegadas”

- Confirme que a imagem está na aba `iPhone`, não `iPad`.
- Confirme as dimensões reais com `file` ou `sips -g pixelWidth -g pixelHeight arquivo.png`.
- Use `1242 x 2688` para o slot de 6,5".
- Aguarde o processamento do upload antes de tentar adicionar para revisão.

### “É necessário selecionar uma categoria primária”

- Vá para `App Information`.
- Escolha uma categoria no campo `Primary`.
- Clique em `Save` e aguarde a confirmação.

### “Administrador deve fornecer informações sobre privacidade”

- Abra `App Privacy` com uma conta Administrador.
- Selecione a resposta correta sobre coleta de dados.
- Salve o questionário, mesmo quando a opção já aparecer marcada.

### O upload por API não funciona

Nem todos os campos do App Store Connect têm suporte completo pela API. Use o painel web para:

- Screenshots.
- Privacy questionnaire.
- Categoria.
- Informações de contato.
- `What's New` quando bloqueado pela API.
- Adicionar para revisão.

### O navegador pede login

Use um navegador conectado à sessão Apple correta. Confirme visualmente o nome da conta e o app antes de editar. Nunca cole credenciais em comandos ou arquivos do projeto.

## 14. Resultado deste Lançamento

O Swing Brasília foi submetido com sucesso à revisão e ficou no estado `Waiting for Review`. O prazo informado pela Apple foi de até 48 horas, sujeito à fila e às regras atuais da App Store.

Para o próximo app, copie este playbook, substitua os dados específicos e mantenha os workflows de release e screenshots como base.
