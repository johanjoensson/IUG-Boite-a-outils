with Ada_SDL_Video, Gr_Shapes ;
use Ada_SDL_Video, Ada_SDL_Video.PixelPtrPkg, Gr_Shapes ;

package Event_Handling is

	type OBJECT is (Canvas,Line, Polyline, Polygone, Circle, FilledCircle, Toolglass);

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
							Clipper		: RectanglePtr := null);

   	procedure RedrawOffscreen(	Window		: ImagePtr;
							TabObj		: Nirvana;
							Clipper		: RectanglePtr := null);

	-- Procedure to locate an objetc in the zen
	procedure findShape(Id: PixelPtr; Scene: Nirvana ; Res : out ShapePtr);

	-- Simple procedure to test findShape
	procedure CheckShape(offscreenImage: ImagePtr; x,y: integer; Zen : Nirvana; res : out ShapePtr);
   
	-- Procedure to erase a picture from the zen
	procedure eraseShape(id : PixelPtr; Scene : in out Nirvana; Obj : out ShapePtr; erase : Boolean := True);
   
	-- Simple procedure to test eraseShape
	procedure RemoveShape(offscreenImage: ImagePtr; x,y : Integer; Zen: in out nirvana; res : out ShapePtr; erase : Boolean := True);
   
	-- Increase the max priority by one
	procedure increasePrio (prio: in out pixel; iR, iG, iB, iA : Integer);
   
	-- Remove any holes in the list of priorities already in use
	procedure resortPrio(scene: in out nirvana; iR, iG, iB, iA : integer ; MaxPrio : out Pixel);

	function ObjectType(id : PixelPtr; scene : Nirvana) return OBJECT;

	function whatObject(offscreenImage: ImagePtr; x,y : Integer; Zen: nirvana) return OBJECT;

	procedure DrawToolglass(MyImagePtr : ImagePtr; mousex, mousey : Integer; iR, iG, iB, iA : Integer; Clipper : RectanglePtr := null);
	
	procedure DrawColorTable(MyImagePtr : ImagePtr; mousex, mousey : Integer; iR, iG, iB, iA : Integer; Clipper : RectanglePtr := null);


end Event_Handling;

