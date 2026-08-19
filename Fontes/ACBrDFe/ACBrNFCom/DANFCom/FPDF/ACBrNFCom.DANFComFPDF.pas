{******************************************************************************}
{ Projeto: Componentes ACBr                                                    }
{                                                                              }
{ DANFCom em FPDF, sem dependência de LCL, Forms ou qualquer backend gráfico. }
{ Esta unidade segue o mesmo desenho por bandas usado pelos geradores FPDF de  }
{ NF-e e NFSe, mantendo o contrato de TACBrNFComDANFComClass.                  }
{******************************************************************************}

{$I ACBr.inc}

unit ACBrNFCom.DANFComFPDF;

interface

uses
  Classes,
  SysUtils,
  DateUtils,
  Math,
  ACBrBase,
  ACBrDFeReport,
  ACBrDFeUtil,
  ACBrUtil.FilesIO,
  ACBrUtil.Strings,
  ACBrUtil.Compatibilidade,
  ACBrDelphiZXingQRCode,
  ACBr_fpdf,
  ACBr_fpdf_ext,
  ACBr_fpdf_report,
  ACBrNFComClass,
  ACBrNFComConversao,
  ACBrNFComEnvEvento,
  ACBrNFComEventoClass,
  ACBrNFComDANFComClass;

type
  { Relatório FPDF do DANFCom. O desenho fica isolado do componente para que a }
  { classe pública continue responsável somente pelo ciclo de vida ACBr.       }
  TDANFComFPDFRelatorio = class(TFPDFReport)
  private
    FNotaFiscal: TNFCom;
    FCancelada: Boolean;
    FInicializado: Boolean;
    FFormato: TFormatSettings;
    FLogomarca: TBytes;

    procedure DesenharDocumentoFiel(Argumentos: TFPDFBandDrawArgs);
    procedure DesenharDocumento(Argumentos: TFPDFBandDrawArgs);
    procedure DesenharTexto(const Pdf: IFPDF; const X, Y, Largura, Altura: Double;
      const Texto: string; Tamanho: Double; const Estilo: string;
      const AlinhamentoVertical, AlinhamentoHorizontal: Char;
      Borda: Boolean = False);
    procedure DesenharRotulo(const Pdf: IFPDF; const X, Y, Largura: Double;
      const Rotulo, Valor: string; TamanhoRotulo, TamanhoValor: Double;
      Alinhamento: Char = 'L');
    procedure DesenharLinhaVertical(const Pdf: IFPDF; const X, Y, Altura: Double);
    procedure DesenharLinhaHorizontal(const Pdf: IFPDF; const X, Y, Largura: Double);
    procedure DesenharCaixa(const Pdf: IFPDF; const X, Y, Largura, Altura: Double;
      Preenchida: Boolean = False);
    function FormatarData(const Data: TDateTime): string;
    function FormatarDataHora(const Data: TDateTime): string;
    function FormatarValor(const Valor: Double): string;
    function FormatarQuantidade(const Valor: Double): string;
    function FormatarNumeroFatura(const Numero: Integer): string;
    function FormatarDocumento(const Documento: string): string;
    function ObterEndereco(const Endereco: TEndereco): string;
    function ObterEnderecoResumido(const Endereco: TEndereco): string;
    procedure DesenharQRCode(const Pdf: IFPDF; const X, Y, Tamanho: Double;
      const Dados: string);
    procedure CarregarLogomarca;
  protected
    procedure OnStartReport(Argumentos: TFPDFReportEventArgs); override;
  public
    constructor Create(ANotaFiscal: TNFCom; ACancelada: Boolean;
      const ALogomarca: string); reintroduce;
    procedure SalvarPDF(const NomeArquivo: string); overload;
    procedure SalvarPDF(Fluxo: TStream); overload;
  end;

  { Relatório do processo de evento NFCom. O layout é independente do
    DANFCom principal, mas usa o mesmo motor FPDF e não depende de LCL. }
  TDANFComEventoFPDFRelatorio = class(TFPDFReport)
  private
    FEvento: TInfEventoCollectionItem;
    FNotaFiscal: TNFCom;
    FInicializado: Boolean;

    procedure DesenharDocumento(Argumentos: TFPDFBandDrawArgs);
    procedure DesenharTexto(const Pdf: IFPDF; const X, Y, Largura, Altura: Double;
      const Texto: string; Tamanho: Double; const Estilo: string;
      const AlinhamentoVertical, AlinhamentoHorizontal: Char;
      Borda: Boolean = False);
    procedure DesenharLinha(const Pdf: IFPDF; const X, Y, Largura,
      Altura: Double; Preenchida: Boolean = False);
    function FormatarDataHora(const Data: TDateTime): string;
  protected
    procedure OnStartReport(Argumentos: TFPDFReportEventArgs); override;
  public
    constructor Create(AEvento: TInfEventoCollectionItem; ANFCom: TNFCom);
      reintroduce;
    procedure SalvarPDF(const NomeArquivo: string); overload;
    procedure SalvarPDF(Fluxo: TStream); overload;
  end;

type
  {$IFDEF RTL230_UP}
  [ComponentPlatformsAttribute(piacbrAllPlatforms)]
  {$ENDIF RTL230_UP}
  TACBrNFComDANFComFPDF = class(TACBrNFComDANFComClass)
  private
    procedure GerarPDF(ANFCom: TNFCom; Fluxo: TStream); overload;
    procedure GerarPDF(ANFCom: TNFCom; const NomeArquivo: string); overload;
    procedure GerarPDFEvento(AEvento: TInfEventoCollectionItem;
      ANFCom: TNFCom; Fluxo: TStream); overload;
    procedure GerarPDFEvento(AEvento: TInfEventoCollectionItem;
      ANFCom: TNFCom; const NomeArquivo: string); overload;
    function ObterNomeArquivo(ANFCom: TNFCom): string;
    function ObterNomeArquivoEvento(AEvento: TInfEventoCollectionItem): string;
  public
    procedure ImprimirDANFCom(ANFCom: TNFCom = nil); override;
    procedure ImprimirDANFComPDF(ANFCom: TNFCom = nil); override;
    procedure ImprimirDANFComPDF(AStream: TStream; ANFCom: TNFCom = nil); override;
    procedure ImprimirDANFComResumidoPDF(ANFCom: TNFCom = nil); override;
    procedure ImprimirDANFComCancelado(ANFCom: TNFCom = nil); override;
    procedure ImprimirEVENTO(ANFCom: TNFCom = nil); override;
    procedure ImprimirEVENTOPDF(ANFCom: TNFCom = nil); override;
    procedure ImprimirEVENTOPDF(AStream: TStream; ANFCom: TNFCom = nil); override;
  end;

implementation

uses
  ACBrNFCom;

const
  CorCinzaRotulo = 235;
  MargemPadrao = 7.0;

function TextoSeguro(const Valor: string): string;
begin
  Result := Trim(Valor);
end;

{ TDANFComFPDFRelatorio }

constructor TDANFComFPDFRelatorio.Create(ANotaFiscal: TNFCom; ACancelada: Boolean;
  const ALogomarca: string);
begin
  inherited Create;
  FNotaFiscal := ANotaFiscal;
  FCancelada := ACancelada;
  FInicializado := False;
  FFormato := DefaultFormatSettings;
  FFormato.DecimalSeparator := ',';
  FFormato.ThousandSeparator := '.';

  SetFont('Arial');
  { NFe e NFSe convertem a string nativa antes de escrever no FPDF. O
    renderer NFCom segue o mesmo contrato para evitar UTF-8 duplicado. }
  SetUTF8(False);
  SetMargins(MargemPadrao, MargemPadrao, MargemPadrao, MargemPadrao);
  EngineOptions.DoublePass := True;
  if ALogomarca <> '' then
    FileToBytes(ALogomarca, FLogomarca);
end;

procedure TDANFComFPDFRelatorio.OnStartReport(Argumentos: TFPDFReportEventArgs);
begin
  if FInicializado then
    Exit;

  if not Assigned(FNotaFiscal) then
    raise Exception.Create('NFCom não foi informada para o relatório FPDF.');

  CarregarLogomarca;
  AddPage(poPortrait, puMM, pfA4);
  AddBand(btData, 282, DesenharDocumento);
  FInicializado := True;
end;

procedure TDANFComFPDFRelatorio.CarregarLogomarca;
begin
  { A imagem já é carregada no construtor. O método permanece separado para
    manter o ciclo de inicialização compatível com os demais relatórios FPDF. }
end;

function TDANFComFPDFRelatorio.FormatarData(const Data: TDateTime): string;
begin
  if Data <= 0 then
    Result := ''
  else
    Result := FormatDateTime('dd/mm/yyyy', Data, FFormato);
