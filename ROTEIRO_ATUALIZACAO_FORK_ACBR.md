# Roteiro de atualização do fork ACBr

Data de início: 08/09/2026

## Objetivo

Atualizar o fork `billbarsch/ACBr` com o `ProjetoACBr/ACBr`, preservando somente os ajustes próprios que continuarem necessários e comprovados.

Nenhum envio ao Git remoto deve ser feito durante a auditoria. O `master` atual deve permanecer preservado até a conclusão dos testes e autorização explícita.

## Estado inicial

- Fork atual: `d0b9ec9902`.
- Upstream atual: `b08d6e285a`.
- Base comum identificada: `264f2abf52`.
- Commits próprios do fork desde a base comum: 17.
- Arquivos alterados por esses commits: 19.
- Situação do repositório `ACBr`: limpo no início da auditoria.
- Situação do repositório `acbrcmd`: possui alteração em `funcoesacbrnfse.pas` e diversos artefatos locais de testes; será auditado separadamente.

## Legenda das decisões

- `PENDENTE`: ainda não foi analisado.
- `EM ANÁLISE`: ajuste aberto para decisão atual.
- `MANTER`: será reaplicado na base atualizada.
- `DESCARTAR`: não será reaplicado.
- `SUBSTITUÍDO PELO UPSTREAM`: o projeto original já contém solução equivalente ou mais nova.
- `REAPLICAR PARCIALMENTE`: somente parte do commit será reaplicada.
- `VALIDADO`: reaplicado e confirmado por compilação/teste.

## Roadmap

1. Preservar o estado atual com tag e backup local.
2. Catalogar os 17 commits próprios do fork.
3. Comparar cada ajuste com o upstream atual.
4. Registrar uma decisão individual para cada ajuste.
5. Criar uma base candidata a partir do upstream, sem alterar o `master` atual.
6. Reaplicar somente os ajustes classificados como `MANTER` ou `REAPLICAR PARCIALMENTE`.
7. Atualizar a referência do ACBr nos `Dockerfile` do `acbrcmd`.
8. Revisar os patches locais do `acbrcmd`, especialmente a diferença entre desenvolvimento e produção.
9. Compilar o ACBr e o `acbrcmd`.
10. Testar os provedores afetados e comparar XML/PDF quando aplicável.
11. Atualizar o `master` somente após a aprovação e publicar apenas quando solicitado.

## Inventário dos ajustes próprios do fork

Todos os itens abaixo estão aplicados na base atual do fork. A coluna decisão indica o que será feito na futura base atualizada.

| Ordem | Commit | Data | Ajuste | Estado atual | Decisão na nova base |
|---:|---|---|---|---|---|
| 1 | `9040449da4` | 21/07/2026 | Atualiza cidades e serviços NFSe | Aplicado na base atual | Manter parcialmente; tabela conferida |
| 2 | `f4c6123ee1` | 22/07/2026 | Corrige configuração de NFSe de São Geraldo do Araguaia | Aplicado na base atual | Manter configuração final conferida |
| 3 | `60b98e1899` | 28/07/2026 | Corrige XML legado do ISS São Paulo | Aplicado na base atual | Pendente |
| 4 | `804d73c783` | 30/07/2026 | Atualiza o fork com o MirrorProjetoACBr | Aplicado na base atual | Pendente |
| 5 | `0753354301` | 05/08/2026 | Mescla alterações do MirrorProjetoACBr | Aplicado na base atual | Pendente |
| 6 | `7849cb07d4` | 07/08/2026 | Atualiza endpoint de NFSe de Brasília | Aplicado na base atual | Manter bloco do INI; código pendente |
| 7 | `5db1724872` | 07/08/2026 | Corrige endpoint oficial de NFSe de Brasília | Aplicado na base atual | Manter bloco do INI; código pendente |
| 8 | `d0b3ac83f1` | 16/08/2026 | Ajusta layouts municipais de NFSe | Aplicado na base atual | Pendente |
| 9 | `ed2a826e57` | 17/08/2026 | Correção adicional sem descrição detalhada no título | Aplicado na base atual | Pendente |
| 10 | `6811236492` | 19/08/2026 | Adiciona DANFCom FPDF sem ambiente gráfico | Aplicado na base atual | Pendente |
| 11 | `2f31fc8028` | 21/08/2026 | Corrige grupos de obra e imóvel na NFSe | Aplicado na base atual | Pendente |
| 12 | `e5b4bedbb0` | 01/09/2026 | Atualiza endpoint nacional de NFSe de João Pessoa | Aplicado na base atual | Manter bloco municipal do INI; validar código |
| 13 | `a6499d6602` | 02/09/2026 | Corrige envio REST do provedor DSF | Aplicado na base atual | Manter; validar código |
| 14 | `59bfe9b2f0` | 03/09/2026 | Atualiza serviços de NFSe de João Pessoa | Aplicado na base atual | Manter bloco municipal do INI; validar código |
| 15 | `1c0b6881a9` | 04/09/2026 | Corrige retorno do SigISSWeb | Aplicado na base atual | Pendente |
| 16 | `a533d818bc` | 07/09/2026 | Configura Palmital no provedor Equiplano | Aplicado na base atual | Manter bloco do INI; validar código |
| 17 | `d0b9ec9902` | 08/09/2026 | Corrige consultas e eventos da NFS-e SilTecnologia | Aplicado na base atual | Pendente |

