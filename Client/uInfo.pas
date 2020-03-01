unit uInfo;

interface

uses
  Windows, SysUtils, Classes, uSmb, uEnc;

function GtInPTy(Free: Boolean = False): string;        // GetInfoPCType
function GtInBod(Free: Boolean = False): TStringList;   // GetInfoBoard
function GtInMm(Free: Boolean = False): TStringList;    // GetInfoMem
function GtInCu(Free: Boolean = False): TStringList;    // GetInfoCpu

var
  SMB: TSMBios;

implementation

function GtInPTy(Free: Boolean = False): string;
var
  i: Integer;
  Res: TEnclosureInformation;
begin
  if not Assigned(SMB) then SMB := TSMBios.Create;
                                                                                            
  if SMB.HasEnclosureInfo then
    for i := low(SMB.EnclosureInfo) to high(SMB.EnclosureInfo) do
    begin
      Res := SMB.EnclosureInfo[i];
      Result := Res.TypeStr;
    end;

  if Free then begin
    SMB.Free;
    SMB := nil;
  end;
end; { GetInfoPCType -> Desktop or Notebook }

function GtInBod(Free: Boolean = False): TStringList;
var
  i: Integer;
  Res: TBaseBoardInformation;
begin
  if not Assigned(SMB) then SMB := TSMBios.Create;
  Result := TStringList.Create;
  Result.Add(Format('=========== %s ===========', [DE('EdrHdWBUOC/Xl4K')]));
  Result.Add('===================================');

  if SMB.HasBaseBoardInfo then
    for i := Low(SMB.BaseBoardInfo) to High(SMB.BaseBoardInfo) do begin
      Res := SMB.BaseBoardInfo[i];
      Result.Add(Format('%s               %s', [DE('ElLag6ZlQ5LNOC'), Res.ManufacturerStr]));
      Result.Add(Format('%s                  %s', [DE('ZVLGAaRFLD'), Res.ProductStr]));
    end;

  Result.Add('');  
  if Free then begin
    SMB.Free;
    SMB := nil;
  end;
end; { GetInfoMem -> Motherboard Information }

function GtInMm(Free: Boolean = False): TStringList;
var
  i: Integer;
  Res: TMemoryDeviceInformation;
begin
  if not Assigned(SMB) then SMB := TSMBios.Create;
  Result := TStringList.Create;
  Result.Add(Format('============== %s =============', [DE('E1bLD/vP')]));
  Result.Add('===================================');

  if SMB.HasMemoryDeviceInfo then
    for i := Low(SMB.MemoryDeviceInfo) to High(SMB.MemoryDeviceInfo) do begin
      Res := SMB.MemoryDeviceInfo[i];
      Result.Add(Format('----- %s %s -----', [DE('apv1f27k'), Res.GetDeviceLocatorStr]));
      Result.Add(Format('%s              %d bits', [DE('d5W1K4wqcjh2ulI'), Res.RAWMemoryDeviceInfo.TotalWidth]));
      Result.Add(Format('Size                     %d MB', [Res.GetSize]));
      Result.Add(Format('%s              %s', [DE('Pht29F309UdwUrA'), Res.GetFormFactor]));
      Result.Add(Format('%s             %s', [DE('LxByeVMpEcpnXQiW'), Res.GetBankLocatorStr]));
      Result.Add(Format('%s                    %d MHz', [DE('aV+oPxP'), Res.RAWMemoryDeviceInfo.Speed]));
    end;

  Result.Add('');
  if Free then begin
    SMB.Free;
    SMB := nil;
  end;
end; { GetInfoMem -> Memory Information }

function GtInCu(Free: Boolean = False): TStringList;
var
  i: Integer;
  Res: TProcessorInformation;
