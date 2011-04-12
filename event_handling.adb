with Ada_SDL_Video,Ada.Unchecked_Deallocation, Interfaces.C, Gr_Shapes, Drawline_Pkg, Circle_Pkg, Aux_Fct, Ada.Text_Io;
use Ada_SDL_Video, Ada_SDL_Video.PixelPtrPkg, Interfaces.C, Gr_Shapes, Drawline_Pkg, Circle_Pkg, Aux_Fct, Ada.Text_Io;

package body Event_Handling is

	procedure free is new Ada.Unchecked_Deallocation (Shape, ShapePtr);
	procedure free is new Ada.Unchecked_Deallocation (Point, PointPtr);
   	
	procedure insert_shape(Shape_Table: in out ShapePtr; Shape: in ShapePtr) is
		-- Insert a shape into the Scene (called Shape_Table), the table is sorted in order of Identifier
		-- The insertion will never unsort the table, 
		-- unless the Identifier is not unique (god only knows what might happen then)
	   curr : ShapePtr := Shape_Table;
   begin
	   Shape.next := null;
	   if Shape_Table /= null then
		   while curr.next /= null loop
			   if shape.Identifier(2)< curr.next.Identifier(2) or else  shape.Identifier(1)< curr.next.Identifier(1) or else  shape.Identifier(0)< curr.next.Identifier(0) then
				   -- Insert the side
				  shape.next := curr.next;
				  curr.next := shape;
				  return;
			   end if; 
			   curr := curr.next;
		   end loop;
		   curr.next := Shape;
	   else
		   Shape_Table := Shape;
	   end if;
	   end insert_shape;

	   function lowestPriority(Line, Polyline, Polygone, Circle, FCircle : pixel; iR, iG, iB, iA : Integer) return pixel is
		   -- Return the lowest priority of the five entered.
		   -- Requires: All Identifiers are unique.
	   begin
 
		   if (Line(iA) /= 0) and then (Line(iB) <= Polygone(iB) and Line(iB) <= Polyline(iB) and Line(iB) <= Circle(iB) and Line(iB) <= FCircle(iB)) and then (Line(iG) <= Polygone(iG) and Line(iG) <= Polyline(iG) and Line(iG) <= Circle(iG) and Line(iG) <= FCircle(iG)) and then (Line(iR) <= Polygone(iR) and Line(iR) <= Polyline(iR) and Line(iR) <= Circle(iR) and Line(iR) <= FCircle(iR)) then 

		   return Line;

	   elsif (PolyLine(iA) /= 0) and then (PolyLine(iB) <= Polygone(iB) and PolyLine(iB) <= Line(iB) and PolyLine(iB) <= Circle(iB) and PolyLine(iB) <= FCircle(iB)) and then (PolyLine(iG) <= Polygone(iG) and PolyLine(iG) <= Line(iG) and PolyLine(iG) <= Circle(iG) and PolyLine(iG) <= FCircle(iG)) and then (PolyLine(iR) <= Polygone(iR) and PolyLine(iR) <= Line(iR) and PolyLine(iR) <= Circle(iR) and PolyLine(iR) <= FCircle(iR)) then 

		   return PolyLine;

	   elsif (Polygone(iA) /= 0) and then (Polygone(iB) <= PolyLine(iB) and PolyGone(iB) <= Line(iB) and Polygone(iB) <= Circle(iB) and Polygone(iB) <= FCircle(iB)) and then (Polygone(iG) <= PolyLine(iG) and Polygone(iG) <= Line(iG) and Polygone(iG) <= Circle(iG) and Polygone(iG) <= FCircle(iG)) and then (Polygone(iR) <= PolyLine(iR) and Polygone(iR) <= Line(iR) and Polygone(iR) <= Circle(iR) and Polygone(iR) <= FCircle(iR)) then 
		   
		   return Polygone;

	   elsif (Circle(iA) /= 0) and then (Circle(iB) <= PolyLine(iB) and Circle(iB) <= Line(iB) and Circle(iB) <= Polygone(iB) and Circle(iB) <= FCircle(iB)) and then (Circle(iG) <= PolyLine(iG) and Circle(iG) <= Line(iG) and Circle(iG) <= Polygone(iG) and Circle(iG) <= FCircle(iG)) and then (Circle(iR) <= PolyLine(iR) and Circle(iR) <= Line(iR) and Circle(iR) <= Polygone(iR) and Circle(iR) <= FCircle(iR)) then
		   
		  return Circle;

	   else

		  return FCircle; 


	   end if;
	   end lowestPriority;


   procedure RedrawWindow(	Window		: ImagePtr;
							TabObj		: Nirvana;
							Clipper		: RectanglePtr := null) is
							-- Procedure to draw the background (canvas) and all the object we have created, normally called with a rectangular window for clipping.

		pPixel	: PixelPtr	:= Window.basePixel;
		PCour	: PointPtr;
		CurrLine, CurrPolyline, CurrPolygone, CurrCircle, CurrCircleF	: ShapePtr;
		lowestPrio, LinePrio, PolyLinePrio,PolygonePrio, CirclePrio, CircleFPrio : Pixel;
		nullPrio		: Pixel			:= (255, 255, 255, 255);
		iR, iG, iB, iA	: integer;
   begin
	   -- Draw the "Canvas" (Background)
	   iR := Window.iR;
	   iG := Window.iG;
	   iB := Window.iB;
	   iA := window.iA;
	   nullPrio(iA) := 0;
	   CurrPolygone := TabObj(Canvas);
	   while CurrPolygone /= null loop
		   PCour := CurrPolygone.PStart;
		   Polygone(Window, PCour, CurrPolygone.Color, Clipper);
		   CurrPolygone := CurrPolygone.next;
	   end loop;

	   -- Redraw all objects in order of priority (Identifier)
	   CurrLine := TabObj(Line);
	   CurrPolyLine := TabObj(Polyline);
	   CurrPolygone := TabObj(Polygone);
	   CurrCircle	:= TabObj(Circle);
	   CurrCircleF	:= TabObj(FilledCircle);
	   PCour := null;

	   while not (CurrLine = null and CurrPolyLine = null and CurrPolygone = null and currCircle = null and CurrCircleF = null) loop
		   -- When one of our pointers does not point anywhere (it is null)
		   -- give it an identifier > any other identifier
		   if CurrLine = null then
			   LinePrio := nullPrio;
		   else
			   LinePrio := CurrLine.Identifier;
		   end if;
		  
		   if CurrPolyLine = null then
			   PolyLinePrio := nullPrio;
		   else
			   PolyLinePrio := CurrPolyLine.Identifier;
		   end if;
		  
		   if CurrPolygone = null then
			   PolygonePrio := nullPrio;
		   else
			   PolygonePrio := CurrPolygone.Identifier;
		   end if;
		  
		   if CurrCircle = null then
			   CirclePrio := nullPrio;
		   else
			   CirclePrio := CurrCircle.Identifier;
		   end if;
		  
		   if CurrCircleF = null then
			   CircleFPrio := nullPrio;
		   else
			   CircleFPrio := CurrCircleF.Identifier;
		   end if;


		   lowestPrio := lowestPriority(LinePrio, PolyLinePrio, PolygonePrio, CirclePrio, CircleFPrio, iR, iG, iB, iA);

		   if LinePrio(iA) /= 0 and then LinePrio = lowestPrio then
			   PCour := CurrLine.PStart;
			   DrawLine(Window, PCour, CurrLine.Color, Clipper);
			   CurrLine := CurrLine.next;
		   elsif PolylinePrio(iA) /= 0 and then PolyLinePrio = lowestPrio then
			   PCour :=CurrPolyLine.PStart;
			   Polyline(Window, PCour, CurrPolyLine.Color, Clipper);
			   CurrPolyLine := CurrPolyLine.next;
		   elsif PolygonePrio(iA) /= 0 and then PolygonePrio = lowestPrio then
			   PCour :=CurrPolygone.PStart;
			   Polygone(Window, PCour, CurrPolygone.Color, Clipper);
			   CurrPolygone := CurrPolygone.next;
		   elsif CirclePrio(iA) /= 0 and then CirclePrio = lowestPrio then
			   Cercle(Window, CurrCircle.PStart, CurrCircle.Pstart.Next, CurrCircle.Color);
			   CurrCircle := CurrCircle.next;
		   elsif CircleFPrio(iA) /= 0 and then CircleFPrio = lowestPrio then
			   CercleRempli(Window, CurrCircleF.Pstart, CurrCircleF.PStart.next, CurrCircleF.Color, Clipper);
			   CurrCircleF := CurrCircleF.next;

		   end if;


	   end loop;
   end RedrawWindow;

  procedure RedrawOffscreen(Window		: ImagePtr;
							TabObj		: Nirvana;
							Clipper		: RectanglePtr := null) is
							-- Procedure to redraw the offscreen and all the objects we have created, normally called with a Rectangular window for Clipping, the "color" in the offscreen is an objects priority and identifier

		pPixel	: PixelPtr	:= Window.basePixel;
		PCour	: PointPtr;
		CurrLine, CurrPolyline, CurrPolygone, CurrCircle, CurrCircleF	: ShapePtr;
		lowestPrio, LinePrio, PolyLinePrio,PolygonePrio, CirclePrio, CircleFPrio : Pixel;
		nullPrio	: Pixel		:= (255, 255, 255, 255);
		iR, iG, iB, iA	: Integer;
   begin
	   -- Draw the "Canvas" (Background)

	   iR := Window.iR;
	   iG := Window.iG;
	   iB := Window.iB;
	   iA := window.iA;
	   nullPrio(iA) := 0;
	   CurrPolygone := TabObj(Canvas);
	   while CurrPolygone /= null loop
		   Polygone(Window, CurrPolygone.Pstart, CurrPolygone.Identifier, Clipper);
		   CurrPolygone := CurrPolygone.next;
	   end loop;

	   -- Redraw all objects in order of priority (Identifier)
	   CurrLine := TabObj(Line);
	   CurrPolyLine := TabObj(Polyline);
	   CurrPolygone := TabObj(Polygone);
	   CurrCircle	:= TabObj(Circle);
	   CurrCircleF	:= TabObj(FilledCircle);
	   PCour := null;

	   while not (CurrLine = null and CurrPolyLine = null and CurrPolygone = null and CurrCircle = null and CurrCircleF = null) loop
		   -- When one of our pointers does not point anywhere (it is null)
		   -- give it an identifier > any other identifier
		   if CurrLine = null then
			   LinePrio := nullPrio;
		   else
			   LinePrio := CurrLine.Identifier;
		   end if;
		  
		   if CurrPolyLine = null then
			   PolyLinePrio := nullPrio;
		   else
			   PolyLinePrio := CurrPolyLine.Identifier;
		   end if;
		  
		   if CurrPolygone = null then
			   PolygonePrio := nullPrio;
		   else
			   PolygonePrio := CurrPolygone.Identifier;
		   end if;
		  
		   if CurrCircle = null then
			   CirclePrio := nullPrio;
		   else
			   CirclePrio := CurrCircle.Identifier;
		   end if;
		  
		   if CurrCircleF = null then
			   CircleFPrio := nullPrio;
		   else
			   CircleFPrio := CurrCircleF.Identifier;
		   end if;



		   lowestPrio := lowestPriority(LinePrio, PolyLinePrio, PolygonePrio, CirclePrio, CircleFPrio, iR, iG, iB, iA);

		   if LinePrio = lowestPrio then
			   PCour := CurrLine.PStart;
			   DrawLine(Window, PCour, CurrLine.Identifier, Clipper);
			   CurrLine := CurrLine.next;
		   elsif PolyLinePrio = lowestPrio then
			   PCour :=CurrPolyLine.PStart;
			   Polyline(Window, PCour, CurrPolyLine.Identifier, Clipper);
			   CurrPolyLine := CurrPolyLine.next;
		   elsif PolygonePrio = lowestPrio then
			   PCour :=CurrPolygone.PStart;
			   Polygone(Window, PCour, CurrPolygone.Identifier, Clipper);
			   CurrPolygone := CurrPolygone.next;
		   elsif CirclePrio = lowestPrio then
			   Cercle(Window, CurrCircle.PStart, CurrCircle.Pstart.Next, CurrCircle.Identifier);
			   CurrCircle := CurrCircle.next;
		   elsif CircleFPrio = lowestPrio then
			   CercleRempli(Window, CurrCircleF.Pstart, CurrCircleF.PStart.next, CurrCircleF.Identifier, Clipper);
			   CurrCircleF := CurrCircleF.next;
		   end if;


	   end loop;
   end RedrawOffscreen;


   procedure findShape(Id: PixelPtr; Scene: Nirvana; res: out ShapePtr) is
	   -- Locate an object with Identifier Id in the Scene.
	   -- Return the object when found
	   -- If no object with Identifier = Id is found return Null
	   Curr: ShapePtr;
   begin
	   -- Loop through all the object in the scene.
	   for i in Line..FilledCircle loop
		   Curr := Scene(i);
		   while curr /= null loop
			   if Curr.Identifier = Id.all then
				   -- Object found, return object!
				   res := Curr;
				   return;
			   end if;
			   Curr := Curr.next;
		   end loop;
	   end loop;
	   -- no object was found
	   res := null;
   end findShape;

   procedure CheckShape(offscreenImage: ImagePtr; x,y: integer; Zen : Nirvana; res : out ShapePtr) is
	   -- Simple procedure for using findShape.
	   pPtr : pixelPtr;
   begin	   
	   -- Locate the Identifier of the object we clicked and call findShape.
	   pPtr:= offscreenImage.basePixel + ptrdiff_t (offscreenImage.width * y + x);
	   findShape(pPtr, Zen, res); 
		
   end CheckShape;

   procedure eraseShape(id : PixelPtr; Scene : in out Nirvana; Obj : out ShapePtr; erase : Boolean := true) is
	   -- Function to either remove or erase a shape from the scene
	   -- Res = null if no object to remove/delete was found

	   Prec, Curr, Next	: ShapePtr;
   begin
	   -- Loop through all the object in the scene.
	   for i in Line..FilledCircle loop
		   Curr := Scene(i);
		   Prec := null;
		   while curr /= null loop
			   Next := Curr.next;
			   if Curr.Identifier = Id.all then
				   -- Object found, return object!
				   Obj := Curr;
				   Obj.next := null;
				   if Prec = null then
					   -- First shape in the list is to be removed
					   Scene(i) := next;
				   else
					   Prec.next := next;
				   end if;
				   if erase then
					   free(curr);
				   end if;

				   return;
			   end if;
			   Prec := Curr;
			   Curr := Next;
		   end loop;
	   end loop;
	   -- no object was found nothing to do
   end eraseShape;

   procedure RemoveShape(offscreenImage: ImagePtr; x,y : Integer; Zen: in out nirvana; res : out ShapePtr; erase : Boolean := True) is
	   -- Function to simplify the calling of eraseShape
	  	   pPtr	: PixelPtr;
   begin
	   pPtr:= offscreenImage.basePixel + ptrdiff_t (offscreenImage.width * y + x);
	   eraseShape(pPtr, Zen, Res, erase);
   end RemoveShape; 

   procedure increasePrio (prio: in out pixel; iR, iG, iB, iA : Integer) is
   begin
	   if prio(iR) /= 255 then
		   prio(iR) := prio(iR) + 1;
	   else
		   if prio(iG) /= 255 then
			   prio(iR) := 0;
			   prio(iG) := prio(iG) + 1;
		   else
			   if prio(iB) /= 255 then
				   prio(iG) := 0;
				   prio(iB) := prio(iB) + 1; 
			   else
				   put_line("The Scene is full, God knows what happens if you enter another object");
			   end if;
		   end if;
	   end if;
   end increasePrio;

   procedure resortPrio(scene: in out nirvana; iR, iG, iB, iA : integer ; MaxPrio : out Pixel) is
	   -- Resets all priorities eliminating all possible "holes" amongst the identifiers
	   -- Returns the new maxPrio (one higher than the highest priority in the Scene)
	   currLine, currPolyline, currPolygone, CurrCircle, CurrCircleF	: ShapePtr;
	   lowestPrio, linePrio, polylinePrio, polygonePrio, CirclePrio, CircleFPrio	: Pixel;
	   nullPrio : Pixel := (255, 255, 255, 255);
   begin
	   maxPrio := (0, 0, 0, 0);
	   nullPrio(iA) := 0;
	   CurrLine := scene(Line);
	   CurrPolyLine := scene(Polyline);
	   CurrPolygone := scene(Polygone);
	   CurrCircle	:= Scene(Circle);
	   CurrCircleF	:= Scene(FilledCircle);

	   if currline = null then
		   linePrio := nullprio;
	   else
		   linePrio := currLine.Identifier;
	   end if;
	   if currPolyline = null then
		   polylinePrio := nullprio;
	   else
		   polylinePrio := currPolyline.Identifier;
	   end if;
	   if currPolygone = null then
		   polygonePrio := nullPrio;
	   else
		   polygonePrio := currPolygone.Identifier;
	   end if;
	   if CurrCircle = null then
		   CirclePrio := nullPrio;
	   else
		   CirclePrio := CurrCircle.Identifier;
	   end if;
	   if CurrCircleF = null then
		   CircleFPrio := nullPrio;
	   else
		   CircleFPrio := CurrCircleF.Identifier;
	   end if;
	   maxPrio(iA) := 255;
	   maxPrio(iR) := 1;
	   
	   while not (CurrLine = null and CurrPolyLine = null and CurrPolygone = null and currCircle = null and currCircleF = null) loop
		   -- When one of our pointers does not point anywhere (it is null)
		   -- give it an identifier > any other identifier and an alpha value of 0
		   if CurrLine = null then
			   LinePrio := nullPrio;
		   else
			   LinePrio := CurrLine.Identifier;
		   end if;
		  
		   if CurrPolyLine = null then
			   PolyLinePrio := nullPrio;
		   else
			   PolyLinePrio := CurrPolyLine.Identifier;
		   end if;
		  
		   if CurrPolygone = null then
			   PolygonePrio := nullPrio;
		   else
			   PolygonePrio := CurrPolygone.Identifier;
		   end if;

		   if CurrCircle = null then
			   CirclePrio := nullPrio;
		   else
			   CirclePrio := CurrCircle.Identifier;
		   end if;
		  
		   if CurrCircleF = null then
			   CircleFPrio := nullPrio;
		   else
			   CircleFPrio := CurrCircleF.Identifier;
		   end if;

		   -- Find the lowest priority 
		   lowestPrio := lowestPriority(LinePrio, polylinePrio, polygonePrio, CirclePrio, CircleFPrio, iR, iG, iB, iA);
		   -- Treat the lowest priority (update the identifier) object
		   if LinePrio(iA) /= 0 and then LinePrio = lowestPrio then
			   CurrLine.Identifier := maxPrio;
			   increasePrio(maxPrio, iR, iG, iB, iA);
			   CurrLine := CurrLine.next;
		   elsif PolylinePrio(iA)/= 0 and then PolyLinePrio = lowestPrio then
			   currPolyline.Identifier := maxprio;
			   increasePrio(maxPrio, iR, iG, iB, iA);
			   CurrPolyLine := CurrPolyLine.next;
		   elsif polygonePrio(iA) /= 0 and then PolygonePrio = lowestPrio then
			   currPolygone.Identifier := maxPrio;
			   increasePrio(maxPrio, iR, iG, iB, iA);
			   CurrPolygone := CurrPolygone.next;
		   elsif CirclePrio(iA) /= 0 and then CirclePrio = lowestPrio then
			   CurrCircle.Identifier := maxPrio;
			   increasePrio(maxPrio, iR, iG, iB, iA);
			   currCircle := currCircle.next;
		   elsif CircleFPrio(iA) /= 0 and then CircleFPrio = lowestPrio then
			   CurrCircleF.Identifier := maxPrio;
			   increasePrio(maxPrio, iR, iG, iB, iA);
			   currCircleF := currCircleF.next;
		   end if;
	   end loop;
   end resortPrio;

