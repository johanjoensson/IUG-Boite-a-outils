-- example_package.ads --
--
--  Gives an example of a simple package with a simple "Ex_DrawLine"
--  procedure.

with
  Ada_SDL_Video, Gr_Shapes;
use
  Ada_SDL_Video, Gr_Shapes;

package Example_Package is

  --
  -- Ex_DrawLine
  --
  --  Draws the line between the points (xMin, yMin) and (xMax, yMax) using
  --  the Bresenham algorithm.
  --  This must be called only with xMin <= xMax, yMin <= yMax, and
  --    (xMax - xMin) > (yMax - yMin)

  procedure Ex_DrawLine  (anImage                 : Image;
                          xMin, yMin, xMax, yMax  : Integer;
                          color                   : Pixel);

  type Boundary is (Upper,Lower,Left,Right);

  function Inside (Point:PointPtr;ClipRect:RectanglePtr;WBoundary:Boundary) return Boolean;
  pragma inline(Inside);

  procedure Intersect(ClipRect: in RectanglePtr;Point1,Point2: in PointPtr;WBoundary:Boundary; Intersection: out PointPtr);
  pragma inline(Intersect);

  procedure SutherlandHodgmanClip(Poly:in PointPtr;PolygonClip:out PointPtr; ClipRect:in RectanglePtr;TheBoundary:Boundary);


  function PolygonClipping(Points:PointPtr;ClipRect:RectanglePtr) return PointPtr;

end Example_Package;

