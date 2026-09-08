# Roteiro de atualização do fork ACBr

Data de início: 08/09/2026

## Objetivo

Atualizar o fork `billbarsch/ACBr` a partir de `ProjetoACBr/ACBr`, preservando somente ajustes próprios que ainda sejam necessários para emissão, consulta, cancelamento ou geração de DANFCom sem ambiente gráfico.

## Estado preservado antes da atualização

- Fork original: `d0b9ec9902`.
- Upstream usado como base: `b08d6e285a`.
- Base comum: `264f2abf52`.
- Tag local de retorno: `acbr-fork-antes-atualizacao-20260908`.
- Backup completo: `backups/acbr-atualizacao-20260908/acbr-fork-completo.bundle`.
- Candidata: branch `atualizacao-acbr-20260908`, criada diretamente sobre o upstream.

## Critério de decisão

- `MANTER`: ajuste ainda ausente na origem e necessário para um fluxo fiscal real ou para a compilação headless.
- `MANTER NA TABELA`: configuração municipal conferida em `acbrcmd/cidades_atualizadas.txt` e reaplicada no INI e no recurso compilado.
- `SUBSTITUÍDO PELO UPSTREAM`: a origem possui solução equivalente ou mais atual.
- `DESCARTAR`: ajuste antigo, genérico sem evidência suficiente ou com risco de regressão na base atual.
- `VALIDAR`: reaplicado, aguardando a compilação final do `acbrcmd`.

## Decisão individual dos commits do fork

| Ordem | Commit | Ajuste | Decisão | Motivo objetivo |
|---:|---|---|---|---|
| 1 | `9040449da4` | Cidades e serviços NFSe | MANTER NA TABELA | Três blocos independentes permanecem ausentes na origem; São Geraldo foi substituído pela configuração final do item 2. |
| 2 | `f4c6123ee1` | São Geraldo do Araguaia | MANTER NA TABELA | Configuração Fiorilli 1.01, serviço nacional, consultas próprias e porta 5661 conferidos. |
| 3 | `60b98e1899` | XML legado ISS São Paulo | MANTER | No layout 1.00 a tag opcional `RetencaoPisCofins` ainda é emitida pela origem e pode causar rejeição. |
| 4 | `804d73c783` | Mesclagem MirrorProjetoACBr | DESCARTAR | O segundo pai já é ancestral do upstream atual; reaplicar só duplicaria uma sincronização histórica. |
| 5 | `0753354301` | Mesclagem MirrorProjetoACBr | DESCARTAR | O segundo pai já é ancestral do upstream atual; reaplicar só duplicaria uma sincronização histórica. |
| 6 | `7849cb07d4` | Endpoint de Brasília | MANTER NA TABELA | Bloco ISSNet nacional reaplicado; o fluxo síncrono e de cancelamento já está no `acbrcmd`. |
| 7 | `5db1724872` | Endpoint oficial de Brasília | MANTER NA TABELA | Representado pela configuração final do INI. |
| 8 | `d0b3ac83f1` | Layouts municipais gerais | DESCARTAR | O ajuste antigo de obra/endereço foi superado pela correção mais completa `ACBR-9738` da origem; tornar `cTribMun` opcional contraria o schema atual. |
| 9 | `ed2a826e57` | Validação Tinus | SUBSTITUÍDO PELO UPSTREAM | O upstream atual já configura `ConfigSchemas.Validar := False` no provedor Tinus. |
| 10 | `6811236492` | DANFCom FPDF sem ambiente gráfico | MANTER | A origem não contém a implementação FPDF, nem nos branches ou pull requests públicos pesquisados; o `acbrcmd` headless a compila explicitamente. |
| 11 | `2f31fc8028` | Grupos de obra e imóvel | DESCARTAR | A origem atual gera endereço nacional, exterior e inscrição do imóvel com estrutura mais completa; reaplicar o código antigo pode regredir campos. |
| 12 | `e5b4bedbb0` | Endpoint João Pessoa | MANTER NA TABELA | Bloco DSF 2.03 municipal reaplicado, com produção, homologação e `Params=*`. |
| 13 | `a6499d6602` | Envio REST DSF | SUBSTITUÍDO PELO UPSTREAM | A origem já possui preparação de arquivo, URL com caminho e envio GZip/Base64 para DPS e eventos. |
| 14 | `59bfe9b2f0` | Serviços João Pessoa | MANTER NA TABELA | Representado pela configuração final do INI. |
| 15 | `1c0b6881a9` | Retorno SigISSWeb | MANTER | A origem ainda não normaliza retorno/token nem marca resposta bem-sucedida; necessário para login, cancelamento e resposta do provedor. |
| 16 | `a533d818bc` | Palmital no Equiplano | MANTER NA TABELA | Bloco Equiplano com `CodigoCidade:38` reaplicado. |
| 17 | `d0b9ec9902` | Consultas e eventos SilTecnologia | MANTER | O fluxo SOAP assinado, a consulta e os eventos municipais não existem na origem. Há validação histórica de emissão e cancelamento bem-sucedidos. |

## Configurações municipais reaplicadas

`acbrcmd/cidades_atualizadas.txt` é a fonte de verdade. Os sete blocos abaixo foram comparados campo a campo e reaplicados na candidata em `ACBrNFSeXServicos.ini`:

- Costa Rica/MS (`5003256`) — Fiorilli 2.00.
- São João da Canabrava/PI (`2209856`) — Agili.
- São João Batista/SC (`4216305`) — Betha com endereço do serviço.
- São Geraldo do Araguaia/PA (`1507458`) — Fiorilli 1.01, serviço nacional, consultas próprias e porta 5661.
- Brasília/DF (`5300108`) — ISSNet no endereço nacional atualizado.
- João Pessoa/PB (`2507507`) — DSF 2.03 municipal, produção, homologação e `Params=*`.
- Palmital/PR (`4117800`) — Equiplano com `CodigoCidade:38`.

O recurso `ACBrNFSeXServicos.res` foi regenerado a partir do INI com `windres` e conferido com os sete marcadores, inclusive `CodigoCidade:38`.

## Ajustes do `acbrcmd` revisados separadamente

| Ajuste | Decisão | Motivo objetivo |
|---|---|---|
| Patch de regime especial nacional | DESCARTAR | O `acbrcmd` já seleciona o provedor nacional e o upstream atual converte `retNenhum` em `0`; o patch só cobre um estado inválido que não ocorre no fluxo tipado. |
| Patch Tinus | DESCARTAR | A origem atual já contém a desativação da validação de schema. |
| Regra local de locação de Goiânia (`5208707` e item `990101`) | DESCARTAR | Não há commit, caso fiscal ou fixture que acione essa condição; os exemplos de Goiânia usam outros itens de serviço. Não será enviada como ajuste especulativo. |
| Código de Brasília | MANTER | Já está versionado no `acbrcmd`: lote síncrono, assinatura do RPS/lote e cancelamento nacional. |
| Referência do ACBr no Docker | VALIDAR | Será fixada no commit final da candidata antes da compilação da imagem. |

## Etapas finais

1. Reaplicar os quatro ajustes de código classificados como `MANTER`: São Paulo, DANFCom FPDF, SigISSWeb e SilTecnologia.
2. Conferir o diff final contra `upstream/master` e compilar a imagem do `acbrcmd` com a referência exata do fork.
3. Promover a candidata para `master`, preservar a tag de retorno e publicar os dois repositórios.
4. Verificar a publicação automática com o commit implantado, a saúde pública e o processo do serviço. A verificação não emitirá documento fiscal real sem um cenário de teste específico.