function ObjectType(id : PixelPtr; scene : Nirvana) return OBJECT is
	-- Returns the Object type of a shape, using it's identifier
	-- Returns Canvas if no matching objectwas found

 Curr: ShapePtr;
begin
	   -- Loop through all the object in the scene.
	   for i in Line..FilledCircle loop
		   Curr := Scene(i);
		   while curr /= null loop
			   if Curr.Identifier = Id.all then
				   -- Object found, return object!
				   return i;
			   end if;
			   Curr := Curr.next;
		   end loop;
	   end loop;
	   -- no object was found
	return Canvas;
end ObjectType;

function whatObject(offscreenImage: ImagePtr; x,y : Integer; Zen: nirvana) return OBJECT is
	-- Simple procedure to get an objects identifier and the call ObjectType
	pPtr : PixelPtr;
	res : OBJECT;
begin
	 pPtr:= offscreenImage.basePixel + ptrdiff_t (offscreenImage.width * y + x);
	 res := ObjectType(pPtr, Zen);
	 return res;
end whatObject;


procedure DrawToolglass(MyImagePtr : ImagePtr; mousex, mousey : Integer; iR, iG, iB, iA : Integer; Clipper : RectanglePtr := null)is
	-- Procedure to draw the toolglass on the screen
	Tool1, Tool2, Tool3, Tool4,Tool5 : PointPtr := new point;
	width : Integer := MyImagePtr.width;
	height : Integer := MyImagePtr.height;
	Black, Green, Red, Blue	: Pixel := (0,0,0,0);
