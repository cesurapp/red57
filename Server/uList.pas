{##########################################
#                                         #
#  List                                   #
#                                         #
#  Author:   red57                        #
#  Date:     2010-07-08                   #
#  Version:  0.1                          #
#                                         #
##########################################}

unit uList;

interface
uses Windows;

const
  MaxListSize = 134217727;

type
  TListAssignOp = (laCopy, laAnd, laOr, laXor, laSrcUnique, laDestUnique);
  TListSortCompare = function(Item1, Item2: Pointer): Integer;
  TPointerList = array[0..MaxListSize-1] of Pointer;
  PPointerList = ^TPointerList;
  TPointerArray = array of Pointer;

  TList = class
  private
    FList: TPointerArray;
    FPList: PPointerList;
    FCount: Integer;
    FCapacity: Integer;
    procedure SetCapacity(Value: Integer);
    function ValidIndex(Index: Integer): Boolean;
    function GetItem(Index: Integer): Pointer;
    procedure SetItem(Index: Integer; Item: Pointer);
    procedure MoveBlock(Index1, Index2, Dir: Integer);
    function Merge(List1, List2: TPointerArray; Compare: TListSortCompare): TPointerArray;
    function MergeSort(List: TPointerArray; Compare: TListSortCompare): TPointerArray;
  protected
    function Compare(Item1, Item2: Pointer): Boolean;
  public
    constructor Create;
    function Add(Item: Pointer): Integer;
    procedure Assign(ListA: TList; AOperator: TListAssignOp = laCopy; ListB: TList = nil);
    procedure Clear;
    procedure Delete(Index: Integer);
    destructor Destroy; override;
    procedure Exchange(Index1, Index2: Integer);
    function Expand: TList;
    function Extract(Item: Pointer): Pointer;
    function First: Pointer;
    function IndexOf(Item: Pointer): Integer;
    procedure Insert(Index: Integer; Item: Pointer);
    function Last: Pointer;
    procedure Move(CurIndex, NewIndex: Integer);
    procedure Pack;
    function Remove(Item: Pointer): Integer;
    procedure Sort(Compare: TListSortCompare);
    property Capacity: Integer read FCapacity write SetCapacity;
    property Count: Integer read FCount;
    property Items[Index: Integer]: Pointer read GetItem write SetItem; default;
    property List: PPointerList read FPList;
  end;

  TDuplicates = (dupIgnore, dupAccept, dupError);

  TThreadList = class
  private
    FDuplicates: TDuplicates;
    FList: TList;
    FLock: TRTLCriticalSection;
  public
    procedure Add(Item: Pointer);
    procedure Clear;
    constructor Create;
    destructor Destroy; override;
    function LockList: TList;
    procedure Remove(Item: Pointer);
    procedure UnlockList;
    property Duplicates: TDuplicates read FDuplicates write FDuplicates;
  end;


implementation

constructor TList.Create;
begin
  inherited Create;
  Clear;
  FPList := @FList;
end;

procedure TList.SetCapacity(Value: Integer);
begin
  if Value <> FCapacity then
  begin
    SetLength(FList, Value);
    FCapacity := Value;
  end;
end;

function TList.ValidIndex(Index: Integer): Boolean;
begin
  Result := (Index >= 0) and (Index < FCount);
end;

function TList.GetItem(Index: Integer): Pointer;
begin
  if ValidIndex(Index) then
    Result := FList[Index]
  else
    Result := nil;
end;

procedure TList.SetItem(Index: Integer; Item: Pointer);
begin
  if ValidIndex(Index) then
    FList[Index] := Item;
end;

procedure TList.MoveBlock(Index1, Index2, Dir: Integer);
var
  I: Integer;
begin
  if Dir > 0 then
    for I := Index2 downto Index1 do
      FList[I + 1] := FList[I]
  else if Dir < 0 then
    for I := Index1 to Index2 do
      FList[I - 1] := FList[I];
end;

function TList.Compare(Item1, Item2: Pointer): Boolean;
begin
  Result := Item1 = Item2;
end;

function TList.Add(Item: Pointer): Integer;
begin
  Expand;
  FList[FCount] := Item;
  Result := FCount;
  Inc(FCount);
end;

procedure TList.Assign(ListA: TList; AOperator: TListAssignOp = laCopy; ListB: TList = nil);
var
  I: Integer;
begin
  if Assigned(ListB) then
  begin
    Assign(ListA);
    Assign(ListB, AOperator);
  end
  else case AOperator of
    laCopy: begin
        FList := ListA.FList;
        FCapacity := ListA.Capacity;
        FCount := ListA.FCount;
      end;
    laAnd:
        for I := FCount - 1 downto 0 do
          if ListA.IndexOf(FList[I]) = -1 then
            Delete(I);
    laOr:
        for I := 0 to ListA.FCount - 1 do
          if IndexOf(ListA.FList[I]) = -1 then
            Add(ListA.FList[I]);
    laXor:
        for I := 0 to ListA.FCount - 1 do
          if Remove(ListA.FList[I]) = -1 then
            Add(ListA.FList[I]);
    laSrcUnique: begin
        Assign(ListA, laAnd);
        Assign(ListA, laXor);
      end;
    laDestUnique: begin
        Assign(ListA, laOr);
        Assign(ListA, laAnd);
      end;
  end;
end;

procedure TList.Clear;
begin
  FCount := 0;
  FCapacity := 0;
  SetLength(FList, 0);
end;

procedure TList.Delete(Index: Integer);
begin
  if ValidIndex(Index) then
  begin
    Dec(FCount);
    if Index < FCount then
      MoveBlock(Index + 1, FCount, -1);
  end;
end;

procedure TList.Exchange(Index1, Index2: Integer);
var
  Tmp: Pointer;
begin
  if ValidIndex(Index1) and ValidIndex(Index2) then
  begin
    Tmp := FList[Index1];
    FList[Index1] := FList[Index2];
    FList[Index2] := Tmp;
  end;
end;

function TList.Expand: TList;
begin
  while FCount >= FCapacity do
    case FCapacity of
      0..4: SetCapacity(FCapacity + 4);
      5..8: SetCapacity(FCapacity + 8);
      else SetCapacity(FCapacity + 16);
    end;
  Result := Self;
end;

function TList.Extract(Item: Pointer): Pointer;
var
  Index: Integer;
begin
  Index := IndexOf(Item);
  Result := GetItem(Index);
  Delete(Index);
end;

function TList.First: Pointer;
begin
  Result := GetItem(0);
end;

function TList.IndexOf(Item: Pointer): Integer;
begin
  for Result := 0 to FCount - 1 do
    if Compare(FList[Result], Item) then
      Exit;
  Result := -1;
end;

procedure TList.Insert(Index: Integer; Item: Pointer);
begin
  if ValidIndex(Index) then
  begin
    Expand;
    MoveBlock(Index, FCount - 1, 1);
    Inc(FCount);
    FList[Index] := Item;
  end;
end;

function TList.Last: Pointer;
begin
  Result := GetItem(FCount - 1);
end;

procedure TList.Move(CurIndex, NewIndex: Integer);
var
  Tmp: Pointer;
begin
  if ValidIndex(CurIndex) and ValidIndex(NewIndex) and (CurIndex <> NewIndex) then
  begin
    Tmp := FList[CurIndex];
    if CurIndex < NewIndex then
      MoveBlock(CurIndex + 1, NewIndex, -1)
    else
      MoveBlock(NewIndex, CurIndex - 1, 1);
    FList[NewIndex] := Tmp;
  end;
end;


procedure TList.Pack;
var
  I: Integer;
begin
  for I := FCount - 1 downto 0 do
    if FList[I] = nil then
      Delete(I);
end;

function TList.Remove(Item: Pointer): Integer;
begin
  Result := IndexOf(Item);
  Delete(Result);
end;


function TList.Merge(List1, List2: TPointerArray; Compare: TListSortCompare): TPointerArray;
var
  I, J, K, L, R: Integer;
  function PostInc(var X: Integer): Integer;
  begin
    Result := X;
    Inc(X);
  end;
begin
  I := 0;
  J := 0;
  R := 0;
  K := Length(List1);
  L := Length(List2);
  SetLength(Result, K + L);
  while (I < K) and (J < L) do
    if Compare(List1[I], List2[J]) >= 0 then
      Result[PostInc(R)] := List1[PostInc(I)]
    else
      Result[PostInc(R)] := List2[PostInc(J)];
  while I < K do
    Result[PostInc(R)] := List1[PostInc(I)];
  while J < L do
    Result[PostInc(R)] := List2[PostInc(J)];
end;

function TList.MergeSort(List: TPointerArray; Compare: TListSortCompare): TPointerArray;
var
  L, P: Integer;
begin
  L := Length(List);
  if L = 1 then
    Result := List
  else
  begin
    P := L div 2;
    Result := Merge(MergeSort(Copy(List, 0, P), Compare),
      MergeSort(Copy(List, P, L), Compare), Compare);
  end;
end;

procedure TList.Sort(Compare: TListSortCompare);
var
  Tmp: Integer;
begin
  if FCount > 1 then
  begin
    Tmp := FCapacity;
    FList := MergeSort(Copy(FList, 0, FCount), Compare);
    FCapacity := FCount;
    SetCapacity(Tmp);
  end;
end;

destructor TList.Destroy;
begin
  Clear;
  inherited Destroy;
end;



procedure TThreadList.Add(Item: Pointer);
begin
  with LockList do try
    if (Duplicates = dupAccept) or (IndexOf(Item) = -1) then
      Add(Item);
  finally
    UnlockList;
  end;
end;

procedure TThreadList.Clear;
begin
  with LockList do try
    Clear;
  finally
    UnlockList;
  end;
end;

constructor TThreadList.Create;
begin
  inherited Create;
  InitializeCriticalSection(FLock);
  FList := TList.Create;
  FDuplicates := dupIgnore;
end;

destructor TThreadList.Destroy;
begin
  FList.Free;
  DeleteCriticalSection(FLock);
  inherited Destroy;
end;

function TThreadList.LockList: TList;
begin
  EnterCriticalSection(FLock);
  Result := FList;
end;

procedure TThreadList.Remove(Item: Pointer);
begin
  with LockList do try
    Remove(Item);
  finally
    UnlockList;
  end;
end;

procedure TThreadList.UnlockList;
begin
  LeaveCriticalSection(FLock);
end;   

end.