end;

function TDANFComFPDFRelatorio.FormatarDataHora(const Data: TDateTime): string;
begin
  if Data <= 0 then
    Result := ''
  else
    Result := FormatDateTime('dd/mm/yyyy hh:nn:ss', Data, FFormato);
end;

function TDANFComFPDFRelatorio.FormatarValor(const Valor: Double): string;
begin
  Result := FormatFloat('#,##0.00', Valor, FFormato);
end;

function TDANFComFPDFRelatorio.FormatarQuantidade(const Valor: Double): string;
begin
  Result := FormatFloat('#,##0.####', Valor, FFormato);
end;

function TDANFComFPDFRelatorio.FormatarNumeroFatura(const Numero: Integer): string;
var
  Texto: string;
begin
  Texto := IntToStr(Numero);
  while Length(Texto) < 9 do
    Texto := '0' + Texto;
  Result := Copy(Texto, 1, 3) + '.' + Copy(Texto, 4, 3) + '.' +
    Copy(Texto, 7, 3);
end;

function TDANFComFPDFRelatorio.FormatarDocumento(const Documento: string): string;
var
  Texto: string;
begin
  Texto := OnlyNumber(Documento);
  if Length(Texto) = 14 then
    Result := Copy(Texto, 1, 2) + '.' + Copy(Texto, 3, 3) + '.' +
      Copy(Texto, 6, 3) + '/' + Copy(Texto, 9, 4) + '-' + Copy(Texto, 13, 2)
  else if Length(Texto) = 11 then
    Result := Copy(Texto, 1, 3) + '.' + Copy(Texto, 4, 3) + '.' +
      Copy(Texto, 7, 3) + '-' + Copy(Texto, 10, 2)
  else
    Result := Documento;
end;

function TDANFComFPDFRelatorio.ObterEndereco(const Endereco: TEndereco): string;
begin
  Result := TextoSeguro(Endereco.xLgr);
  if TextoSeguro(Endereco.nro) <> '' then
    Result := Result + ', ' + TextoSeguro(Endereco.nro);
  if TextoSeguro(Endereco.xCpl) <> '' then
    Result := Result + ' ' + TextoSeguro(Endereco.xCpl);
  if TextoSeguro(Endereco.xBairro) <> '' then
    Result := Result + ' - ' + TextoSeguro(Endereco.xBairro);
  if TextoSeguro(Endereco.xMun) <> '' then
    Result := Result + ' - ' + TextoSeguro(Endereco.xMun);
  if TextoSeguro(Endereco.UF) <> '' then
    Result := Result + '/' + TextoSeguro(Endereco.UF);
end;

function TDANFComFPDFRelatorio.ObterEnderecoResumido(
  const Endereco: TEndereco): string;
begin
  Result := TextoSeguro(Endereco.xLgr);
  if TextoSeguro(Endereco.nro) <> '' then
    Result := Result + ', ' + TextoSeguro(Endereco.nro);
  if TextoSeguro(Endereco.xBairro) <> '' then
    Result := Result + ' - ' + TextoSeguro(Endereco.xBairro);
end;

procedure TDANFComFPDFRelatorio.DesenharQRCode(const Pdf: IFPDF; const X, Y,
  Tamanho: Double; const Dados: string);
var
  QRCode: TDelphiZXingQRCode;
  TamanhoModulo: Double;
  Linha, Coluna: Integer;
begin
  if TextoSeguro(Dados) = '' then
    Exit;

  QRCode := TDelphiZXingQRCode.Create;
  try
    QRCode.Encoding := qrUTF8NoBOM;
    QRCode.QuietZone := 1;
    QRCode.Data := WideString(Dados);
    if (QRCode.Rows = 0) or (QRCode.Columns = 0) then
      Exit;

    TamanhoModulo := Tamanho / QRCode.Rows;
    Pdf.SetFillColor(0, 0, 0);
    for Linha := 0 to QRCode.Rows - 1 do
      for Coluna := 0 to QRCode.Columns - 1 do
        if QRCode.IsBlack[Linha, Coluna] then
          Pdf.Rect(X + (Coluna * TamanhoModulo),
            Y + (Linha * TamanhoModulo), TamanhoModulo, TamanhoModulo, 'F');
    Pdf.SetFillColor(255, 255, 255);
  finally
    QRCode.Free;
  end;
end;

procedure TDANFComFPDFRelatorio.DesenharCaixa(const Pdf: IFPDF; const X, Y,
  Largura, Altura: Double; Preenchida: Boolean);
begin
  if Preenchida then
  begin
    Pdf.SetFillColor(CorCinzaRotulo, CorCinzaRotulo, CorCinzaRotulo);
    Pdf.Rect(X, Y, Largura, Altura, 'DF');
    Pdf.SetFillColor(255, 255, 255);
  end
  else
    Pdf.Rect(X, Y, Largura, Altura);
end;

procedure TDANFComFPDFRelatorio.DesenharLinhaVertical(const Pdf: IFPDF;
  const X, Y, Altura: Double);
begin
  Pdf.Line(X, Y, X, Y + Altura);
end;

procedure TDANFComFPDFRelatorio.DesenharLinhaHorizontal(const Pdf: IFPDF;
  const X, Y, Largura: Double);
begin
  Pdf.Line(X, Y, X + Largura, Y);
end;

procedure TDANFComFPDFRelatorio.DesenharTexto(const Pdf: IFPDF; const X, Y,
  Largura, Altura: Double; const Texto: string; Tamanho: Double;
  const Estilo: string; const AlinhamentoVertical,
  AlinhamentoHorizontal: Char;
  Borda: Boolean);
begin
  Pdf.SetFont('Arial', Estilo, Tamanho);
  Pdf.TextBox(X, Y, Largura, Altura, NativeStringToAnsi(Texto), AlinhamentoVertical,
    AlinhamentoHorizontal, Borda, True, False);
end;

procedure TDANFComFPDFRelatorio.DesenharRotulo(const Pdf: IFPDF; const X, Y,
  Largura: Double; const Rotulo, Valor: string; TamanhoRotulo,
  TamanhoValor: Double; Alinhamento: Char);
begin
  DesenharTexto(Pdf, X, Y, Largura, 3.5, UpperCase(Rotulo), TamanhoRotulo,
    '', 'T', Alinhamento);
  DesenharTexto(Pdf, X, Y + 3, Largura, 6, Valor, TamanhoValor,
    '', 'T', Alinhamento);
end;

procedure TDANFComFPDFRelatorio.DesenharDocumentoFiel(
  Argumentos: TFPDFBandDrawArgs);
const
  ColunasItens: array[1..8] of Double =
    (64, 75, 91, 108, 126, 143, 160, 176);
var
  Pdf: IFPDF;
  Nota: TNFCom;
  Item: TDetCollectionItem;
  FluxoImagem: TBytesStream;
  Y, Largura, Altura, Linha: Double;
  Indice, ColunaIndice: Integer;
  Texto, CodigoBarras: string;
  ValorICMS, ValorPISCOFINS: Double;
