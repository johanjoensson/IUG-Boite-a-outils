with Ada_SDL_Video,Ada.Unchecked_Deallocation, Interfaces.C, Gr_Shapes, Drawline_Pkg, Aux_Fct, Ada.Text_Io;
use Ada_SDL_Video, Ada_SDL_Video.PixelPtrPkg, Interfaces.C, Gr_Shapes, Drawline_Pkg, Aux_Fct, Ada.Text_Io;

package body Event_Handling is

	procedure free is new Ada.Unchecked_Deallocation (Shape, ShapePtr);
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

	   function lowestPriority(Line, Polyline, Polygone : pixel; iR, iG, iB, iA : Integer) return pixel is
		   -- Return the lowest priority of the three entered.
		   -- Requires: All Identifiers are unique.
	   begin
 
		   if (Line(iA) /= 0) and then (Line(iB) < Polygone(iB) and Line(iB) < Polyline(iB)) and then (Line(iG) < Polygone(iG) and Line(iG) < Polyline(iG)) and then (Line(iR) < Polygone(iR) and Line(iR) < Polyline(iR)) then 

		   return Line;

	   elsif (PolyLine(iA)/= 0) and then (PolyLine(iB) < Polygone(iB) and PolyLine(iB) < Line(iB)) and then (PolyLine(iG) < Polygone(iG) and PolyLine(iG) < Line(iG)) and then (PolyLine(iR) < Polygone(iR) and PolyLine(iR) < Line(iR)) then 

		   return PolyLine;

	   else

		   return Polygone;

	   end if;
	   end lowestPriority;


   procedure RedrawWindow(	Window		: ImagePtr;
							TabObj		: Nirvana;
							Clipper		: RectanglePtr) is

		pPixel	: PixelPtr	:= Window.basePixel;
		PCour	: PointPtr;
		CurrLine, CurrPolyline, CurrPolygone	: ShapePtr;
		lowestPrio, LinePrio, PolyLinePrio,PolygonePrio : Pixel;
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
	   PCour := null;

	   while not (CurrLine = null and CurrPolyLine = null and CurrPolygone = null) loop
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

		   lowestPrio := lowestPriority(LinePrio, PolyLinePrio, PolygonePrio, iR, iG, iB, iA);

		   if LinePrio = lowestPrio then
			   PCour := CurrLine.PStart;
			   DrawLine(Window, PCour, CurrLine.Color, Clipper);
			   CurrLine := CurrLine.next;
		   elsif PolyLinePrio = lowestPrio then
			   PCour :=CurrPolyLine.PStart;
			   Polyline(Window, PCour, CurrPolyLine.Color, Clipper);
			   CurrPolyLine := CurrPolyLine.next;
		   elsif PolygonePrio = lowestPrio then
			   PCour :=CurrPolygone.PStart;
			   Polygone(Window, PCour, CurrPolygone.Color, Clipper);
			   CurrPolygone := CurrPolygone.next;
		   end if;


	   end loop;
   end RedrawWindow;

  procedure RedrawOffscreen(Window		: ImagePtr;
							TabObj		: Nirvana;
							Clipper		: RectanglePtr) is

		pPixel	: PixelPtr	:= Window.basePixel;
		PCour	: PointPtr;
		CurrLine, CurrPolyline, CurrPolygone	: ShapePtr;
		lowestPrio, LinePrio, PolyLinePrio,PolygonePrio : Pixel;
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
	   PCour := null;

	   while not (CurrLine = null and CurrPolyLine = null and CurrPolygone = null) loop
		   -- When one of our pointers does not point anywhere (it is null)
		   -- give it an identifier > any other identifier
--		   Put_line("Loop!!!");
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

		   lowestPrio := lowestPriority(LinePrio, PolyLinePrio, PolygonePrio, iR, iG, iB, iA);

		   if LinePrio = lowestPrio then
--			   put_line(" Linje ");
			   PCour := CurrLine.PStart;
			   DrawLine(Window, PCour, CurrLine.Identifier, Clipper);
			   CurrLine := CurrLine.next;
		   elsif PolyLinePrio = lowestPrio then
--			   put_line(" Polylinje ");
			   PCour :=CurrPolyLine.PStart;
			   Polyline(Window, PCour, CurrPolyLine.Identifier, Clipper);
			   CurrPolyLine := CurrPolyLine.next;
		   elsif PolygonePrio = lowestPrio then
