with Ada_SDL_Video, Gr_Shapes;
use Ada_SDL_Video, Gr_Shapes;
package Aux_Fct is

	type Cote;
 	type CotePtr is access all Cote;

   type Cote is record
      Ymax, X_Ymin    : Integer;
      Dx, Dy          : Integer;
      E               : Integer;
      Next            : CotePtr;
   end record;
   
   type TableCotes is array (Integer range <>) of CotePtr ;

   procedure PaintPixel(currentImage	:in		ImagePtr;
						pPixel			:in out	PixelPtr;
						color			:in		Pixel);

   function Min(A,B : Integer) return Integer;

   function Max(A,B : Integer) return Integer;

   function Check (X,Y,XLMin,YLMin,XLMax,YLMax: Integer) return Boolean;   
   
   procedure X_MinMax (P: in PointPtr; min, max : out integer) ;
   
   procedure erasePoints(Points : pointPtr) ;

   procedure InitScanline (P: in PointPtr; Min, Max : out Integer) ;
   
   function X_YMin(Point1,Point2: PointPtr) return integer ;
   
   procedure Table_Des_Cotes (P1,P2: in PointPtr ; Cotes: in out CotePtr) ;
   
   procedure Table_Des_Cotes_Actifs(Cotes: in CotePtr; TCA: in out CotePtr) ;
   
   procedure Update_Cotes(Cotes : in out CotePtr; Line : in Natural) ;
  
   type Boundary is (Upper,Lower,Left,Right);

  function Inside (Point:PointPtr;ClipRect:RectanglePtr;WBoundary:Boundary) return Boolean;
  pragma inline(Inside);

  procedure Intersect(ClipRect: in RectanglePtr;Point1,Point2: in PointPtr;WBoundary:Boundary; Intersection: out PointPtr);
  pragma inline(Intersect);

  procedure SutherlandHodgmanClip(Poly:in PointPtr;PolygonClip:out PointPtr; ClipRect:in RectanglePtr;TheBoundary:Boundary);


  function PolygonClipping(Points:PointPtr;ClipRect:RectanglePtr) return PointPtr;

end Aux_Fct;