begin
  Pdf := Argumentos.PDF;
  Nota := FNotaFiscal;
  Largura := Argumentos.Band.Width;
  Pdf.SetLineWidth(0.25);
  Pdf.SetDrawColor(0, 0, 0);
  Pdf.SetTextColor(0, 0, 0);
  Pdf.SetFillColor(255, 255, 255);

  { O DANFCom Fortes usa uma grade fixa em A4 retrato. As bandas abaixo
    reproduzem essa grade em milimetros, sem depender de controles visuais. }
  Y := 0;
  Altura := 25;
  DesenharCaixa(Pdf, 0, Y, Largura, Altura);
  DesenharCaixa(Pdf, 3, Y + 4, 20, 15);
  if Length(FLogomarca) > 0 then
  begin
    FluxoImagem := TBytesStream.Create;
    try
      FluxoImagem.WriteBuffer(FLogomarca[0], Length(FLogomarca));
      FluxoImagem.Position := 0;
      Pdf.Image(3.5, Y + 4.5, 19, 14, FluxoImagem, 'T', 'L', False);
    finally
      FluxoImagem.Free;
    end;
  end;
  DesenharTexto(Pdf, 35, Y + 2, 158, 4,
    'DOCUMENTO AUXILIAR DA NOTA FISCAL FATURA DE SERVIÇOS DE COMUNICAÇÃO ELETRÔNICA',
    8, 'B', 'T', 'C');
  DesenharTexto(Pdf, 35, Y + 7, 158, 4, Nota.Emit.xNome, 9, 'B', 'T', 'L');
  DesenharTexto(Pdf, 35, Y + 11, 158, 4,
    ObterEnderecoResumido(Nota.Emit.EnderEmit), 8, 'B', 'T', 'L');
  DesenharTexto(Pdf, 35, Y + 15, 158, 4,
    'CNPJ: ' + FormatarDocumento(Nota.Emit.CNPJ), 8, 'B', 'T', 'L');
  DesenharTexto(Pdf, 35, Y + 19, 158, 4,
    'INSCRIÇÃO ESTADUAL: ' + Nota.Emit.IE, 8, 'B', 'T', 'L');

  Y := 27;
  DesenharTexto(Pdf, 1, Y, 78, 4, Nota.Dest.xNome, 8, 'B', 'T', 'L');
  DesenharTexto(Pdf, 1, Y + 4, 78, 4,
    ObterEnderecoResumido(Nota.Dest.EnderDest), 8, 'B', 'T', 'L');
  DesenharTexto(Pdf, 1, Y + 8, 78, 4,
    'CNPJ/CPF: ' + FormatarDocumento(Nota.Dest.CNPJCPF), 8, 'B', 'T', 'L');
  DesenharTexto(Pdf, 1, Y + 12, 78, 4, 'INSCRIÇÃO ESTADUAL: ' + Nota.Dest.IE,
    8, 'B', 'T', 'L');
  DesenharTexto(Pdf, 1, Y + 16, 78, 4,
    'CÓDIGO CLIENTE: ' + Nota.assinante.iCodAssinante, 8, 'B', 'T', 'L');
  DesenharTexto(Pdf, 1, Y + 20, 78, 4,
    'N. TELEFONE: ' + Nota.Dest.EnderDest.fone, 8, 'B', 'T', 'L');
  DesenharTexto(Pdf, 1, Y + 24, 78, 4,
    'PERÍODO: ' + FormatarData(Nota.gFat.dPerUsoIni) + ' A ' +
    FormatarData(Nota.gFat.dPerUsoFim), 8, 'B', 'T', 'L');

  if TextoSeguro(Nota.infNFComSupl.qrCodNFCom) <> '' then
    DesenharQRCode(Pdf, 86, Y, 25, Nota.infNFComSupl.qrCodNFCom);

  DesenharTexto(Pdf, 116, Y, 78, 4,
    'NOTA FISCAL FATURA No. ' + FormatarNumeroFatura(Nota.Ide.nNF),
    8, '', 'T', 'L');
  DesenharTexto(Pdf, 116, Y + 4, 78, 4,
    'SÉRIE: ' + FormatFloat('000', Nota.Ide.serie), 8, '', 'T', 'L');
  DesenharTexto(Pdf, 116, Y + 11, 78, 4,
    'DATA DE EMISSÃO: ' + FormatarData(Nota.Ide.dhEmi), 8, '', 'T', 'L');
  DesenharTexto(Pdf, 116, Y + 18, 78, 4,
    'CONSULTE PELA CHAVE DE ACESSO EM:', 8, '', 'T', 'L');
  DesenharTexto(Pdf, 116, Y + 22, 78, 4,
    'http://dfe-portal.svrs.rs.gov.br/NFCom', 6, '', 'T', 'L');
  DesenharTexto(Pdf, 116, Y + 27, 78, 4, 'CHAVE DE ACESSO', 8, '', 'T', 'L');
  DesenharTexto(Pdf, 116, Y + 31, 78, 5,
    FormatarChaveAcesso(Nota.infNFCom.ID), 8, 'B', 'T', 'L');
  DesenharTexto(Pdf, 116, Y + 35, 78, 3,
    'PROTOCOLO DE AUTORIZAÇÃO DE USO', 6, '', 'T', 'L');
  if FCancelada then
    Texto := 'NFCom CANCELADA'
  else if Nota.procNFCom.cStat > 0 then
    Texto := Nota.procNFCom.nProt + ' ' + FormatarDataHora(Nota.procNFCom.dhRecbto)
  else
    Texto := 'NFCom NÃO PROTOCOLADA NA SEFAZ - SEM VALOR FISCAL';
  DesenharTexto(Pdf, 116, Y + 39, 78, 5, Texto, 8, 'B', 'T', 'L');

  Y := 70;
  DesenharCaixa(Pdf, 0, Y, 80, 25);
  DesenharCaixa(Pdf, 83, Y, Largura - 83, 25);
  Linha := Y + (25 / 3);
  DesenharLinhaHorizontal(Pdf, 0, Linha, 80);
  DesenharLinhaHorizontal(Pdf, 0, Linha + (25 / 3), 80);
  DesenharTexto(Pdf, 3, Y + 4, 74, 4,
    'REFERÊNCIA (ANO/MÊS): ' + FormatDateTime('mm/yyyy', Nota.gFat.CompetFat),
    8, '', 'T', 'L');
  DesenharTexto(Pdf, 3, Y + 12, 74, 4,
    'VENCIMENTO:                 ' + FormatarData(Nota.gFat.dVencFat),
    8, '', 'T', 'L');
  DesenharTexto(Pdf, 3, Y + 20, 74, 4,
    'TOTAL A PAGAR:              R$ ' + FormatarValor(Nota.Total.vNF),
    8, 'B', 'T', 'L');

  Y := 96.5;
  Altura := 5;
  DesenharCaixa(Pdf, 0, Y, Largura, Altura, True);
  DesenharTexto(Pdf, 1, Y + 1, 64, 3, 'ITENS DA FATURA', 6, '', 'T', 'C');
  DesenharTexto(Pdf, 64, Y + 1, 11, 3, 'UNID.', 6, '', 'T', 'C');
  DesenharTexto(Pdf, 75, Y + 1, 16, 3, 'QUANT.', 6, '', 'T', 'C');
  DesenharTexto(Pdf, 91, Y + 1, 17, 3, 'PREÇO UNITÁRIO', 6, '', 'T', 'C');
  DesenharTexto(Pdf, 108, Y + 1, 18, 3, 'VALOR TOTAL', 6, '', 'T', 'C');
  DesenharTexto(Pdf, 126, Y + 1, 17, 3, 'PIS COFINS', 6, '', 'T', 'C');
  DesenharTexto(Pdf, 143, Y + 1, 17, 3, 'BASE CÁLC. ICMS', 6, '', 'T', 'C');
  DesenharTexto(Pdf, 160, Y + 1, 16, 3, 'ALÍQUOTA', 6, '', 'T', 'C');
  DesenharTexto(Pdf, 176, Y + 1, 20, 3, 'VALOR I.C.M.S.', 6, '', 'T', 'C');
  for Indice := 1 to 8 do
    DesenharLinhaVertical(Pdf, ColunasItens[Indice], Y, Altura);

  Y := Y + Altura;
  for Indice := 0 to Nota.Det.Count - 1 do
  begin
    Item := Nota.Det[Indice];
    Altura := 5;
    DesenharCaixa(Pdf, 0, Y, Largura, Altura);
    DesenharTexto(Pdf, 1, Y + 1, 63, 3, Item.Prod.xProd, 6, '', 'T', 'L');
    DesenharTexto(Pdf, 64, Y + 1, 11, 3, uMedToDescricao(Item.Prod.uMed), 6, '', 'T', 'C');
    DesenharTexto(Pdf, 75, Y + 1, 16, 3, FormatarQuantidade(Item.Prod.qFaturada), 6, '', 'T', 'R');
    DesenharTexto(Pdf, 91, Y + 1, 17, 3, FormatarValor(Item.Prod.vItem), 6, '', 'T', 'R');
    DesenharTexto(Pdf, 108, Y + 1, 18, 3, FormatarValor(Item.Prod.vProd), 6, '', 'T', 'R');
    ValorPISCOFINS := Item.Imposto.PIS.vPIS + Item.Imposto.COFINS.vCOFINS;
    DesenharTexto(Pdf, 126, Y + 1, 17, 3, FormatarValor(ValorPISCOFINS), 6, '', 'T', 'R');
    DesenharTexto(Pdf, 143, Y + 1, 17, 3, FormatarValor(Item.Imposto.ICMS.vBC), 6, '', 'T', 'R');
    DesenharTexto(Pdf, 160, Y + 1, 16, 3, FormatarValor(Item.Imposto.ICMS.pICMS), 6, '', 'T', 'R');
    ValorICMS := Item.Imposto.ICMS.vICMS + Item.Imposto.ICMS.vFCP;
    DesenharTexto(Pdf, 176, Y + 1, 20, 3, FormatarValor(ValorICMS), 6, '', 'T', 'R');
    for ColunaIndice := 1 to 8 do
      DesenharLinhaVertical(Pdf, ColunasItens[ColunaIndice], Y, Altura);
    Y := Y + Altura;
  end;

  Y := 106.5;
  Altura := 29;
  DesenharCaixa(Pdf, 0, Y, 64, Altura);
  DesenharCaixa(Pdf, 66, Y, 40, Altura);
  DesenharCaixa(Pdf, 107, Y, Largura - 107, Altura);
  for Indice := 1 to 4 do
    DesenharLinhaHorizontal(Pdf, 0, Y + (Altura / 5) * Indice, 64);
  DesenharTexto(Pdf, 2, Y + 3, 60, 4, 'VALOR TOTAL NFF', 8, '', 'T', 'L');
  DesenharTexto(Pdf, 35, Y + 3, 27, 4, FormatarValor(Nota.Total.vNF), 8, 'B', 'T', 'R');
  DesenharTexto(Pdf, 2, Y + 8.8, 60, 4, 'VALOR BASE DE CÁLCULO', 8, '', 'T', 'L');
  DesenharTexto(Pdf, 35, Y + 8.8, 27, 4, FormatarValor(Nota.Total.vBC), 8, 'B', 'T', 'R');
  DesenharTexto(Pdf, 2, Y + 14.6, 60, 4, 'VALOR ICMS', 8, '', 'T', 'L');
  DesenharTexto(Pdf, 35, Y + 14.6, 27, 4, FormatarValor(Nota.Total.vICMS), 8, 'B', 'T', 'R');
  DesenharTexto(Pdf, 2, Y + 20.4, 60, 4, 'VALOR DESCONTO', 8, '', 'T', 'L');
  DesenharTexto(Pdf, 35, Y + 20.4, 27, 4, '0,00', 8, 'B', 'T', 'R');
  DesenharTexto(Pdf, 2, Y + 26.2, 60, 4, 'VALOR OUTROS', 8, '', 'T', 'L');
  DesenharTexto(Pdf, 35, Y + 26.2, 27, 4, '0,00', 8, 'B', 'T', 'R');
  DesenharTexto(Pdf, 66, Y + 1, 40, 4, 'INFORMAÇÕES DOS TRIBUTOS', 7, '', 'T', 'C');
  DesenharLinhaHorizontal(Pdf, 66, Y + 5, 40);
  DesenharLinhaVertical(Pdf, 84, Y + 5, Altura - 5);
  DesenharTexto(Pdf, 67, Y + 6, 16, 4, 'TRIBUTO', 7, '', 'T', 'L');
  DesenharTexto(Pdf, 85, Y + 6, 19, 4, 'VALOR', 7, '', 'T', 'R');
  DesenharTexto(Pdf, 67, Y + 11, 16, 4, 'PIS', 7, '', 'T', 'L');
  DesenharTexto(Pdf, 85, Y + 11, 19, 4, FormatarValor(Nota.Total.vPIS), 8, 'B', 'T', 'R');
  DesenharTexto(Pdf, 67, Y + 16, 16, 4, 'COFINS', 7, '', 'T', 'L');
  DesenharTexto(Pdf, 85, Y + 16, 19, 4, FormatarValor(Nota.Total.vCOFINS), 8, 'B', 'T', 'R');
  DesenharTexto(Pdf, 67, Y + 21, 16, 4, 'FUST', 7, '', 'T', 'L');
  DesenharTexto(Pdf, 85, Y + 21, 19, 4, FormatarValor(Nota.Total.vFUST), 8, 'B', 'T', 'R');
  DesenharTexto(Pdf, 67, Y + 26, 16, 4, 'FUNTTEL', 7, '', 'T', 'L');
  DesenharTexto(Pdf, 85, Y + 26, 19, 4, FormatarValor(Nota.Total.vFUNTTEL), 8, 'B', 'T', 'R');
  DesenharTexto(Pdf, 108, Y + 1, Largura - 109, 4, 'RESERVADO AO FISCO', 8, '', 'T', 'C');
  DesenharLinhaHorizontal(Pdf, 107, Y + 5, Largura - 107);
  DesenharTexto(Pdf, 108, Y + 7, Largura - 110, 15,
    TextoSeguro(Nota.infAdic.infAdFisco), 7, '', 'T', 'L');

  Y := 184.5;
  DesenharTexto(Pdf, 0, Y - 3, Largura, 4, 'DADOS ADICIONAIS', 7, 'B', 'T', 'L');
  DesenharCaixa(Pdf, 0, Y, Largura, 36);
  DesenharTexto(Pdf, 1, Y + 1, Largura - 2, 3,
    'INFORMAÇÕES COMPLEMENTARES', 6, '', 'T', 'L');
  DesenharTexto(Pdf, 2, Y + 5, Largura - 4, 25,
    TextoSeguro(Nota.infAdic.infCpl), 7, '', 'T', 'L');

  Y := 222.5;
  Altura := 30;
  DesenharCaixa(Pdf, 0, Y, Largura, Altura);
  DesenharLinhaVertical(Pdf, 61, Y, 13);
  DesenharLinhaVertical(Pdf, 92, Y, 13);
  DesenharLinhaVertical(Pdf, 123, Y, 13);
  DesenharLinhaVertical(Pdf, 155, Y, 13);
  DesenharLinhaHorizontal(Pdf, 0, Y + 6.5, 155);
  DesenharTexto(Pdf, 1, Y + 2, 59, 3, 'IDENTIFICADOR DE DÉBITO AUTOMÁTICO', 6, '', 'T', 'L');
  DesenharTexto(Pdf, 62, Y + 2, 29, 3, 'MÊS REFERÊNCIA', 6, '', 'T', 'C');
  DesenharTexto(Pdf, 93, Y + 2, 29, 3, 'VENCIMENTO', 6, '', 'T', 'C');
  DesenharTexto(Pdf, 124, Y + 2, 30, 3, 'TOTAL A PAGAR', 6, '', 'T', 'C');
  DesenharTexto(Pdf, 62, Y + 8, 29, 4, FormatDateTime('mm/yyyy', Nota.gFat.CompetFat), 8, 'B', 'T', 'C');
  DesenharTexto(Pdf, 93, Y + 8, 29, 4, FormatarData(Nota.gFat.dVencFat), 8, 'B', 'T', 'C');
  DesenharTexto(Pdf, 124, Y + 8, 30, 4, 'R$ ' + FormatarValor(Nota.Total.vNF), 8, 'B', 'T', 'C');
  DesenharTexto(Pdf, 1, Y + 14, 70, 4,
    'Número da Fatura: ' + FormatarNumeroFatura(Nota.Ide.nNF), 8, 'B', 'T', 'L');
  CodigoBarras := OnlyNumber(Nota.gFat.codBarras);
  DesenharTexto(Pdf, 70, Y + 14, 84, 4, CodigoBarras, 7, '', 'T', 'C');
  if CodigoBarras <> '' then
  begin
    Pdf.SetFillColor(0, 0, 0);
    Pdf.Code128(CodigoBarras, 70, Y + 19, 12, 80);
    Pdf.SetFillColor(255, 255, 255);
  end;
  DesenharTexto(Pdf, 156, Y + 1, 39, 4, 'PAGUE NO PIX', 8, '', 'T', 'C');
  if TextoSeguro(Nota.gFat.gPIX.urlQRCodePIX) <> '' then
    DesenharQRCode(Pdf, 165, Y + 5, 23, Nota.gFat.gPIX.urlQRCodePIX);

  Y := 255;
  DesenharCaixa(Pdf, 0, Y, Largura, 22);
  DesenharTexto(Pdf, Largura - 50, Y + 25, 50, 4,
    'Projeto ACBr - www.projetoacbr.com.br', 6, '', 'T', 'R');
