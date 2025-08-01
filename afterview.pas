{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit AfterView;

{$warn 5023 off : no warning about unused units}
interface

uses
  AVBevel, AVColorBox, AVGauge, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('AVBevel', @AVBevel.Register);
  RegisterUnit('AVColorBox', @AVColorBox.Register);
  RegisterUnit('AVGauge', @AVGauge.Register);
end;

initialization
  RegisterPackage('AfterView', @Register);
end.
