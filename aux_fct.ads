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
   
   procedure InitScanline (P: in PointPtr; Min, Max : out Integer) ;
   
   function X_YMin(Point1,Point2: PointPtr) return integer ;
   
   procedure Table_Des_Cotes (P1,P2: in PointPtr ; Cotes: in out CotePtr) ;
   
   procedure Table_Des_Cotes_Actifs(Cotes: in CotePtr; TCA: in out CotePtr) ;
   
   procedure Update_Cotes(Cotes : in out CotePtr; Line : in Natural) ;
end Aux_Fct;