end;

procedure TDANFComFPDFRelatorio.DesenharDocumento(Argumentos: TFPDFBandDrawArgs);
var
  Pdf: IFPDF;
  Nota: TNFCom;
  Item: TDetCollectionItem;
  FluxoImagem: TBytesStream;
  Y, Largura, Altura, Coluna: Double;
  Indice: Integer;
  Texto: string;
  ValorICMS, ValorPISCOFINS: Double;
  CodigoBarras: string;
begin
  DesenharDocumentoFiel(Argumentos);
  Exit;

  Pdf := Argumentos.PDF;
  Nota := FNotaFiscal;
  Largura := Argumentos.Band.Width;
  Pdf.SetLineWidth(0.25);
  Pdf.SetDrawColor(0, 0, 0);
  Pdf.SetTextColor(0, 0, 0);
  Pdf.SetFillColor(255, 255, 255);

  { Cabeçalho: mesma ordem visual do DANFCom Fortes. }
  Y := 0;
  Altura := 31;
  DesenharCaixa(Pdf, 0, Y, Largura, Altura);
  DesenharCaixa(Pdf, 0, Y, 46, Altura);
  DesenharCaixa(Pdf, 46, Y, 100, Altura);
  DesenharCaixa(Pdf, 146, Y, Largura - 146, Altura);
  DesenharTexto(Pdf, 2, Y + 2, 42, 4, 'DOCUMENTO AUXILIAR DA NFCom', 8, 'B', 'T', 'C');
  DesenharTexto(Pdf, 2, Y + 7, 42, 4, 'NFCom - NOTA FISCAL FATURA', 7, 'B', 'T', 'C');
  DesenharTexto(Pdf, 2, Y + 13, 42, 12, Nota.Emit.xNome, 8, 'B', 'T', 'C');
  DesenharTexto(Pdf, 48, Y + 2, 96, 5, 'NFCom - MODELO 62', 12, 'B', 'T', 'C');
  DesenharTexto(Pdf, 48, Y + 8, 96, 5, 'NOTA FISCAL FATURA DE SERVIÇOS DE COMUNICAÇÃO', 7, 'B', 'T', 'C');
  DesenharTexto(Pdf, 48, Y + 15, 96, 4, Nota.Emit.xNome, 8, 'B', 'T', 'C');
  DesenharTexto(Pdf, 48, Y + 20, 96, 4, ObterEndereco(Nota.Emit.EnderEmit), 6, '', 'T', 'C');
  if Length(FLogomarca) > 0 then
  begin
    FluxoImagem := TBytesStream.Create;
    try
      FluxoImagem.WriteBuffer(FLogomarca[0], Length(FLogomarca));
      FluxoImagem.Position := 0;
      Pdf.Image(2, Y + 2, 20, 20, FluxoImagem, 'T', 'L', False);
    finally
      FluxoImagem.Free;
    end;
  end;
  DesenharRotulo(Pdf, 148, Y + 1, 46, 'Número', IntToStr(Nota.Ide.nNF), 6, 10, 'C');
  DesenharRotulo(Pdf, 148, Y + 10, 46, 'Série', FormatFloat('000', Nota.Ide.Serie), 6, 9, 'C');
  DesenharRotulo(Pdf, 148, Y + 19, 46, 'Emissão', FormatarDataHora(Nota.Ide.dhEmi), 6, 7, 'C');

  Y := Y + Altura;
  Altura := 29;
  DesenharCaixa(Pdf, 0, Y, Largura, Altura);
  Coluna := 98;
  DesenharLinhaVertical(Pdf, Coluna, Y, Altura);
  DesenharRotulo(Pdf, 2, Y + 1, 92, 'Emitente / Prestador', Nota.Emit.xNome, 6, 8);
  DesenharTexto(Pdf, 2, Y + 10, 92, 5, 'CNPJ: ' + Nota.Emit.CNPJ + '  IE: ' + Nota.Emit.IE, 7, '', 'T', 'L');
  DesenharTexto(Pdf, 2, Y + 16, 92, 9, ObterEndereco(Nota.Emit.EnderEmit), 7, '', 'T', 'L');
  DesenharRotulo(Pdf, Coluna + 2, Y + 1, 96, 'Destinatário / Assinante', Nota.Dest.xNome, 6, 8);
  Texto := Nota.Dest.CNPJCPF;
  if TextoSeguro(Nota.Dest.idOutros) <> '' then
    Texto := 'ID: ' + Nota.Dest.idOutros
  else if Texto <> '' then
    Texto := 'CNPJ/CPF: ' + Texto;
  DesenharTexto(Pdf, Coluna + 2, Y + 10, 96, 5, Texto, 7, '', 'T', 'L');
  DesenharTexto(Pdf, Coluna + 2, Y + 16, 96, 5, ObterEndereco(Nota.Dest.EnderDest), 7, '', 'T', 'L');
  DesenharTexto(Pdf, Coluna + 2, Y + 22, 96, 5, 'Telefone: ' + Nota.Dest.EnderDest.fone, 7, '', 'T', 'L');

  Y := Y + Altura;
  Altura := 22;
  DesenharCaixa(Pdf, 0, Y, Largura, Altura, True);
  DesenharRotulo(Pdf, 2, Y + 1, 62, 'Código do assinante', Nota.assinante.iCodAssinante, 6, 8);
  DesenharRotulo(Pdf, 66, Y + 1, 64, 'Contrato', Nota.assinante.nContrato, 6, 8);
  DesenharRotulo(Pdf, 134, Y + 1, 60, 'Período de uso',
    FormatarData(Nota.gFat.dPerUsoIni) + ' a ' + FormatarData(Nota.gFat.dPerUsoFim), 6, 7);
  DesenharTexto(Pdf, 2, Y + 11, 192, 8,
    'Tipo de assinante: ' + tpAssinanteToStr(Nota.assinante.tpAssinante) +
    '    Serviço: ' + tpServUtilToStr(Nota.assinante.tpServUtil), 7, '', 'T', 'L');

  Y := Y + Altura;
  Altura := 8;
  DesenharCaixa(Pdf, 0, Y, Largura, Altura, True);
  DesenharTexto(Pdf, 1, Y + 1, Largura - 2, 5, 'PRODUTOS / SERVIÇOS FATURADOS', 7, 'B', 'T', 'C');
  Y := Y + Altura;

  { Cabeçalho da tabela de itens. }
  Altura := 8;
  DesenharCaixa(Pdf, 0, Y, Largura, Altura, True);
  DesenharTexto(Pdf, 1, Y + 1, 50, 6, 'DESCRIÇÃO', 6, 'B', 'T', 'L');
  DesenharTexto(Pdf, 51, Y + 1, 9, 6, 'UN.', 6, 'B', 'T', 'C');
  DesenharTexto(Pdf, 60, Y + 1, 14, 6, 'QUANT.', 6, 'B', 'T', 'C');
  DesenharTexto(Pdf, 74, Y + 1, 16, 6, 'UNITÁRIO', 6, 'B', 'T', 'C');
  DesenharTexto(Pdf, 90, Y + 1, 22, 6, 'TOTAL', 6, 'B', 'T', 'C');
  DesenharTexto(Pdf, 112, Y + 1, 22, 6, 'BASE ICMS', 6, 'B', 'T', 'C');
  DesenharTexto(Pdf, 134, Y + 1, 18, 6, 'ALIQ.', 6, 'B', 'T', 'C');
  DesenharTexto(Pdf, 152, Y + 1, 22, 6, 'ICMS', 6, 'B', 'T', 'C');
  DesenharTexto(Pdf, 174, Y + 1, 22, 6, 'PIS/COFINS', 6, 'B', 'T', 'C');
  DesenharLinhaVertical(Pdf, 51, Y, Altura);
  DesenharLinhaVertical(Pdf, 60, Y, Altura);
  DesenharLinhaVertical(Pdf, 74, Y, Altura);
  DesenharLinhaVertical(Pdf, 90, Y, Altura);
  DesenharLinhaVertical(Pdf, 112, Y, Altura);
  DesenharLinhaVertical(Pdf, 134, Y, Altura);
  DesenharLinhaVertical(Pdf, 152, Y, Altura);
  DesenharLinhaVertical(Pdf, 174, Y, Altura);
  Y := Y + Altura;

  for Indice := 0 to Nota.Det.Count - 1 do
  begin
    Item := Nota.Det[Indice];
    Altura := 15;
    DesenharCaixa(Pdf, 0, Y, Largura, Altura);
    DesenharTexto(Pdf, 1, Y + 1, 49, Altura - 2, Item.Prod.xProd, 7, '', 'T', 'L');
    DesenharTexto(Pdf, 51, Y + 1, 9, 5, uMedToDescricao(Item.Prod.uMed), 6, '', 'T', 'C');
    DesenharTexto(Pdf, 60, Y + 1, 14, 5, FormatarQuantidade(Item.Prod.qFaturada), 6, '', 'T', 'R');
    DesenharTexto(Pdf, 74, Y + 1, 16, 5, FormatarValor(Item.Prod.vItem), 6, '', 'T', 'R');
    DesenharTexto(Pdf, 90, Y + 1, 22, 5, FormatarValor(Item.Prod.vProd), 6, '', 'T', 'R');
    DesenharTexto(Pdf, 112, Y + 1, 22, 5, FormatarValor(Item.Imposto.ICMS.vBC), 6, '', 'T', 'R');
    DesenharTexto(Pdf, 134, Y + 1, 18, 5, FormatarValor(Item.Imposto.ICMS.pICMS), 6, '', 'T', 'R');
    ValorICMS := Item.Imposto.ICMS.vICMS + Item.Imposto.ICMS.vFCP;
    ValorPISCOFINS := Item.Imposto.PIS.vPIS + Item.Imposto.COFINS.vCOFINS;
    DesenharTexto(Pdf, 152, Y + 1, 22, 5, FormatarValor(ValorICMS), 6, '', 'T', 'R');
    DesenharTexto(Pdf, 174, Y + 1, 22, 5, FormatarValor(ValorPISCOFINS), 6, '', 'T', 'R');
    DesenharLinhaVertical(Pdf, 51, Y, Altura);
    DesenharLinhaVertical(Pdf, 60, Y, Altura);
    DesenharLinhaVertical(Pdf, 74, Y, Altura);
    DesenharLinhaVertical(Pdf, 90, Y, Altura);
    DesenharLinhaVertical(Pdf, 112, Y, Altura);
    DesenharLinhaVertical(Pdf, 134, Y, Altura);
    DesenharLinhaVertical(Pdf, 152, Y, Altura);
    DesenharLinhaVertical(Pdf, 174, Y, Altura);
    if TextoSeguro(Item.infAdProd) <> '' then
      DesenharTexto(Pdf, 1, Y + 8, 49, 5, Item.infAdProd, 6, 'I', 'T', 'L');
    Y := Y + Altura;
  end;

  { Totais e tributos. }
  Altura := 28;
  DesenharCaixa(Pdf, 0, Y, Largura, Altura);
  DesenharCaixa(Pdf, 0, Y, 52, Altura);
  DesenharCaixa(Pdf, 54, Y, 46, Altura);
  DesenharCaixa(Pdf, 102, Y, 94, Altura);
  DesenharRotulo(Pdf, 2, Y + 1, 48, 'Valor total da NFCom', FormatarValor(Nota.Total.vNF), 6, 9, 'R');
  DesenharRotulo(Pdf, 2, Y + 10, 48, 'Base de cálculo ICMS', FormatarValor(Nota.Total.vBC), 6, 8, 'R');
  DesenharRotulo(Pdf, 2, Y + 19, 48, 'Valor ICMS', FormatarValor(Nota.Total.vICMS), 6, 8, 'R');
  DesenharRotulo(Pdf, 56, Y + 1, 42, 'PIS', FormatarValor(Nota.Total.vPIS), 6, 8, 'R');
  DesenharRotulo(Pdf, 56, Y + 10, 42, 'COFINS', FormatarValor(Nota.Total.vCOFINS), 6, 8, 'R');
  DesenharRotulo(Pdf, 56, Y + 19, 42, 'FUST/FUNTTEL', FormatarValor(Nota.Total.vFUST + Nota.Total.vFUNTTEL), 6, 8, 'R');
  DesenharTexto(Pdf, 104, Y + 1, 90, 4, 'INFORMAÇÕES DOS TRIBUTOS', 6, 'B', 'T', 'C');
  DesenharTexto(Pdf, 104, Y + 6, 90, 5,
    'ICMS: ' + FormatarValor(Nota.Total.vICMS) +
    '   PIS: ' + FormatarValor(Nota.Total.vPIS) +
    '   COFINS: ' + FormatarValor(Nota.Total.vCOFINS), 6, '', 'T', 'L');
  DesenharTexto(Pdf, 104, Y + 13, 90, 5,
    'IBS/CBS base: ' + FormatarValor(Nota.Total.IBSCBSTot.vBCIBSCBS), 6, '', 'T', 'L');
  DesenharTexto(Pdf, 104, Y + 20, 90, 5,
    'Reservado ao fisco: ' + TextoSeguro(Nota.infAdic.infAdFisco), 6, '', 'T', 'L');
  Y := Y + Altura;

  { Cobrança e informações adicionais. }
  Altura := 31;
  DesenharCaixa(Pdf, 0, Y, Largura, Altura);
  DesenharCaixa(Pdf, 0, Y, 78, Altura);
  DesenharCaixa(Pdf, 80, Y, 116, Altura);
  DesenharTexto(Pdf, 2, Y + 1, 74, 4, 'FATURAMENTO / COBRANÇA', 6, 'B', 'T', 'C');
  DesenharRotulo(Pdf, 2, Y + 7, 35, 'Competência', FormatarData(Nota.gFat.CompetFat), 6, 7);
  DesenharRotulo(Pdf, 40, Y + 7, 35, 'Vencimento', FormatarData(Nota.gFat.dVencFat), 6, 7);
  DesenharRotulo(Pdf, 2, Y + 17, 73, 'Total a pagar', 'R$ ' + FormatarValor(Nota.Total.vNF), 6, 9, 'R');
  DesenharTexto(Pdf, 82, Y + 1, 112, 4, 'DADOS ADICIONAIS', 6, 'B', 'T', 'C');
  DesenharTexto(Pdf, 83, Y + 7, 110, 18, TextoSeguro(Nota.infAdic.infCpl), 7, '', 'T', 'L');
  Y := Y + Altura;

  { Rodapé com chave, QRCode e código de barras. }
  Altura := 43;
  DesenharCaixa(Pdf, 0, Y, Largura, Altura);
  DesenharTexto(Pdf, 2, Y + 1, 142, 4, 'CHAVE DE ACESSO DA NFCom', 6, 'B', 'T', 'L');
  DesenharTexto(Pdf, 2, Y + 6, 142, 8, FormatarChaveAcesso(Nota.infNFCom.ID), 7, '', 'T', 'L');
  DesenharTexto(Pdf, 2, Y + 17, 142, 4, 'PROTOCOLO DE AUTORIZAÇÃO DE USO', 6, 'B', 'T', 'L');
  if FCancelada then
    Texto := 'NFCom CANCELADA'
  else if Nota.procNFCom.cStat > 0 then
    Texto := Nota.procNFCom.nProt + ' ' + FormatarDataHora(Nota.procNFCom.dhRecbto)
  else
    Texto := 'NFCom NÃO PROTOCOLADA NA SEFAZ - SEM VALOR FISCAL';
  DesenharTexto(Pdf, 2, Y + 22, 142, 8, Texto, 7, '', 'T', 'L');
  if TextoSeguro(Nota.infNFComSupl.qrCodNFCom) <> '' then
    Pdf.QRCode(166, Y + 2, 24, Nota.infNFComSupl.qrCodNFCom);
  CodigoBarras := OnlyNumber(Nota.gFat.codBarras);
  if CodigoBarras <> '' then
    Pdf.Code128(CodigoBarras, 5, Y + 34, 6, 0.28);
  DesenharTexto(Pdf, 82, Y + 35, 112, 5, CodigoBarras, 6, '', 'T', 'C');

  if TextoSeguro(Nota.gFat.gPIX.urlQRCodePIX) <> '' then
    Pdf.QRCode(145, Y + 17, 18, Nota.gFat.gPIX.urlQRCodePIX);

  { Rodapé técnico equivalente ao sistema antigo. }
  Y := Y + Altura + 2;
  DesenharTexto(Pdf, 0, Y, Largura, 5,
    'Documento emitido por ACBr - DANFCom FPDF | Impresso em ' + FormatarDataHora(Now), 6, '', 'T', 'C');