begin
  if not Assigned(SMB) then SMB := TSMBios.Create;
  Result := TStringList.Create;
  Result.Add(Format('=============== %s ===============', [DE('K9vQ')]));
  Result.Add('===================================');

  if SMB.HasProcessorInfo then
    for I := Low(SMB.ProcessorInfo) to High(SMB.ProcessorInfo) do
    begin
      Res := SMB.ProcessorInfo[I];
      Result.Add(Format('%s               ', [DE('ElLag6ZlQ5LNOC'), Res.ProcessorManufacturerStr]));
      Result.Add(Format('%s       ', [DE('apv1f27ksga6aL5DYWmTpsPm'), Res.SocketDesignationStr]));
      Result.Add('Type                     ' + Res.ProcessorTypeStr);
      Result.Add(Format('%s                  ', [DE('PZtZ7QsWpB'), Res.ProcessorFamilyStr]));
      Result.Add(Format('%s                  ', [DE('fhvbgtTOGD'), Res.ProcessorVersionStr]));
      Result.Add(Format('%s             %x', [DE('ZVLGH2mp+y3bJW2c'), Res.RAWProcessorInformation^.ProcessorID]));
      Result.Add(Format('%s           %d Mhz', [DE('MNTudxokM5ExwkRagbH'), Res.RAWProcessorInformation^.ExternalClock]));
      Result.Add(Format('%s        %d Mhz', [DE('Elrf6Lq2uTIZN3HRB3Il6GF'), Res.RAWProcessorInformation^.MaxSpeed]));
      Result.Add(Format('%s        %d Mhz', [DE('Kp9Mfw6nbbSe7aPxYQSQNoN'), Res.RAWProcessorInformation^.CurrentSpeed]));

      if (Res.RAWProcessorInformation^.L1CacheHandle > 0) and (Res.L2Chache <> nil) then begin
        Result.Add('');
        Result.Add(Format('----- %s -----', [DE('FdpFy81JfAA')]));
        Result.Add(Format('%s       ', [DE('apv1f27ksga6aL5DYWmTpsPm'), Res.L1Chache.SocketDesignationStr]));
        Result.Add(Format('%s      %.4x', [DE('K589TJ3LdzDmKDHsneynyJidiD'), Res.L1Chache.RAWCacheInformation^.CacheConfiguration]));
        Result.Add(Format('%s       %d Kb', [DE('Elrf6Lq2uTIZ832val4xx2mV'), Res.L1Chache.GetMaximumCacheSize]));
        Result.Add(Format('%s     %d Kb', [DE('ABfhFkekSAeVMpStZLIXVoNHzaC'), Res.L1Chache.GetInstalledCacheSize]));
      end;

      if (Res.RAWProcessorInformation^.L2CacheHandle > 0) and (Res.L2Chache <> nil) then begin
        Result.Add('');
        Result.Add(Format('----- %s -----', [DE('FR56g8BsY0L')]));
        Result.Add(Format('%s       ', [DE('apv1f27ksga6aL5DYWmTpsPm'), Res.L2Chache.SocketDesignationStr]));
        Result.Add(Format('%s      %.4x', [DE('K589TJ3LdzDmKDHsneynyJidiD'), Res.L2Chache.RAWCacheInformation^.CacheConfiguration]));
        Result.Add(Format('%s       %d Kb', [DE('Elrf6Lq2uTIZ832val4xx2mV'), Res.L2Chache.GetMaximumCacheSize]));
        Result.Add(Format('%s     %d Kb', [DE('ABfhFkekSAeVMpStZLIXVoNHzaC'), Res.L2Chache.GetInstalledCacheSize]));
      end;

      if (Res.RAWProcessorInformation^.L3CacheHandle > 0) and (Res.L3Chache <> nil) then
      begin
        Result.Add('');
        Result.Add('----- L3 Cache -----');
        Result.Add(Format('%s       ', [DE('apv1f27ksga6aL5DYWmTpsPm'), Res.L3Chache.SocketDesignationStr]));
        Result.Add(Format('%s      %.4x', [DE('K589TJ3LdzDmKDHsneynyJidiD'), Res.L3Chache.RAWCacheInformation^.CacheConfiguration]));
        Result.Add(Format('%s       %d Kb', [DE('Elrf6Lq2uTIZ832val4xx2mV'), Res.L3Chache.GetMaximumCacheSize]));
        Result.Add(Format('%s     %d Kb', [DE('ABfhFkekSAeVMpStZLIXVoNHzaC'), Res.L3Chache.GetInstalledCacheSize]));
      end;
    end;

  Result.Add('');
  if Free then begin
    SMB.Free;
    SMB := nil;
  end;
end; { GetInfoMem -> CPU Information }

end.

