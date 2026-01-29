# API Cielo - Links de Pagamento (Delphi 10.2 VCL)

## Passo a passo rapido
1) Abra o projeto `Apicielo.dpr` no Delphi 10.2.
2) Compile e execute.
3) Aba `Configuracao e Autenticacao`:
   - Preencha `MerchantId`, `MerchantKey`, `Ambiente API` e `Timeout`.
   - Clique em `Salvar INI` (gera `apicielo.ini`).
   - Use `Testar Auth` para validar credenciais (usa `PaymentId` informado).
4) Aba `Geracao e Consulta`:
   - Preencha os campos para criar o link (expiracao, titulo, descricao, pedido, valor, parcelas, tipo, URL retorno).
   - Opcionalmente marque `Captura` e `Autenticacao`.
   - Use `MerchantDefinedFields` (id=valor) para dados adicionais. Ex: `1=PreVenda123`.
   - Clique `Gerar Link` para enviar `POST /1/sales`.
   - Use `PaymentId` em `Consulta / Resultado` para `GET /1/sales/{PaymentId}`.
   - O painel de retorno mostra dados detalhados + JSON bruto no final.
5) Aba `Logs`:
   - Acompanhe os logs em tela ou clique `Abrir arquivo`.
   - O retorno bruto da API tambem e registrado no log.

## Arquivos principais
- `src\uCieloConfig.pas`: carrega/salva autenticacao e ambiente no INI.
- `src\uCieloApi.pas`: cliente HTTP para POST/GET da API.
- `src\uCieloInterpreter.pas`: interpreta retorno, status e erros com mensagem amigavel.
- `src\uLogger.pas`: grava logs e exibe em tela.
- `src\uMain.pas`: UI e fluxo da aplicacao.

## Como usar a classe de interpretacao
### Instanciacao e uso
```delphi
var
  Interpreter: TCieloReturnInterpreter;
  ApiResponse: TCieloApiResponse;
  ResultData: TCieloReturn;
begin
  Interpreter := TCieloReturnInterpreter.Create;
  try
    ApiResponse := Api.PostSales(PayloadJson);
    ResultData := Interpreter.Interpret(ApiResponse);
    ShowMessage(ResultData.StatusMessage);
  finally
    Interpreter.Free;
  end;
end;
```

### Proposito de metodos e propriedades
- `Interpret`: recebe o retorno bruto e produz um `TCieloReturn` padronizado.
- `StatusToText`: converte o enum de status em texto legivel.
- `TCieloReturn`:
  - `Status/StatusMessage`: status da transacao (mapeado).
  - `FriendlyMessage`: mensagem amigavel baseada em status/erro.
  - `PaymentId/Tid/ReturnCode/ReturnMessage`: dados do pagamento.
  - `AuthorizationCode/Nsu/Brand`: identificadores do adquirente.
  - `LinkUrl/LinkShortUrl`: URL do link (quando retornada pela API).
  - `ErrorCode/ErrorMessage`: erro mapeado quando a API retorna falha.
  - `RawJson/HttpStatus`: retorno bruto para auditoria.

## Integracao com o fluxo de geracao/consulta
No formulario principal, `btnCreateLinkClick` e `btnConsultClick`:
- Enviam a requisicao (`uCieloApi.pas`).
- Chamam `TCieloReturnInterpreter.Interpret`.
- Exibem status, codigos e o JSON bruto.

## Orientacoes para futuras atualizacoes
- Novos campos de envio:
  - Atualize `BuildCreatePayload` em `src\uMain.pas`.
  - Se desejar, mova o builder para uma classe dedicada.
- Novos status:
  - Atualize `MapStatus` e `StatusToText` em `src\uCieloInterpreter.pas`.
- Novos codigos de erro:
  - Ajuste a leitura de `Error`, `Code` e `Message` na interpretacao.
- Novos endpoints:
  - Adicione metodos em `src\uCieloApi.pas`.

## Observacoes
- O campo `JSON adicional` permite anexar um objeto JSON a `AdditionalData`.
- `Testar Auth` chama `GET /1/sales/{PaymentId}` e ajuda a validar credenciais.