end;

procedure TDANFComFPDFRelatorio.SalvarPDF(const NomeArquivo: string);
var
  Motor: TFPDFEngine;
begin
  Motor := TFPDFEngine.Create(Self, False);
  try
    Motor.Compressed := True;
    Motor.SaveToFile(NomeArquivo);
  finally
    Motor.Free;
  end;
end;

procedure TDANFComFPDFRelatorio.SalvarPDF(Fluxo: TStream);
var
  Motor: TFPDFEngine;
begin
  if not Assigned(Fluxo) then
    raise EACBrNFComException.Create('Fluxo de saída não foi informado.');

  Motor := TFPDFEngine.Create(Self, False);
  try
    Motor.Compressed := True;
    Motor.SaveToStream(Fluxo);
  finally
    Motor.Free;
  end;
end;

{ TDANFComEventoFPDFRelatorio }

constructor TDANFComEventoFPDFRelatorio.Create(
  AEvento: TInfEventoCollectionItem; ANFCom: TNFCom);
begin
  inherited Create;
  FEvento := AEvento;
  FNotaFiscal := ANFCom;
  FInicializado := False;
  SetFont('Arial');
  SetUTF8(False);
  SetMargins(MargemPadrao, MargemPadrao, MargemPadrao, MargemPadrao);