begin
	if iA /= -1 then
		Black(iA)	:= 128;
		Green(iA)	:= 128;
		Red(iA)		:= 128;
		Blue(iA)	:= 128;
	end if;
	Red(iR)		:= 255;
	Green(iG)	:= 255;
	Blue(iB)	:= 255;

	-- Draw the big rectangle surrounding the toolglass
			Tool5.all:= (Mousex,Min(Height,Mousey),null) ;
            Tool4.all:= (Mousex,Min(Height,Mousey+160),Tool5) ;
            Tool3.all:= (Mousex+80,Min(Height,Mousey+160),Tool4) ;
            Tool2.all:= (Mousex+80,Min(Height,Mousey),Tool3) ;
            Tool1.all:= (Mousex,Min(Height,Mousey),Tool2) ;
            Polyline(MyImagePtr,Tool1,black, Clipper) ;

			-- Draw the Drawline button
            DrawLine(MyImagePtr,new point'(Mousex+5,Min(Height,Mousey+35), new point'(Mousex+35,Min(Height,Mousey+5), null)),black, Clipper) ;

			-- Draw the polyline button
            Tool3.all:= (Mousex+45,Min(Height,Mousey+18),null) ;
            Tool2.all:= (Mousex+53,Min(Height,Mousey+10),Tool3) ;
            Tool1.all:= (Mousex+75,Min(Height,Mousey+35),Tool2) ;
            Polyline(MyImagePtr,Tool1 ,Black, Clipper) ;
            
			-- Draw the circle button
			if Mousey+75 <= Height then
				Tool1.all := (Mousex+20,Mousey+60, null);
				Tool2.all := (mousex + 35, mousey + 60, null);
               Cercle(MyImagePtr, Tool1, Tool2, black) ;
            end if ;

			-- Draw the filled circle button
            if Mousey+115 <= Height then
				Tool1.all := (Mousex+20,Mousey+100, null);
				Tool2.all := (mousex + 35, mousey + 100, null);
               CercleRempli(MyImagePtr, Tool1, Tool2, black, Clipper) ;
            end if ;

			-- Draw the polygon button
            Tool4.all:= (Mousex+45,Min(Height,Mousey+50),null) ;
            Tool3.all:= (Mousex+75,Min(Height,Mousey+50),Tool4) ;
            Tool2.all:= (Mousex+75,Min(Height,Mousey+70),Tool3) ;
            Tool1.all:= (Mousex+45,Min(Height,Mousey+70),Tool2) ;
            Polygone(MyImagePtr,Tool1, black, Clipper) ;

			-- Draw the Table of colors button
			Tool2.all := (Mousex+60,Min(Height,Mousey+120), null);
			Tool1.all := (Mousex+60,Min(Height,Mousey+80), Tool2);
            Drawline(MyImagePtr, Tool1, black, Clipper) ;
			
			Tool2.all := (Mousex+80,Min(Height,Mousey+100), null);
			Tool1.all := (Mousex+40,Min(Height,Mousey+100), Tool2);
            Drawline(MyImagePtr, Tool1, black, Clipper) ;

			-- Draw the small, colored squares
            Tool4.all:= (Mousex+43,Min(Height,Mousey+83),null) ;
            Tool3.all:= (Mousex+57,Min(Height,Mousey+83),Tool4) ;
            Tool2.all:= (Mousex+57,Min(Height,Mousey+97),Tool3) ;
            Tool1.all:= (Mousex+43,Min(Height,Mousey+97),Tool2) ;
            Polygone(MyImagePtr,Tool1,Red, Clipper) ;
            Tool4.all:= (Mousex+63,Min(Height,Mousey+83),null) ;
            Tool3.all:= (Mousex+77,Min(Height,Mousey+83),Tool4) ;
            Tool2.all:= (Mousex+77,Min(Height,Mousey+97),Tool3) ;
            Tool1.all:= (Mousex+63,Min(Height,Mousey+97),Tool2) ;
            Polygone(MyImagePtr,Tool1,green, Clipper) ;
            Tool4.all:= (Mousex+63,Min(Height,Mousey+103),null) ;
            Tool3.all:= (Mousex+77,Min(Height,Mousey+103),Tool4) ;
            Tool2.all:= (Mousex+77,Min(Height,Mousey+117),Tool3) ;
            Tool1.all:= (Mousex+63,Min(Height,Mousey+117),Tool2) ;
            Polygone(MyImagePtr,Tool1,black, Clipper) ;
            Tool4.all:= (Mousex+43,Min(Height,Mousey+103),null) ;
            Tool3.all:= (Mousex+57,Min(Height,Mousey+103),Tool4) ;
            Tool2.all:= (Mousex+57,Min(Height,Mousey+117),Tool3) ;
            Tool1.all:= (Mousex+43,Min(Height,Mousey+117),Tool2) ;
            Polygone(MyImagePtr,Tool1,blue, Clipper) ;
			

			-- Draw the erase button
			Tool2.all := (Mousex+35,Min(Height,Mousey+155), null);
			Tool1.all := (Mousex+5,Min(Height,Mousey+125), Tool2);
            Drawline(MyImagePtr,Tool1, Red, Clipper) ;
			
			Tool2.all := (Mousex+35,Min(Height,Mousey+125), null);
			Tool1.all := (Mousex+5,Min(Height,Mousey+155), Tool2);
            Drawline(MyImagePtr,Tool1, Red, Clipper) ;


			-- Draw the increase priority button
			Tool2.all := (Mousex+60,Min(Height,Mousey+155), null);
			Tool1.all := (Mousex+60,Min(Height,Mousey+125), Tool2);
            Drawline(MyImagePtr, Tool1, Black, Clipper) ;

			Tool2.all := (Mousex+50,Min(Height,Mousey+135), null);
			Tool1.all := (Mousex+60,Min(Height,Mousey+125), Tool2);
            Drawline(MyImagePtr, Tool1, black, clipper) ;

            Tool2.all := (Mousex+70,Min(Height,Mousey+135), null);
			Tool1.all := (Mousex+60,Min(Height,Mousey+125), Tool2);
			Drawline(MyImagePtr, Tool1, black, Clipper) ;

			-- Draw all the separating lines between the buttons
			Tool2.all := (Mousex+40,Min(Height,Mousey+160), null);
			Tool1.all := (Mousex+40,Min(Height,Mousey), Tool2);
			DrawLine(MyImagePtr, Tool1, black, Clipper) ;

			Tool2.all := (Mousex+80,Min(Height,Mousey+40), null);
			Tool1.all := (Mousex,Min(Height,Mousey+40), Tool2);
		   	DrawLine(MyImagePtr, Tool1, black, Clipper) ;

            Tool2.all := (Mousex+80,Min(Height,Mousey+80), null);
			Tool1.all := (Mousex,Min(Height,Mousey+80), Tool2);
			DrawLine(MyImagePtr, Tool1, black, Clipper) ;

            Tool2.all := (Mousex+80,Min(Height,Mousey+120), null);
			Tool1.all := (Mousex,Min(Height,Mousey+120), Tool2);
		   	DrawLine(MyImagePtr, Tool1, black, Clipper) ;

			Tool2.next := Tool3;
			Tool4.next := Tool5;

			erasePoints(Tool1);
