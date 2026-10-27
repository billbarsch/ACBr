# Atualizacao seletiva da NT 009

Origem oficial: https://svn.code.sf.net/p/acbr/code/trunk2

Revisoes importadas em 27/10/2026:

- 48803: somente as chaves ProVersaoNT e HomVersaoNT, preservando as URLs e configuracoes municipais do fork.
- 48804: pastas de esquemas Producao e Homologacao das versoes 1.00 e 1.01 do Padrao Nacional.
- 48805: geracao, leitura e selecao de esquemas da NT 009. Alteracoes nao relacionadas no provedor ModernizacaoPublica e no historico nao foram importadas.
- 48877: tratamento da finalidade ausente na leitura do XML.

O Padrao Nacional permanece com ProVersaoNT=0 e usa HomVersaoNT=009.1.01.
Os provedores municipais preservam a revisao anterior. Nao antecipar a mudanca
de producao: os ambientes possuem cronogramas e esquemas independentes.

Compatibilidade preservada no fork: provedores municipais que herdam o provedor
nacional continuam usando a pasta anterior de esquemas, e a leitura de XML antigo
nao sobrescreve a finalidade ja informada dentro de IBS/CBS.

Regressao integrada no acbrcmd: teste_leiaute_nacional.lpi, com geracao sem
transmissao, leitura e validacao dos documentos nos esquemas de cada ambiente.
