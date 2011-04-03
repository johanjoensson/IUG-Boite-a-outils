with Ada_SDL_Video, Interfaces.C, Gr_Shapes, Drawline_Pkg, Ada.Text_Io;
use Ada_SDL_Video, Ada_SDL_Video.PixelPtrPkg, Interfaces.C, Gr_Shapes, Drawline_Pkg, Ada.Text_Io;

package body Event_Handling is
   	procedure insert_shape(Shape_Table: in out ShapePtr; Shape: in ShapePtr) is
	   curr : ShapePtr := Shape_Table;
   begin
	   Shape.next := null;
	   if Shape_Table /= null then
		   while curr.next /= null loop
			   if shape.Identifier(2)< curr.next.Identifier(2) or else  shape.Identifier(1)< curr.next.Identifier(1) or else  shape.Identifier(0)< curr.next.Identifier(0) then
				   -- Insert the side
				   Put_line("instoppning av sida");
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
   procedure RedrawWindow(	Window		: ImagePtr;
							TabObj		: Nirvana;
							pixelValue	: Pixel;
							Clipper		: RectanglePtr) is

		pPixel	: PixelPtr	:= Window.basePixel;
		PCour	: PointPtr;
		SCour	: ShapePtr;
		nullPixel : Pixel := (0,0,0,0);
   begin



	   for i in OBJECT loop
		   PCour := null;
		   SCour := TabObj(i);
		   case i is
			   when Canvas =>
				   while SCour /= null loop
					   PCour := SCour.PStart;
					   Polygone(Window, PCour, SCour.Color, Clipper);
					   SCour := SCour.next;
				   end loop;
				   new_line;


			   when Line =>
				   while SCour /= null loop
					   PCour := SCour.PStart;
					   DrawLine(Window, PCour, TabObj(i).Color, Clipper);
					   SCour := SCour.next;
				   end loop;
			   when Polyline =>
				   while SCour /= null loop
					   PCour :=SCour.PStart;
					   Polyline(Window, PCour, TabObj(i).Color, Clipper);
					   SCour := SCour.next;
				   end loop;
			   when Polygone =>
				   while SCour /= null loop
					   PCour := SCour.PStart;
					   Polygone(Window, PCour, SCour.Color, Clipper);
					   SCour := SCour.next;
				   end loop;
				   new_line;
			   when Toolglass => null;
		   end case;
	   end loop;
   end RedrawWindow;

   procedure CheckShape(offscreenImage: ImagePtr; x,y: integer) is
	   pPtr : pixelPtr;
   begin

         pPtr:= offscreenImage.basePixel + ptrdiff_t (offscreenImage.width * y + x);
		 if pPtr.all = (4,0,0,255) then
			 put_line("Korrekt!");
			 put(integer'image(integer(pPtr.all(0))));
		 else
			 put_line("Inte korrekt!");
			 put(integer'image(integer(pPtr.all(0))));
		 end if;
   end CheckShape;
end Event_Handling;