## Ajustes fora do histórico do fork

Estes itens não são commits do repositório `ACBr`; pertencem ao `acbrcmd` e precisam de decisão própria:

| Item | Local | Estado atual | Decisão |
|---|---|---|---|
| Regime especial ausente deve virar `0` no padrão nacional | `acbrcmd/correcoes/acbr-regime-especial.patch` | Aplicado nos ambientes de desenvolvimento e produção | Pendente |
| Desativação da validação de esquema do provedor Tinus | `acbrcmd/correcoes/acbr-tinus-validacao.patch` | Aplicado no `Dockerfile.dev`; não aplicado no `Dockerfile` de produção | Pendente |
| Referência do ACBr usada na imagem | `acbrcmd/Dockerfile` e `acbrcmd/Dockerfile.dev` | Fixa em `a533d818bc` | Pendente |

## Conferência de cidades_atualizadas.txt

Conferência realizada em 08/09/2026 usando `acbrcmd/cidades_atualizadas.txt` como fonte de verdade.

### Resultado da tabela municipal

Os sete blocos abaixo já estavam presentes no `ACBrNFSeXServicos.ini` atual e foram comparados campo a campo:

- Costa Rica/MS (`5003256`) — Fiorilli 2.00.
- São João da Canabrava/PI (`2209856`) — Agili.
- São João Batista/SC (`4216305`) — Betha com endereço do serviço.
- São Geraldo do Araguaia/PA (`1507458`) — Fiorilli 1.01, serviço nacional e serviços próprios de consulta.
- Brasília/DF (`5300108`) — ISSNet com o endereço nacional atualizado.
- João Pessoa/PB (`2507507`) — DSF 2.03 municipal, endpoints de produção/homologação e `Params=*`.
- Palmital/PR (`4117800`) — Equiplano com `CodigoCidade:38`.

Na base atual do fork, todos os campos da fonte já estavam aplicados. Na candidata criada sobre o `upstream`, os sete blocos foram reaplicados sobre a versão mais nova, preservando a codificação legada do arquivo. O recurso binário candidato `ACBrNFSeXServicos.res` foi regenerado a partir do `.ini` com `windres` e conferido com os sete marcadores municipais, incluindo `CodigoCidade:38`.

**Estado no fork atual:** `APLICADO E CONFERIDO`.

**Estado na candidata:** `REAPLICADO E CONFERIDO`.

## Outros ajustes que ainda precisam ser conferidos

O arquivo de cidades também registra comportamentos que não são resolvidos apenas no `.ini`:

1. **Brasília no `acbrcmd`:** o código já contém o modo síncrono, assinatura de RPS e lote, `LoteDps`, reconhecimento genérico de `EnviarLoteDpsSincronoResposta` e cancelamento nacional por evento com extração do `Id`. Falta validar o fluxo completo com XML autorizado e cancelado.
2. **João Pessoa/DSF:** a tabela mantém o fluxo municipal DSF 2.03 e `Params=*`; falta confirmar por teste que o código continua usando esse fluxo e localizar ou repetir a validação da emissão autorizada registrada no arquivo.
3. **Palmital/Equiplano:** a tabela está correta e o ACBr faz a leitura genérica de `Params`; falta confirmar que `CodigoCidade:38` chega como `idEntidade` no XML e testar emissão/consulta.
4. **Recurso compilado:** concluído para a tabela atual; deve ser regenerado novamente sempre que qualquer cidade for alterada.
5. **Referência do Docker:** atualizar depois da escolha dos commits, pois o `acbrcmd` ainda baixa o ACBr pelo commit fixado `a533d818bc`.
6. **Ajustes do fork que não estão no arquivo de cidades:** ISS São Paulo, layouts municipais gerais, DANFCom FPDF headless, grupos de obra e imóvel, SigISSWeb e SilTecnologia.

## Item concluído

### 1. Atualização de cidades e serviços NFSe — `9040449da4`

O commit altera a tabela `ACBrNFSeXServicos.ini` e seu recurso compilado `ACBrNFSeXServicos.res`:

- São Geraldo do Araguaia/PA: muda o serviço Fiorilli da porta `8080` para `5661` e adiciona `Assinar:NaoAssinar`.
- São João da Canabrava/PI: define o provedor como `Agili`.
- São João Batista/SC: define o provedor `Betha` e o endereço do serviço.
- Costa Rica/MS: troca `Pronim` pelo provedor `Fiorilli`, versão `2.00`, com novo endereço.

Na referência atual do upstream, esses quatro pontos ainda aparecem com os valores antigos. O ajuste não parece ter sido incorporado pelo projeto original.

Dependência identificada: o commit seguinte, `f4c6123ee1`, altera novamente São Geraldo do Araguaia, trocando a configuração provisória por Fiorilli 1.01, serviço nacional e `ServicosAPIPropria`. Por isso, a parte de São Geraldo deste item não deve ser reaplicada isoladamente.

**Decisão:** `MANTER PARCIALMENTE — os três municípios independentes foram conferidos; São Geraldo do Araguaia fica representado pela configuração final do item 2`.

## Próximo item para decisão

O próximo ajuste a ser analisado individualmente será o commit `60b98e1899`, referente à correção do XML legado do ISS São Paulo. Nenhum outro commit próprio foi reaplicado na candidata até que esse item seja comparado com o `upstream` e decidido.
