with  Ada_SDL_Video, Interfaces.C, Ada.Text_IO, Ada.Integer_Text_IO, Ada.Unchecked_Deallocation,  Drawline_Pkg, Aux_Fct ;
use   Ada_SDL_Video, Interfaces.C, Ada_SDL_Video.PixelPtrPkg, Ada.Text_IO, Ada.Integer_Text_IO,  Drawline_Pkg, Aux_Fct;

package body Gr_Shapes is

   procedure Polyline (image      : ImagePtr;
                       points     : PointPtr;
                       pixelValue : Pixel;
                       clipRect   : RectanglePtr :=null    ) is
      Cour: PointPtr:= points ;
   begin
      if Cour.Next /= null then
--         DrawLine(image, Cour, Cour, PixelValue,ClipRect) ;
--      else
         while Cour.next /= null loop
            DrawLine(image, Cour, PixelValue,ClipRect);
            Cour := Cour.next;
         end loop ;
      end if ;
   end Polyline;



   procedure Polygone (image      : ImagePtr;
                       points     : PointPtr;
                       pixelValue : Pixel;
                       clipRect   : RectanglePtr  :=    null) is
      Ymin,Ymax: Integer ;
      PDeb,PCour, Tmp : PointPtr:= points ;
      TCA,Cour: CotePtr ;
      TC: array (0..Image.height) of CotePtr ;
      pPtr: PixelPtr ;
      Final_Y,X, XMAx: Integer ;
      Paire: Boolean ;
	  PClip	: PointPtr:= Points;
   begin
	   if ClipRect /= null then
		   PClip := PolygonClipping(Points, ClipRect);
		   PDeb := PCLip;
		   PCour := PClip;
	   end if;

	   if PCLip /= null then
	 	   InitScanline(PClip, Ymin, Ymax);
	  -- Insertion des cotes.
      while PCour.Next /= null loop
         if PCour.Y /= PCour.Next.Y then
            Table_Des_Cotes(PCour, PCour.Next, TC(Min(PCour.y, PCour.next.y)));
         end if ;
         PCour := PCour.next;
      end loop ;
      -- Insertion de la dernier cote
	  Final_Y := Min(PCour.Y, PDeb.Y);
      if PCour.Y /= PDeb.Y then
         Table_Des_Cotes(PCour, PDeb, TC(Final_Y));
      end if ;
	
 
	  -- Remplissage de poygone
      for y in Ymin ..Ymax-1 loop
		  -- mets a jour le TCA
		  Table_Des_Cotes_Actifs(TC(y), TCA);
         Cour := TCA;
--		 if ClipRect /= null then
--			 X:= Max(Cour.X_Ymin, ClipRect.topLeft.X) +1 ;
--		 else
			 X := Cour.X_Ymin;
--		 end if;
         pPtr:= Image.basePixel + ptrdiff_t (Image.width * y + x);
         Paire:= False ;
         while Cour.Next /= null loop
--			 if ClipRect /= null then
--				 XMax := Min(cour.next.X_Ymin, ClipRect.bottomRight.X);
--			 else
				 XMax := cour.next.X_Ymin;
--			 end if;
            if not Paire then
				-- Paint the pixels.
               while X <= XMax loop
				  PaintPixel(image,pPtr, pixelValue);
                  Increment(pPtr) ;
                  X:= X+1 ;
               end loop;
               Paire:= True ;
               Cour:= Cour.Next ;
            else
				-- Go to the next interval to paint.
               while X <= XMax loop
                  Increment(pPtr) ;
                  X:= X+1 ;
               end loop;
               Paire:= False ;
               Cour:= Cour.Next ;
            end if ;
         end loop ;
         Update_Cotes(TCA, Y+1);
      end loop;
   end if;
end Polygone ;


end Gr_Shapes;
