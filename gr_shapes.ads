with
  Ada_SDL_Video;
use
  Ada_SDL_Video;

package Gr_Shapes is

   -- Image structure
   type Image is record
      basePixel       : PixelPtr;     -- address of the first pixel of the image
      iR, iG, iB, iA  : Integer;      -- indices of the red, green, blue and alpha channels
      width, height   : Integer;      -- size of the image
   end record;

   type ImagePtr is access all Image;

   -- Point data type
   type Point;
   type PointPtr is access all Point;

   type Point is record
      x, y          : Integer;
      next          : PointPtr;
   end record;

   -- Rectangle data type
   type Rectangle is record
      topLeft, bottomRight : Point;
   end record;

   type RectanglePtr is access all Rectangle;

   type Cote;
   type CotePtr is access all Cote;

   type Cote is record
      Ymax, X_Ymin    : Integer;
      Dx, Dy          : Integer;
      E               : Integer;
      Next            : CotePtr;
   end record;

   type TableCotes is array (Integer range <>) of CotePtr ;

   --
   -- Draw line

   procedure DrawLine (anImage                 : ImagePtr;
                       points				   : PointPtr;
                       color                   : Pixel;
                       clipRect   : RectanglePtr :=null) ;

   --
   -- Draw in the image <image> clipped by the rectangle <clipRect>
   --   the polyline defined by the points list <points>
   --   with the pixel value <pixelValue>.
   -- If <clipRect> is NULL, then clip against the entire image.
   --
   procedure Polyline
     (image      : ImagePtr;
      points     : PointPtr;
      pixelValue : Pixel;
      clipRect   : RectanglePtr := null   );

   --
   -- Draw in the image <image> clipped by the rectangle <clipRect>
   --   the filled polygone defined by the points list <points>
   --   with the pixel value <pixelValue>
   -- If <clipRect> is NULL, then clip against the entire image.
   --
   procedure Polygone
     (image      : ImagePtr;
      points     : PointPtr;
      pixelValue : Pixel;
      clipRect   : RectanglePtr     := NULL);

   procedure PaintPixel(currentImage	:in		ImagePtr;
						pPixel			:in out	PixelPtr;
						color			:in		Pixel);
   pragma inline (PaintPixel);
   

   type OBJECT is (Canvas,Line, Polyline, Polygone, Toolglass);

   type Shape;
   type ShapePtr is access all Shape;

   type Shape is record
	   PStart	: PointPtr;
	   Color	: Pixel;
	   next		: ShapePtr;
   end record;

   procedure insert_shape(Shape_Table: in out ShapePtr; Shape: in ShapePtr);

   type Nirvana is array(OBJECT) of ShapePtr;

	procedure RedrawWindow(	Window		: ImagePtr;
							TabObj		: Nirvana;
							pixelValue	: Pixel;
							Clipper		: RectanglePtr);

end Gr_Shapes;
