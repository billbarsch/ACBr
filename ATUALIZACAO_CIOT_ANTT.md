# Atualizacao seletiva CIOT ANTT

Data: 06/11/2026.

Base preservada do fork: `a2f42f38e9bcef6b37d21be7a3b90c36f5f92672`.
Origem: SVN oficial do Projeto ACBr, revisao `49010`, diretorio
`trunk2/Fontes/ACBrDFe/ACBrCIOT` e pacote Lazarus correspondente.

Foram importados somente o provedor ANTT e suas dependencias no modulo CIOT:
conversoes, modelo, leitores/escritores INI, transporte REST, leitura dos
retornos JSON, tabela de servicos e registro no pacote Lazarus.
O recurso `ACBrCIOTServicos.res` foi recompilado com `windres` a partir do INI.
Os provedores eFrete, Pamcard, Repom e WexFrete nao foram substituidos.

Nao houve atualizacao geral, mesclagem ou alteracao nos modulos NFe, NFSe,
CTe, MDFe, NFCom, boleto ou geradores de PDF. Os ajustes proprios do fork
nesses modulos permanecem preservados.

Validacao inicial: pacote CIOT compilado no Linux, projeto acbrcmd completo
compilado e regressao local HTTPS eFrete aprovada em 67 verificacoes,
incluindo login, token por chamada, rejeicoes e certificado A1 temporario.
O adaptador e os testes da modalidade ANTT pertencem ao repositorio acbrcmd.

O componente ANTT monta a declaracao a partir de `IdOperacaoCliente`, que
corresponde ao identificador oficial de 12 digitos. `GerarCIOT` monta a
mensagem e nao implementa o gerador oficial desse identificador.

Referencia da importacao:
https://svn.code.sf.net/p/acbr/code/!svn/bc/49010/trunk2/Fontes/ACBrDFe/ACBrCIOT/