end;

function TDANFComEventoFPDFRelatorio.FormatarDataHora(
  const Data: TDateTime): string;
begin
  if Data <= 0 then
    Result := ''
  else
    Result := FormatDateTime('dd/mm/yyyy hh:nn:ss', Data);
end;

procedure TDANFComEventoFPDFRelatorio.DesenharTexto(const Pdf: IFPDF;
  const X, Y, Largura, Altura: Double; const Texto: string; Tamanho: Double;
  const Estilo: string; const AlinhamentoVertical,
  AlinhamentoHorizontal: Char; Borda: Boolean);
begin
  Pdf.SetFont('Arial', Estilo, Tamanho);
  Pdf.TextBox(X, Y, Largura, Altura, NativeStringToAnsi(Texto),
    AlinhamentoHorizontal, AlinhamentoVertical, Borda);
end;

procedure TDANFComEventoFPDFRelatorio.DesenharLinha(const Pdf: IFPDF;
  const X, Y, Largura, Altura: Double; Preenchida: Boolean);
begin
  Pdf.SetLineWidth(0.25);
  if Preenchida then
    Pdf.SetFillColor(235, 235, 235)
  else
    Pdf.SetFillColor(255, 255, 255);
  Pdf.Rect(X, Y, Largura, Altura, 'DF');
