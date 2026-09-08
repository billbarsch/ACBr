# Correção da impressão do ISSQN no DANFSe padrão nacional

Olá, pessoal.

Encontramos uma situação em que o XML autorizado informava `tribISSQN=1`, ou seja, operação tributável, mas o DANFSe em FPDF imprimia a mensagem **"Operação não sujeita ao ISSQN"**.

Isso acontecia quando o XML trazia `ValorIss` igual a zero. O código usava o valor calculado do ISSQN para decidir se a operação era tributável. No padrão nacional, especialmente em notas de optantes pelo Simples Nacional, `ValorIss=0` não significa que `tribISSQN` seja igual a não incidência.

## Arquivo e linha

Arquivo:

`Fontes/ACBrDFe/ACBrNFSeX/DANFSE/FPDF/ACBr.DANFSeX.FPDFPadraoNacional.pas`

Método `TACBrDANFSeFPDFPadraoNacional.PossuiISSQN`, linha 719. A decisão estava na linha 722.

### Antes

```pascal
function TACBrDANFSeFPDFPadraoNacional.PossuiISSQN: Boolean;
begin
  Result := (FNFSe <> nil) and (FNFSe.Servico <> nil) and
            (FNFSe.Servico.Valores.ValorIss > 0);
end;
```

### Depois

```pascal
function TACBrDANFSeFPDFPadraoNacional.PossuiISSQN: Boolean;
begin
  Result := (FNFSe <> nil) and (FNFSe.Servico <> nil) and
            (FNFSe.Servico.Valores.tribMun.tribISSQN = tiOperacaoTributavel);
end;
```

A impressão agora usa o indicador fiscal do XML (`tribISSQN`) para decidir entre a seção detalhada e a mensagem de não incidência. O valor monetário do ISSQN continua sendo impresso separadamente.

## Validação local

Compilei o `acbrcmd` com Lazarus/FPC e gerei o DANFSe a partir de um XML nacional de teste com `tribISSQN=1` e `vISSQN=0`. O PDF passou a imprimir:

`1 - Tributação no município`

Também gerei um segundo PDF com `tribISSQN=4`; nesse caso a mensagem continuou sendo:

`TRIBUTAÇÃO MUNICIPAL (ISSQN) - OPERAÇÃO NÃO SUJEITA AO ISSQN`

Assim, a alteração corrige o caso do Simples Nacional sem mudar o comportamento dos casos de não incidência.
