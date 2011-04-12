with  Ada_SDL_Video, Interfaces.C, Gr_Shapes, Aux_Fct ;
use   Ada_SDL_Video, Interfaces.C, Ada_SDL_Video.PixelPtrPkg, Gr_Shapes, Aux_Fct ;

package body Drawline_Pkg is
	
	procedure DrawLine (anImage                 : ImagePtr;
                       points				   : PointPtr;
                       color                   : Pixel ;
                       clipRect                : RectanglePtr:=null ) is
					   -- Bressenham algorithm for drawing a straight line
      xMin,yMin,xMax,yMax,E,x_i,Y_i,dx,Dy,X0,X1,Y0,y1: Integer;
      pPtr        : PixelPtr;
      Pos         : Boolean ;
 	begin
	   xMin := points.X;
	   yMin := points.Y;
	   xMax := Points.next.X;
	   yMax := Points.next.Y;
      if XMin < XMax then
         X0:= XMin ;
         Y0:= YMin ;
         X1:= XMax ;
         Y1:= YMax ;
      elsif XMin = XMax then
         X0:= XMin ;
         Y0:= Min(YMin,YMax) ;
         X1:= XMax ;
         Y1:= Max(YMin,yMax) ;
      else
         X0:= XMax ;
         Y0:= YMax ;
         X1:= XMin ;
         Y1:= YMin ;
      end if ;

      dx:= x1 - x0 ;
      dy:= y1 - y0;
      e:= 0;
      x_i:= x0;
      y_i:= y0;
      pPtr:= anImage.basePixel + ptrdiff_t (anImage.width * y0 + x0);

      if Dx = 0 then
         while Y_I <= Y1 loop
            if ClipRect /= null then
               if Check(X_I,Y_I,ClipRect.TopLeft.X,ClipRect.TopLeft.Y,ClipRect.BottomRight.X,ClipRect.BottomRight.Y) then
				PaintPixel(anImage,pPtr, color);
               end if ;
            else
				PaintPixel(anImage,pPtr, color);
            end if ;
            Y_i:= Y_i + 1 ;
            pPtr    := pPtr + ptrdiff_t (anImage.width);
         end loop ;
      else
         if Dy >= 0 then
            Pos:= True ;
         else
            Pos:= False ;
            Dy:= -Dy ;
         end if ;
         if dy < dx then
            while x_i <= x1 loop
               if ClipRect /= null then
                  if Check(X_I,Y_I,ClipRect.TopLeft.X,ClipRect.TopLeft.Y,ClipRect.BottomRight.X,ClipRect.BottomRight.Y) then
   					  PaintPixel(anImage,pPtr, color);
                  end if ;
               else
				   PaintPixel(anImage,pPtr, color);
               end if ;
               x_i       := x_i + 1;
               Increment(pPtr) ;
               e         := e + dy ;
               if 2*e > dx then
                  if Pos = True then
                     y_i     := y_i + 1 ;
                     pPtr    := pPtr + ptrdiff_t (anImage.width);
                  else
                     y_i     := y_i - 1 ;
                     pPtr    := pPtr - ptrdiff_t (anImage.width);
                  end if ;
                  e       := e - dx ;
               end if;
            end loop;
         else
            if Pos then
               while y_i <= y1 loop
                  if ClipRect /= null then
                     if Check(X_I,Y_I,ClipRect.TopLeft.X,ClipRect.TopLeft.Y,ClipRect.BottomRight.X,ClipRect.BottomRight.Y) then
   					  PaintPixel(anImage,pPtr, color);
                     end if ;
                  else
   					  PaintPixel(anImage,pPtr, color);
                  end if ;
                  Y_i := Y_I + 1 ;
                  pPtr    := pPtr + ptrdiff_t (anImage.width);
                  E:= E + Dx ;
                  if 2*E > Dy then
                     X_i:= X_I + 1 ;
                     Increment(pPtr) ;
                     E:= E - Dy ;
                  end if ;
               end loop ;
            else
               while Y_I >= Y1 loop
                  if ClipRect /= null then
                     if Check(X_I,Y_I,ClipRect.TopLeft.X,ClipRect.TopLeft.Y,ClipRect.BottomRight.X,ClipRect.BottomRight.Y) then
	  					 PaintPixel(anImage,pPtr, color);
                     end if ;
                  else
   					  PaintPixel(anImage,pPtr, color);
                  end if ;
                  Y_i := Y_I - 1 ;
                  pPtr    := pPtr - ptrdiff_t (anImage.width);
                  E:= E + Dx ;
                  if 2*E > Dy then
                     X_i:= X_I + 1 ;
                     Increment(pPtr) ;
                     E:= E - Dy ;
                  end if ;
               end loop ;
            end if ;
         end if ;
      end if ;
   end DrawLine;
end Drawline_pkg;
