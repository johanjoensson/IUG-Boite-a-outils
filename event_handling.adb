with Ada_SDL_Video, Interfaces.C, Gr_Shapes, Drawline_Pkg, Aux_Fct, Ada.Text_Io;
use Ada_SDL_Video, Ada_SDL_Video.PixelPtrPkg, Interfaces.C, Gr_Shapes, Drawline_Pkg, Aux_Fct, Ada.Text_Io;

package body Event_Handling is

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
				  put_line("Shape inserted");
				  return;
			   end if; 
			   curr := curr.next;
		   end loop;
		   put_line("Shape inserted in last spot");
		   curr.next := Shape;
	   else
		   Shape_Table := Shape;
		   put_line("Shape inserted in first spot");
	   end if;
	   end insert_shape;

	   function lowestPriority(Line, Polyline, Polygone : pixel) return pixel is
		   -- Return the lowest priority of the three entered.
		   -- Requires: All Identifiers are unique.
	   begin
 
		   if (Line(3) /= 0) and then (Line(2) < Polygone(2) and Line(2) < Polyline(2)) and then (Line(1) < Polygone(1) and Line(1) < Polyline(1)) and then (Line(0) < Polygone(0) and Line(0) < Polyline(0)) then 

		   return Line;

	   elsif (PolyLine(3)/= 0) and then (PolyLine(2) < Polygone(2) and PolyLine(2) < Line(2)) and then (PolyLine(1) < Polygone(1) and PolyLine(1) < Line(1)) and then (PolyLine(0) < Polygone(0) and PolyLine(0) < Line(0)) then 

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
   begin
	   -- Draw the "Canvas" (Background)
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
		   Put_line("Loop!!!");
		   if CurrLine = null then
			   LinePrio := (255, 255, 255, 0);
		   else
			   LinePrio := CurrLine.Identifier;
		   end if;
		  
		   if CurrPolyLine = null then
			   PolyLinePrio := (255, 255, 255, 0);
		   else
			   PolyLinePrio := CurrPolyLine.Identifier;
		   end if;
		  
		   if CurrPolygone = null then
			   PolygonePrio := (255, 255, 255, 0);
		   else
			   PolygonePrio := CurrPolygone.Identifier;
		   end if;

		   lowestPrio := lowestPriority(LinePrio, PolyLinePrio, PolygonePrio);

		   if LinePrio = lowestPrio then
			   put_line(" Linje ");
			   PCour := CurrLine.PStart;
			   DrawLine(Window, PCour, CurrLine.Color, Clipper);
			   CurrLine := CurrLine.next;
		   elsif PolyLinePrio = lowestPrio then
			   put_line(" Polylinje ");
			   PCour :=CurrPolyLine.PStart;
			   Polyline(Window, PCour, CurrPolyLine.Color, Clipper);
			   CurrPolyLine := CurrPolyLine.next;
		   elsif PolygonePrio = lowestPrio then
			   put_line(" Polygon ");
			   PCour :=CurrPolygone.PStart;
			   Polygone(Window, PCour, CurrPolygone.Color, Clipper);
			   CurrPolygone := CurrPolygone.next;
		   else
			   Put_line(" HELVETE!!!!! ");
		   end if;


	   end loop;
   end RedrawWindow;

  procedure RedrawOffscreen(	Window		: ImagePtr;
							TabObj		: Nirvana;
							Clipper		: RectanglePtr) is

		pPixel	: PixelPtr	:= Window.basePixel;
		PCour	: PointPtr;
		CurrLine, CurrPolyline, CurrPolygone	: ShapePtr;
		lowestPrio, LinePrio, PolyLinePrio,PolygonePrio : Pixel;
   begin
	   -- Draw the "Canvas" (Background)
	   CurrPolygone := TabObj(Canvas);
	   while CurrPolygone /= null loop
		   PCour := CurrPolygone.PStart;
		   Polygone(Window, PCour, (0,0,0,255), Clipper);
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
		   Put_line("Loop!!!");
		   if CurrLine = null then
			   LinePrio := (255, 255, 255, 0);
		   else
			   LinePrio := CurrLine.Identifier;
		   end if;
		  
		   if CurrPolyLine = null then
			   PolyLinePrio := (255, 255, 255, 0);
		   else
			   PolyLinePrio := CurrPolyLine.Identifier;
		   end if;
		  
		   if CurrPolygone = null then
			   PolygonePrio := (255, 255, 255, 0);
		   else
			   PolygonePrio := CurrPolygone.Identifier;
		   end if;

		   lowestPrio := lowestPriority(LinePrio, PolyLinePrio, PolygonePrio);

		   if LinePrio = lowestPrio then
			   put_line(" Linje ");
			   PCour := CurrLine.PStart;
			   DrawLine(Window, PCour, CurrLine.Identifier, Clipper);
			   CurrLine := CurrLine.next;
		   elsif PolyLinePrio = lowestPrio then
			   put_line(" Polylinje ");
			   PCour :=CurrPolyLine.PStart;
			   Polyline(Window, PCour, CurrPolyLine.Identifier, Clipper);
			   CurrPolyLine := CurrPolyLine.next;
		   elsif PolygonePrio = lowestPrio then
			   put_line(" Polygon ");
			   PCour :=CurrPolygone.PStart;
			   Polygone(Window, PCour, CurrPolygone.Identifier, Clipper);
			   CurrPolygone := CurrPolygone.next;
		   else
			   Put_line(" HELVETE!!!!! ");
		   end if;


	   end loop;
   end RedrawOffscreen;


   procedure findShape(Id: PixelPtr; Scene: in out Nirvana; res: out ShapePtr) is
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
			 put("Korrekt!");
			 put_line(integer'image(integer(pPtr.all(0))));
		 else
			 put("Inte korrekt!");
			 put_line(integer'image(integer(pPtr.all(0))));
		 end if;
   end CheckShape;
end Event_Handling;
