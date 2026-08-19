{ Unidade de registro do componente DANFCom FPDF. }

{$I ACBr.inc}

unit ACBrNFComDANFComFPDFReg;

interface

procedure Register;

implementation

uses
  Classes,
  {$IFDEF FPC}
  LazarusPackageIntf,
  {$ENDIF}
  ACBrNFCom.DANFComFPDF;

procedure Register;
begin
  RegisterComponents('ACBrNFCom', [TACBrNFComDANFComFPDF]);
end;

{$IFDEF FPC}
initialization
  RegisterUnit('ACBrNFComDANFComFPDFReg', @Register);
{$ENDIF}

end.
