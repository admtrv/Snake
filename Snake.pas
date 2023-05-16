uses WPFObjects;

const cellSize = 20.0;
const Width = 30;
const Height = 20;

var Snake : array of CircleWPF;
var Fruit : array of CircleWPF;
var alive : boolean;
var score : integer;
  
procedure GrowSnake;
begin
  SetLength(Snake, Snake.Length + 1);
  Snake[Snake.Length - 1] := new CircleWPF(Snake[Snake.Length - 2].Center.X, Snake[Snake.Length - 2].Center.Y, Snake[Snake.Length - 2].Radius, Colors.Green);
end;

procedure MakeFruit;
begin
  Fruit := new CircleWPF[1];
  Fruit[0] := new CircleWPF((random(30)+0.5)*cellSize, (random(20)+0.5)*cellSize, cellSize/2, Colors.Orange);
end;

//  Эта процедура пересоздаёт фрукт с индексом i - в том случае, если его 'съели'
procedure RespawnFruit(i : integer);
begin
  //  Сначала проверяем, находится ли индекс внутри массива
  if (i<0) or (i>Fruit.High) then
    exit;
  //  Теперь уничтожаем "старый фрукт" и создаём его заново на новом месте,
  //  проверяя, чтобы он не был создан "внутри" змеи
  
  //  Генерируем центр нового фрукта до тех пор, пока не окажемся вне змеи
  var x,y : real;
  var insideSnake : boolean;
  repeat
    insideSnake := false;
    (x,y) := ((random(Width)+0.5)*cellSize, (random(Height)+0.5)*cellSize);
    for var j := 0 to Snake.High do
      if sqrt(sqr(Snake[j].Center.X - x) + sqr(Snake[j].Center.Y - y)) < cellSize/2 then
        insideSnake := true;
    //  Тут ещё было бы неплохо таким же циклом проверить, не создаётся ли фрукт поверх 
    //  другого фрукта. А то наложение будет - некрасиво
  until not insideSnake;
  //  Если такой фрукт раньше был, то удаляем его
  if Fruit[i] <> nil then Fruit[i].Destroy;
  //  И создаём новый в новом месте
  Fruit[i] := new CircleWPF(x,y, cellSize/2, Colors.Orange);
  
end;

procedure Init;
begin
  score := 0;
  Snake := new CircleWPF[1];
  Snake[0] := new CircleWPF((Width/2+0.5)*cellSize, (Height/2+0.5)*cellSize, cellSize/2, Colors.Red);
  GrowSnake;
  GrowSnake;
  //  Дублирование процедуры MakeFruit - зачем?
  //Fruit := new CircleWPF[1];
  //Fruit[0] := new CircleWPF((random(30)+0.5)*cellSize, (random(20)+0.5)*cellSize, cellSize/2, Colors.Orange);
  
  Fruit := new CircleWPF[1];
  RespawnFruit(0);
  
  Window.SetSize(cellSize*Width, cellSize*Height);
  Window.CenterOnScreen;
  alive := true;
end;

procedure KeyDown(k: Key);
begin
  case k of
    Key.Left : snake[0].Direction := (-cellSize, 0.0);
    Key.Right : snake[0].Direction := (cellSize, 0.0);
    Key.Up : snake[0].Direction := (0.0, -cellSize);
    Key.Down : snake[0].Direction := (0.0, cellSize);
    Key.Space : ;
  end;
end;

procedure Death;
begin
  for var i:=4 to snake.length-1 do 
  if sqrt(sqr(Snake[0].Center.X - Snake[i].Center.X) + sqr(Snake[0].Center.Y - Snake[i].Center.Y)) < cellSize/2 then
    alive := false;
end;

procedure Meal;
begin
  //  Безобразие! Цикл неправильный - он должен проходить по всему массиву фруктов и проверять на пересечение 
  //  с головой змеи. Сейчас проверяется первый фрукт с всеми кусочками змеи - зачем такое?
  
  //  И вообще, эта процедура нигде не вызывается, её надо внутри MoveAll вызывать
  
  for var i:=0 to Fruit.High do 
    if sqrt(sqr(Fruit[i].Center.X - Snake[0].Center.X) + sqr(Fruit[i].Center.Y - Snake[0].Center.Y)) < cellSize/2 then
      begin
        GrowSnake;
        //  Это тоже плохо - тут внутри процедуры полностью обновляется массив фруктов.
        //  То есть полностью будут сбрасываться все фрукты и заново создаваться (там на самом деле создаётся только один)
        //MakeFruit;
        RespawnFruit(i);
        Score+=10;
      end;
end;

procedure MoveAll;
begin
  for var i := Snake.Length-1 downto 1 do
    Snake[i].MoveTo(Snake[i-1].Left, Snake[i-1].Top); 
  
  Snake[0].Move;
  if Snake[0].Center.Y < 0 then
    Snake[0].MoveBy(0, cellSize*Height)
  else
    if Snake[0].Center.Y > cellSize*Height then
      Snake[0].MoveBy(0, -cellSize*Height);
  //  Дописать по X
  if snake[0].Center.x < 0 then 
    Snake[0].MoveBy(cellSize*width,0)
  else 
    if Snake[0].Center.x > cellSize*width then
      Snake[0].MoveBy(-cellSize*width, 0);
  Death;
  Meal;
  Window.Caption := 'Счёт : ' + score.ToString;
end;

begin
  Init;
  
  OnKeyDown := KeyDown;
  
  var interval := 700;
  var steps := 0;
  
  while alive do
  begin
    MoveAll;
    sleep(interval);
    
    steps += 1;
    score+=1;
    if (steps mod 10 = 0) and (interval > 100) then
      interval -= 1;
    
  end;
  //  Добавить массив фруктов - круги
  //  Если змея съедает фрукт, то она растёт и увеличивается счёт, а фрукт появляется в новом месте
end.