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
      clipRect   : RectanglePtr     := NULL);

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

end Gr_Shapes;
