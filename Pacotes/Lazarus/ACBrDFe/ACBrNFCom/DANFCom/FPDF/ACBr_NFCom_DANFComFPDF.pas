{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit ACBr_NFCom_DANFComFPDF;

{$warn 5023 off : no warning about unused units}
interface

uses
  ACBrNFCom.DANFComFPDF, ACBrNFComDANFComFPDFReg, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('ACBrNFComDANFComFPDFReg', @ACBrNFComDANFComFPDFReg.Register);
end;

initialization
  RegisterPackage('ACBr_NFCom_DANFComFPDF', @Register);
end.
