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

	
	procedure findShape(Id: PixelPtr; Scene: in out Nirvana ; Res : out ShapePtr);

 procedure CheckShape(offscreenImage: ImagePtr; x,y: integer; Zen : in out Nirvana; res : out ShapePtr);

end Event_Handling;