end;

procedure TDANFComEventoFPDFRelatorio.OnStartReport(
  Argumentos: TFPDFReportEventArgs);
begin
  if FInicializado then
    Exit;
  if not Assigned(FEvento) then
    raise EACBrNFComException.Create(
      'Evento NFCom não foi informado para o relatório FPDF.');
  AddPage(poPortrait, puMM, pfA4);
  AddBand(btData, 282, DesenharDocumento);
  FInicializado := True;
end;

procedure TDANFComEventoFPDFRelatorio.DesenharDocumento(
  Argumentos: TFPDFBandDrawArgs);
var
  Pdf: IFPDF;
  Evento: TInfEvento;
  Retorno: TRetInfEvento;
  Y: Double;
begin
  Pdf := Argumentos.PDF;
  Evento := FEvento.InfEvento;
  Retorno := FEvento.RetInfEvento;
  Pdf.SetLineWidth(0.25);
  Pdf.SetDrawColor(0, 0, 0);
  Pdf.SetTextColor(0, 0, 0);
  Pdf.SetFillColor(255, 255, 255);

  Y := 0;
  DesenharLinha(Pdf, 0, Y, 196, 24, True);
  DesenharTexto(Pdf, 2, Y + 2, 192, 5,
    'DOCUMENTO AUXILIAR DO EVENTO DA NFCom', 11, 'B', 'T', 'C');
  DesenharTexto(Pdf, 2, Y + 9, 192, 4,
    Evento.DescEvento, 9, 'B', 'T', 'C');
  DesenharTexto(Pdf, 2, Y + 15, 192, 4,
    'Evento NFCom - modelo 62', 8, '', 'T', 'C');

  Y := 28;
  DesenharLinha(Pdf, 0, Y, 196, 42);
  DesenharTexto(Pdf, 2, Y + 2, 192, 4, 'DADOS DO EVENTO', 7, 'B', 'T', 'L');
  DesenharTexto(Pdf, 2, Y + 8, 94, 4,
    'CNPJ AUTOR: ' + Evento.CNPJ, 8, '', 'T', 'L');
  DesenharTexto(Pdf, 2, Y + 14, 94, 4,
    'CÓDIGO DO ÓRGÃO: ' + IntToStr(Evento.cOrgao), 8, '', 'T', 'L');
  DesenharTexto(Pdf, 2, Y + 20, 94, 4,
    'AMBIENTE: ' + IntToStr(Integer(Evento.tpAmb)), 8, '', 'T', 'L');
  DesenharTexto(Pdf, 2, Y + 26, 94, 4,
    'DATA DO EVENTO: ' + FormatarDataHora(Evento.dhEvento), 8, '', 'T', 'L');
  DesenharTexto(Pdf, 100, Y + 8, 94, 4,
    'TIPO DO EVENTO: ' + Evento.TipoEvento, 8, '', 'T', 'L');
  DesenharTexto(Pdf, 100, Y + 14, 94, 4,
    'SEQUÊNCIA: ' + IntToStr(Evento.nSeqEvento), 8, '', 'T', 'L');
  DesenharTexto(Pdf, 100, Y + 20, 94, 4,
    'ID: ' + Evento.id, 7, '', 'T', 'L');

  Y := 74;
  DesenharLinha(Pdf, 0, Y, 196, 42);
  DesenharTexto(Pdf, 2, Y + 2, 192, 4,
    'DOCUMENTO VINCULADO', 7, 'B', 'T', 'L');
  DesenharTexto(Pdf, 2, Y + 9, 192, 6,
    'CHAVE DE ACESSO NFCom: ' + Evento.chNFCom, 8, '', 'T', 'L');
  if Assigned(FNotaFiscal) then
  begin
    DesenharTexto(Pdf, 2, Y + 17, 192, 4,
      'EMITENTE: ' + FNotaFiscal.Emit.xNome, 8, '', 'T', 'L');
    DesenharTexto(Pdf, 2, Y + 23, 192, 4,
      'CNPJ: ' + FNotaFiscal.Emit.CNPJ, 8, '', 'T', 'L');
    DesenharTexto(Pdf, 2, Y + 29, 192, 4,
      'NÚMERO / SÉRIE: ' + IntToStr(FNotaFiscal.Ide.nNF) + ' / ' +
      IntToStr(FNotaFiscal.Ide.serie), 8, '', 'T', 'L');
  end;

  Y := 120;
  DesenharLinha(Pdf, 0, Y, 196, 62);
  DesenharTexto(Pdf, 2, Y + 2, 192, 4,
    'DETALHES DO EVENTO', 7, 'B', 'T', 'L');
  DesenharTexto(Pdf, 2, Y + 9, 192, 4,
    'DESCRIÇÃO: ' + Evento.detEvento.descEvento, 8, '', 'T', 'L');
  DesenharTexto(Pdf, 2, Y + 17, 192, 4,
    'PROTOCOLO VINCULADO: ' + Evento.detEvento.nProt, 8, '', 'T', 'L');
  DesenharTexto(Pdf, 2, Y + 25, 192, 4,
    'JUSTIFICATIVA: ' + Evento.detEvento.xJust, 8, '', 'T', 'L');
  DesenharTexto(Pdf, 2, Y + 34, 192, 4,
    'PROTOCOLO DO PAGAMENTO: ' + Evento.detEvento.nProtVincPgto,
    8, '', 'T', 'L');

  Y := 188;
  DesenharLinha(Pdf, 0, Y, 196, 38, True);
  DesenharTexto(Pdf, 2, Y + 2, 192, 4,
    'RETORNO DO PROCESSAMENTO', 7, 'B', 'T', 'L');
  DesenharTexto(Pdf, 2, Y + 10, 192, 4,
    'STATUS: ' + IntToStr(Retorno.cStat) + ' - ' + Retorno.xMotivo,
    8, '', 'T', 'L');
  DesenharTexto(Pdf, 2, Y + 18, 192, 4,
    'PROTOCOLO: ' + Retorno.nProt, 8, '', 'T', 'L');
  DesenharTexto(Pdf, 2, Y + 26, 192, 4,
    'REGISTRO: ' + FormatarDataHora(Retorno.dhRegEvento), 8, '', 'T', 'L');
end;

procedure TDANFComEventoFPDFRelatorio.SalvarPDF(const NomeArquivo: string);
var
  Motor: TFPDFEngine;
begin
  Motor := TFPDFEngine.Create(Self, False);
  try
    Motor.Compressed := True;
    Motor.SaveToFile(NomeArquivo);
  finally
    Motor.Free;
  end;
end;

procedure TDANFComEventoFPDFRelatorio.SalvarPDF(Fluxo: TStream);
var
  Motor: TFPDFEngine;
begin
  if not Assigned(Fluxo) then
    raise EACBrNFComException.Create('Fluxo de saída não foi informado.');
  Motor := TFPDFEngine.Create(Self, False);
  try
    Motor.Compressed := True;
    Motor.SaveToStream(Fluxo);
  finally
    Motor.Free;
  end;
end;

{ TACBrNFComDANFComFPDF }

function TACBrNFComDANFComFPDF.ObterNomeArquivo(ANFCom: TNFCom): string;
begin
  Result := DefinirNomeArquivo(PathPDF,
    RemoverLiteralChave(ANFCom.infNFCom.ID) + '-nfcom.pdf', NomeDocumento);
end;

