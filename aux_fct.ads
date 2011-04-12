with Ada_SDL_Video, Gr_Shapes;
use Ada_SDL_Video, Gr_Shapes;
package Aux_Fct is

	-- Type used in polygon algorithm
	type Cote;
 	type CotePtr is access all Cote;

   type Cote is record
      Ymax, X_Ymin    : Integer;
      Dx, Dy          : Integer;
      E               : Integer;
      Next            : CotePtr;
   end record;
   
   -- table used in polygon algorithm
   type TableCotes is array (Integer range <>) of CotePtr ;

   -- paint the pixel with Color, using the alpha channel
   procedure PaintPixel(currentImage	:in		ImagePtr;
						pPixel			:in out	PixelPtr;
						color			:in		Pixel);

   -- returns min(A,B)
   function Min(A,B : Integer) return Integer;

   -- returns max(A,B)
   function Max(A,B : Integer) return Integer;

   -- return True if (x,y) in the rectangle
   function Check (X,Y,XLMin,YLMin,XLMax,YLMax: Integer) return Boolean;   
   
   -- find the Xmin and the Xmax among the points entered
   procedure X_MinMax (P: in PointPtr; min, max : out integer) ;

   -- Liberate the memory occupied by the points   
   procedure erasePoints(Points : pointPtr) ;

   -- Calculate and return the Ymin and Ymax of the points entered
   procedure InitScanline (P: in PointPtr; Min, Max : out Integer) ;
   
   -- Return the X value corresponding to the minimum value of Y
   -- if there is a tie in Ymin, return the min (x)
   function X_YMin(Point1,Point2: PointPtr) return integer ;

   -- Construct the table of sides used in the polygone algorithm   
   procedure Table_Des_Cotes (P1,P2: in PointPtr ; Cotes: in out CotePtr) ;
   
   -- Construct the Table of active sides used in the polygon algorithm
   procedure Table_Des_Cotes_Actifs(Cotes: in CotePtr; TCA: in out CotePtr) ;
   
   -- Update the sides used in the polygon algorihtm
   procedure Update_Cotes(Cotes : in out CotePtr; Line : in Natural) ;
  
   -- Type used for clipping (Sutherland-Hodgmann algorithm)
   type Boundary is (Upper,Lower,Left,Right);

   -- returns true if point inside the rectangle (one side at a time, side determined by Boundary)
  function Inside (Point:PointPtr;ClipRect:RectanglePtr;WBoundary:Boundary) return Boolean;
  pragma inline(Inside);

  -- Calculate the intersection of the ClipRect and the polygon defined by Points
  procedure Intersect(ClipRect: in RectanglePtr;Point1,Point2: in PointPtr;WBoundary:Boundary; Intersection: out PointPtr);
  pragma inline(Intersect);

  -- Sutherland-Hodgmann algorithm for clipping
  procedure SutherlandHodgmanClip(Poly:in PointPtr;PolygonClip:out PointPtr; ClipRect:in RectanglePtr;TheBoundary:Boundary);

  -- returns the "clipped" polygon's points
  function PolygonClipping(Points:PointPtr;ClipRect:RectanglePtr) return PointPtr;

end Aux_Fct;