--			   put_line(" Polygon ");
			   PCour :=CurrPolygone.PStart;
			   Polygone(Window, PCour, CurrPolygone.Identifier, Clipper);
			   CurrPolygone := CurrPolygone.next;
		   else
			   Put_line(" HELVETE!!!!! ");
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
	   for i in Line..Polygone loop
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

   procedure CheckShape(offscreenImage: ImagePtr; x,y: integer; Zen : in out Nirvana; res : out ShapePtr) is
	   -- Simple procedure for testing findShape
	   pPtr : pixelPtr;
   begin

         pPtr:= offscreenImage.basePixel + ptrdiff_t (offscreenImage.width * y + x);
	   findShape(pPtr, Zen, res); 
		 if res /= null then
			 --put("Korrekt!");
			 put_line(integer'image(integer(res.color(0))) & " :" & integer'image(integer(res.color(1))) & " :" & integer'image(integer(res.color(2)))& " :" & integer'image(integer(res.color(3))));
		 else
			 --put("Inte korrekt!");
			 put_line(integer'image(integer(pPtr.all(0))) & " :" & integer'image(integer(pPtr.all(1))) & " :" & integer'image(integer(pPtr.all(2))));
		 end if;
   end CheckShape;

   procedure eraseShape(id : PixelPtr; Scene : in out Nirvana; Obj : out ShapePtr) is
	   Prec, Curr, Next	: ShapePtr;
   begin
	   -- Loop through all the object in the scene.
	   for i in Line..Polygone loop
		   Curr := Scene(i);
		   while curr /= null loop
			   Next := Curr.next;
			   if Curr.Identifier = Id.all then
				   -- Object found, return object!
				   Obj := Curr;
				   free(Curr);
				   if Prec = null then
					   -- First shape in the list is to be removed
					   Scene(i) := next;
				   else
					   Prec.next := next;
				   end if;
				   return;
			   end if;
			   Prec := Curr;
			   Curr := Next;
		   end loop;
	   end loop;
	   -- no object was found nothing to do
   end eraseShape;

   procedure RemoveShape(offscreenImage: ImagePtr; x,y : Integer; Zen: in out nirvana) is
	   pPtr	: PixelPtr;
	   res	: ShapePtr;
   begin
	   pPtr:= offscreenImage.basePixel + ptrdiff_t (offscreenImage.width * y + x);
	   eraseShape(pPtr, Zen, Res);
	   findShape(pPtr, Zen, Res);
	   if res = null then
		   put_line("Misslyckat!");
	   else
		   put_line("Tog bort figuren!");
	   end if;
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
				   put_line("listan är full");
			   end if;
		   end if;
	   end if;
   end increasePrio;

   procedure resortPrio(scene: in out nirvana; iR, iG, iB, iA : integer) is
	   maxPrio	: Pixel := (0, 0, 0, 0);
	   currLine, currPolyline, currPolygone	: ShapePtr;
	   lowestPrio, linePrio, polylinePrio, polygonePrio	: Pixel;
	   nullPrio : Pixel := (255, 255, 255, 255);
   begin
	   nullPrio(iA) := 0;
	   CurrLine := scene(Line);
	   CurrPolyLine := scene(Polyline);
	   CurrPolygone := scene(Polygone);

	   linePrio := currLine.Identifier;
	   polylinePrio := currPolyline.Identifier;
	   polygonePrio := currPolygone.Identifier;
	   maxPrio(iA) := 255;
	   
	   while not (CurrLine = null and CurrPolyLine = null and CurrPolygone = null) loop
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

		   lowestPrio := lowestPriority(LinePrio, polylinePrio, polygonePrio, iR, iG, iB, iA);
 	   if LinePrio = lowestPrio then
		   CurrLine.Identifier := maxPrio;
		   increasePrio(maxPrio, iR, iG, iB, iA);
		   CurrLine := CurrLine.next;
 		   elsif PolyLinePrio = lowestPrio then
			   currPolyline.Identifier := maxprio;
			   increasePrio(maxPrio, iR, iG, iB, iA);
 			   CurrPolyLine := CurrPolyLine.next;
 		   elsif PolygonePrio = lowestPrio then
			   currPolygone.Identifier := maxPrio;
			   increasePrio(maxPrio, iR, iG, iB, iA);
 			   CurrPolygone := CurrPolygone.next;
 		   else
 			   Put_line(" HELVETE!!!!! ");
 		   end if;
	   end loop;
 
   end resortPrio;

end Event_Handling;