-- 			erasePoints(Tool8);
-- 			erasePoints(Tool12);
-- 			erasePoints(Tool16);
-- 			erasePoints(Tool20);
-- 			erasePoints(Tool24);
-- 			erasePoints(Tool28);
-- 
end DrawToolglass;

procedure DrawColorTable(MyImagePtr : ImagePtr; mousex, mousey : Integer; iR, iG, iB, iA : Integer; Clipper : RectanglePtr := null) is
	-- Procdure to draw the table of colors on the screen
	Tabcolor1, TabColor2, TabColor3, TabColor4, TabColor5 : PointPtr := new point;
	height : Integer := MyImagePtr.height;
	width : Integer := MyImagePtr.width;
	Red, Green, Blue, Black, Yellow, White : Pixel := (0, 0, 0, 0);


begin
	if iA /= -1 then
		Red(iA) := 128;
		Green(iA) := 128;
		Blue(iA) := 128;
		Yellow(iA)	:= 128;
		White(iA)	:= 128;
		Black(iA) := 128;
	end if;
	red(iR) := 255;
	Yellow(iR) := 255;
	White(iR) := 255;
	Green(iG) := 255;
	Yellow(iG) := 255;
	White(iG) := 255;
	Blue(iB) := 255;
	White(iB) := 255;

			-- Draw the Rectangle containing the table of colors
			Tabcolor5.all:= (Mousex,Min(Height,Mousey),null) ;
            Tabcolor4.all:= (Mousex+80,Min(Height,Mousey),Tabcolor5) ;
            Tabcolor3.all:= (Mousex+80,Min(Height,Mousey+120),Tabcolor4) ;
            Tabcolor2.all:= (Mousex,Min(Height,Mousey+120),Tabcolor3) ;
            Tabcolor1.all:= (Mousex,Min(Height,Mousey),Tabcolor2) ;
            Polyline(MyImagePtr,Tabcolor1,black, Clipper) ;

			-- Draw the red button
            Tabcolor4.all:= (Mousex+5,Min(Height,Mousey+5),null) ;
            Tabcolor3.all:= (Mousex+35,Min(Height,Mousey+5),Tabcolor4) ;
            Tabcolor2.all:= (Mousex+35,Min(Height,Mousey+35),Tabcolor3) ;
            Tabcolor1.all:= (Mousex+5,Min(Height,Mousey+35),Tabcolor2) ;
            Polygone(MyImagePtr,Tabcolor1,Red, Clipper) ;

			-- Draw the green button
            Tabcolor4.all:= (Mousex+45,Min(Height,Mousey+5),null) ;
            Tabcolor3.all:= (Mousex+75,Min(Height,Mousey+5),Tabcolor4) ;
            Tabcolor2.all:= (Mousex+75,Min(Height,Mousey+35),Tabcolor3) ;
            Tabcolor1.all:= (Mousex+45,Min(Height,Mousey+35),Tabcolor2) ;
            Polygone(MyImagePtr,Tabcolor1,green, Clipper) ;

			-- Draw the black button
            Tabcolor4.all:= (Mousex+45,Min(Height,Mousey+45),null) ;
            Tabcolor3.all:= (Mousex+75,Min(Height,Mousey+45),Tabcolor4) ;
            Tabcolor2.all:= (Mousex+75,Min(Height,Mousey+75),Tabcolor3) ;
            Tabcolor1.all:= (Mousex+45,Min(Height,Mousey+75),Tabcolor2) ;
            Polygone(MyImagePtr,Tabcolor1,black, Clipper) ;

			-- Draw the Blue button
            Tabcolor4.all:= (Mousex+5,Min(Height,Mousey+45),null) ;
            Tabcolor3.all:= (Mousex+35,Min(Height,Mousey+45),Tabcolor4) ;
            Tabcolor2.all:= (Mousex+35,Min(Height,Mousey+75),Tabcolor3) ;
            Tabcolor1.all:= (Mousex+5,Min(Height,Mousey+75),Tabcolor2) ;
            Polygone(MyImagePtr,Tabcolor1,blue, Clipper) ;

			-- Draw the Yellow button
			Tabcolor4.all:= (Mousex+5,Min(Height,Mousey+85),null) ;
            Tabcolor3.all:= (Mousex+35,Min(Height,Mousey+85),Tabcolor4) ;
            Tabcolor2.all:= (Mousex+35,Min(Height,Mousey+115),Tabcolor3) ;
            Tabcolor1.all:= (Mousex+5,Min(Height,Mousey+115),Tabcolor2) ;
            Polygone(MyImagePtr,Tabcolor1, Yellow, Clipper) ;

			-- Draw the white button
			Tabcolor4.all:= (Mousex+45,Min(Height,Mousey+85),null) ;
            Tabcolor3.all:= (Mousex+75,Min(Height,Mousey+85),Tabcolor4) ;
            Tabcolor2.all:= (Mousex+75,Min(Height,Mousey+115),Tabcolor3) ;
            Tabcolor1.all:= (Mousex+45,Min(Height,Mousey+115),Tabcolor2) ;
            Polygone(MyImagePtr,Tabcolor1, White, Clipper) ;




			-- Draw the separating lines between all the buttons

			TabColor2.all := (Mousex+40,Min(Height,Mousey+120), null);
			TabColor1.all := (Mousex+40,Min(Height,Mousey), TabColor2);
			Drawline(MyImagePtr, TabColor1, black, Clipper) ;

            TabColor2.all := (Mousex+80,Min(Height,Mousey+40), null);
			TabColor1.all := (Mousex,Min(Height,Mousey+40), TabColor2);
			Drawline(MyImagePtr,TabColor1, black, Clipper) ;


		   	TabColor2.all := (Mousex+80,Min(Height,Mousey+80), null);
			TabColor1.all := (Mousex,Min(Height,Mousey+80), TabColor2);
            Drawline(MyImagePtr, TabColor1, black, Clipper) ;

			TabColor2.next := TabColor3;
			TabColor4.next := TabColor5;

			erasePoints(Tabcolor1);
end DrawColorTable;


end Event_Handling;
