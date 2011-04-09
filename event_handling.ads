with Ada_SDL_Video, Gr_Shapes ;
use Ada_SDL_Video, Ada_SDL_Video.PixelPtrPkg, Gr_Shapes ;

package Event_Handling is

	type OBJECT is (Canvas,Line, Polyline, Polygone, Toolglass);

   type Shape;
   type ShapePtr is access all Shape;

   type Shape is record
	   PStart	: PointPtr;
	   Color	: Pixel;
	   Identifier	: Pixel;
	   next		: ShapePtr;
   end record;

   procedure insert_shape(Shape_Table: in out ShapePtr; Shape: in ShapePtr);

   type Nirvana is array(OBJECT) of ShapePtr;

	procedure RedrawWindow(	Window		: ImagePtr;
							TabObj		: Nirvana;
							Clipper		: RectanglePtr);

   	procedure RedrawOffscreen(	Window		: ImagePtr;
							TabObj		: Nirvana;
							Clipper		: RectanglePtr);

	-- Procedure to locate an objetc in the zen
	procedure findShape(Id: PixelPtr; Scene: Nirvana ; Res : out ShapePtr);

	-- Simple procedure to test findShape
	procedure CheckShape(offscreenImage: ImagePtr; x,y: integer; Zen : in out Nirvana; res : out ShapePtr);
   
	-- Procedure to erase a picture from the zen
	procedure eraseShape(id : PixelPtr; Scene : in out Nirvana; Obj : out ShapePtr);
   
	-- Simple procedure to test eraseShape
	procedure RemoveShape(offscreenImage: ImagePtr; x,y : Integer; Zen: in out nirvana);
   
	-- Increase the max priority by one
	procedure increasePrio (prio: in out pixel; iR, iG, iB, iA : Integer);

end Event_Handling;