procedure TACBrNFComDANFComFPDF.GerarPDF(ANFCom: TNFCom; Fluxo: TStream);
var
  Relatorio: TDANFComFPDFRelatorio;
begin
  if not Assigned(Fluxo) then
    raise EACBrNFComException.Create('Fluxo de saída não foi informado.');

  Fluxo.Size := 0;
  Relatorio := TDANFComFPDFRelatorio.Create(ANFCom, Cancelada, Logo);
  try
    Relatorio.SalvarPDF(Fluxo);
  finally
    Relatorio.Free;
  end;
end;

procedure TACBrNFComDANFComFPDF.GerarPDF(ANFCom: TNFCom; const NomeArquivo: string);
var
  Relatorio: TDANFComFPDFRelatorio;
begin
  ForceDirectories(ExtractFilePath(NomeArquivo));
  Relatorio := TDANFComFPDFRelatorio.Create(ANFCom, Cancelada, Logo);
  try
    Relatorio.SalvarPDF(NomeArquivo);
  finally
    Relatorio.Free;
  end;
end;

function TACBrNFComDANFComFPDF.ObterNomeArquivoEvento(
  AEvento: TInfEventoCollectionItem): string;
begin
  Result := DefinirNomeArquivo(PathPDF,
    RemoverLiteralChave(AEvento.InfEvento.id) + '-procEventoNFCom.pdf',
    NomeDocumento);
end;

procedure TACBrNFComDANFComFPDF.GerarPDFEvento(
  AEvento: TInfEventoCollectionItem; ANFCom: TNFCom; Fluxo: TStream);
var
  Relatorio: TDANFComEventoFPDFRelatorio;
begin
  if not Assigned(Fluxo) then
    raise EACBrNFComException.Create('Fluxo de saída não foi informado.');
  Fluxo.Size := 0;
  Relatorio := TDANFComEventoFPDFRelatorio.Create(AEvento, ANFCom);
  try
    Relatorio.SalvarPDF(Fluxo);
  finally
    Relatorio.Free;
  end;
end;

procedure TACBrNFComDANFComFPDF.GerarPDFEvento(
  AEvento: TInfEventoCollectionItem; ANFCom: TNFCom;
  const NomeArquivo: string);
var
  Relatorio: TDANFComEventoFPDFRelatorio;
begin
  ForceDirectories(ExtractFilePath(NomeArquivo));
  Relatorio := TDANFComEventoFPDFRelatorio.Create(AEvento, ANFCom);
  try
    Relatorio.SalvarPDF(NomeArquivo);
  finally
    Relatorio.Free;
  end;
end;

procedure TACBrNFComDANFComFPDF.ImprimirDANFCom(ANFCom: TNFCom);
begin
  ImprimirDANFComPDF(ANFCom);
end;

procedure TACBrNFComDANFComFPDF.ImprimirDANFComPDF(ANFCom: TNFCom);
var
  Indice: Integer;
  Nota: TNFCom;
  NomeArquivo: string;
begin
  FPArquivoPDF := '';
  if Assigned(ANFCom) then
  begin
    NomeArquivo := ObterNomeArquivo(ANFCom);
    GerarPDF(ANFCom, NomeArquivo);
    FPArquivoPDF := NomeArquivo;
    Exit;
  end;

  if not Assigned(ACBrNFCom) then
    raise EACBrNFComException.Create('ACBrNFCom não foi associado.');

  for Indice := 0 to TACBrNFCom(ACBrNFCom).NotasFiscais.Count - 1 do
  begin
    Nota := TACBrNFCom(ACBrNFCom).NotasFiscais[Indice].NFCom;
    NomeArquivo := ObterNomeArquivo(Nota);
    GerarPDF(Nota, NomeArquivo);
    FPArquivoPDF := NomeArquivo;
    TACBrNFCom(ACBrNFCom).NotasFiscais[Indice].NomeArqPDF := NomeArquivo;
  end;
end;

procedure TACBrNFComDANFComFPDF.ImprimirDANFComPDF(AStream: TStream;
  ANFCom: TNFCom);
begin
  if not Assigned(AStream) then
    raise EACBrNFComException.Create('Fluxo de saída não foi informado.');

  if Assigned(ANFCom) then
    GerarPDF(ANFCom, AStream)
  else if Assigned(ACBrNFCom) and (TACBrNFCom(ACBrNFCom).NotasFiscais.Count > 0) then
    GerarPDF(TACBrNFCom(ACBrNFCom).NotasFiscais[0].NFCom, AStream)
  else
    raise EACBrNFComException.Create('Nenhuma NFCom foi informada.');
end;

procedure TACBrNFComDANFComFPDF.ImprimirDANFComResumidoPDF(ANFCom: TNFCom);
begin
  ImprimirDANFComPDF(ANFCom);
end;

procedure TACBrNFComDANFComFPDF.ImprimirDANFComCancelado(ANFCom: TNFCom);
var
  CanceladaAnterior: Boolean;
begin
  CanceladaAnterior := Cancelada;
  Cancelada := True;
  try
    ImprimirDANFCom(ANFCom);
  finally
    Cancelada := CanceladaAnterior;
  end;
end;

procedure TACBrNFComDANFComFPDF.ImprimirEVENTO(ANFCom: TNFCom);
begin
  ImprimirEVENTOPDF(ANFCom);
end;

procedure TACBrNFComDANFComFPDF.ImprimirEVENTOPDF(ANFCom: TNFCom);
var
  IndiceEvento, IndiceNota: Integer;
  Nota: TNFCom;
  NomeArquivo: string;
begin
  FPArquivoPDF := '';
  if not Assigned(ACBrNFCom) then
    raise EACBrNFComException.Create('ACBrNFCom não foi associado.');
  if TACBrNFCom(ACBrNFCom).EventoNFCom.Evento.Count = 0 then
    raise EACBrNFComException.Create('Nenhum evento NFCom foi informado.');

  for IndiceEvento := 0 to TACBrNFCom(ACBrNFCom).EventoNFCom.Evento.Count - 1 do
  begin
    Nota := ANFCom;
    if not Assigned(Nota) then
      for IndiceNota := 0 to TACBrNFCom(ACBrNFCom).NotasFiscais.Count - 1 do
        if RemoverLiteralChave(
          TACBrNFCom(ACBrNFCom).NotasFiscais[IndiceNota].NFCom.infNFCom.ID) =
          RemoverLiteralChave(TACBrNFCom(ACBrNFCom).EventoNFCom.Evento[
            IndiceEvento].InfEvento.chNFCom) then
        begin
          Nota := TACBrNFCom(ACBrNFCom).NotasFiscais[IndiceNota].NFCom;
          Break;
        end;

    NomeArquivo := ObterNomeArquivoEvento(
      TACBrNFCom(ACBrNFCom).EventoNFCom.Evento[IndiceEvento]);
    GerarPDFEvento(TACBrNFCom(ACBrNFCom).EventoNFCom.Evento[IndiceEvento],
      Nota, NomeArquivo);
    FPArquivoPDF := FPArquivoPDF + NomeArquivo;
    if IndiceEvento < TACBrNFCom(ACBrNFCom).EventoNFCom.Evento.Count - 1 then
      FPArquivoPDF := FPArquivoPDF + sLinebreak;
  end;
end;

procedure TACBrNFComDANFComFPDF.ImprimirEVENTOPDF(AStream: TStream;
  ANFCom: TNFCom);
var
  IndiceEvento, IndiceNota: Integer;
  Nota: TNFCom;
begin
  if not Assigned(AStream) then
    raise EACBrNFComException.Create('Fluxo de saída não foi informado.');
  if not Assigned(ACBrNFCom) then
    raise EACBrNFComException.Create('ACBrNFCom não foi associado.');

  for IndiceEvento := 0 to TACBrNFCom(ACBrNFCom).EventoNFCom.Evento.Count - 1 do
  begin
    Nota := ANFCom;
    if not Assigned(Nota) then
      for IndiceNota := 0 to TACBrNFCom(ACBrNFCom).NotasFiscais.Count - 1 do
        if RemoverLiteralChave(
          TACBrNFCom(ACBrNFCom).NotasFiscais[IndiceNota].NFCom.infNFCom.ID) =
          RemoverLiteralChave(TACBrNFCom(ACBrNFCom).EventoNFCom.Evento[
            IndiceEvento].InfEvento.chNFCom) then
        begin
          Nota := TACBrNFCom(ACBrNFCom).NotasFiscais[IndiceNota].NFCom;
          Break;
        end;

    GerarPDFEvento(TACBrNFCom(ACBrNFCom).EventoNFCom.Evento[IndiceEvento],
      Nota, AStream);
    Break;
  end;
end;

end.
