with  Ada_SDL_Video, Interfaces.C, Ada.Text_IO, Ada.Integer_Text_IO, Aux;
use   Ada_SDL_Video, Interfaces.C, Ada_SDL_Video.PixelPtrPkg, Ada.Text_IO,Ada.Integer_Text_IO, Aux;

package body Gr_Shapes is

procedure DrawLine (anImage                 : ImagePtr;
                       xMin, yMin, xMax, yMax  : Integer;
                       color                   : Pixel) is
      e           : Integer;
      x_i, y_i    : Integer;
      dx, dy      : Integer;
      pPtr        : PixelPtr;

      x0          : Integer ;
      y0          : Integer ;
      x1          : Integer ;
      y1          : Integer ;

      Pos         : Boolean ;


   begin
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
            PPtr.all:= Color ;
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

         if abs(dy/dx) < 1 then
            while x_i <= x1 loop
               pPtr.all  := Color ;

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

         elsif (dy/dx) = 1 then
            while x_i <= x1 loop
               pPtr.all  := color;
               x_i       := x_i + 1;
               Increment (pPtr);
               if Pos = True then
                  y_i     := y_i + 1;
                  pPtr    := pPtr + ptrdiff_t (anImage.width);
               else
                  y_i     := y_i - 1;
                  pPtr    := pPtr - ptrdiff_t (anImage.width);
               end if ;
            end loop;

         else
            if Pos then
               while y_i <= y1 loop
                  pPtr.all := color ;
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
                  PPtr.all := Color ;
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


   procedure DryDrawPoint (XMin, YMin, XMax, YMax  :in out Integer) is
      Dx,Dy,E : Integer ;
      Pos: Boolean ;
   begin
      Dx:= XMax - XMin ;
      Dy:= YMax - yMin;
      E:= 0;

      if Dx = 0 then
            YMin:= YMin + 1 ;
      else

         if Dy >= 0 then
            Pos:= True ;
         else
            Pos:= False ;
            Dy:= -Dy ;
         end if ;

         if (dy/dx) < 1 then

            xMin       := xMin + 1;

            e         := e + dy ;

            if 2*e > dx then
               if Pos = True then
                  yMin     := yMin + 1 ;
               else
                  yMin     := yMin - 1 ;
               end if ;
               e       := e - dx ;
            end if;

         elsif (dy/dx) = 1 then
            xMin       := xMin + 1;
            if Pos = True then
               yMin     := yMin + 1;
            else
               yMin     := yMin - 1;
            end if ;

         else
            if Pos = True then
               YMin := YMin + 1 ;
            else
               YMin := YMin - 1 ;
            end if ;
            E:= E + Dx ;
            if 2*E > Dy then
               XMin:= XMin + 1 ;
               E:= E - Dy ;
            end if ;
         end if ;
      end if ;
   end DryDrawPoint ;


   function Check (X,Y,XLMin,YLMin,XLMax,YLMax: Integer) return Boolean is
   begin
      if X >= XLMin and X <= XLMax and Y >= YLMin and Y <= YLMax then
         return True ;
      else
         return False ;
      end if ;
   end Check ;




   procedure ClipLine (anImage      : ImagePtr;
                       XMin,YMin,XMax,YMax : Integer ;
                       color : Pixel;
                       XLMin,YLMin,XLMax,YLMax : Integer) is
      NewImage: ImagePtr:= anImage ;
      Cou: Pixel := color ;
      X0,Y0,X1,Y1,NewX0,NewY0,NewX1,NewY1: Integer ;

   begin
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

      if not Check(X0,Y0, XLMin,YLMin,XLMax,YLMax) then
         while X0 /= X1 and not Check(X0,Y0, XLMin,YLMin,XLMax,YLMax) loop
            DryDrawPoint(X0,Y0,X1,Y1) ;
         end loop ;
         if X0 /= X1 and Check(X0,Y0, XLMin,YLMin,XLMax,YLMax) then
            NewX0:= X0 ;
            NewY0:= Y0 ;
         elsif X0 = X1 and Check(X0,Y0, XLMin,YLMin,XLMax,YLMax) then
            NewX0:= X0 ;
            NewY0:= Y0 ;
            NewX1:= X1 ;
            NewY1:= Y1 ;
         end if ;


         while X0 /= X1 and Check(X0,Y0, XLMin,YLMin,XLMax,YLMax) loop
            DryDrawPoint(X0,Y0,X1,Y1) ;
            NewX1:= X0 ;
            NewY1:= Y0 ;
         end loop ;

         DrawLine(NewImage,NewX0,NewY0,NewX1,NewY1,Cou) ;

      else
         NewX0:= X0 ;
         NewY0:= Y0 ;
         while X0 /= X1 and Check(X0,Y0, XLMin,YLMin,XLMax,YLMax) loop
            DryDrawPoint(X0,Y0,X1,Y1) ;
            NewX1:= X0 ;
            NewY1:= Y0 ;
         end loop ;

         DrawLine(NewImage,NewX0,NewY0,NewX1,NewY1,Cou) ;
      end if ;

   end ClipLine ;






   procedure Polyline (image      : ImagePtr;
                       points     : PointPtr;
                       pixelValue : Pixel;
                       clipRect   : RectanglePtr      := NULL) is
      Cour,Suiv: PointPtr ;
   begin
      Cour:= Points ;
      Suiv:= Cour.Next ;
      --while Suiv /= null loop

         DrawLine(Image,Cour.X,Cour.Y,Suiv.X,Suiv.Y,pixelValue);
        -- Cour:= Suiv ;
        -- Suiv:= Cour.Next ;
     -- end loop ;
   end Polyline;

   procedure Polygone (image      : ImagePtr;
                       points     : PointPtr;
                       pixelValue : Pixel;
					   clipRect   : RectanglePtr := null) is
   
      Point1        : PointPtr  := Points ;	-- The first point, the starting point of the polygone
      PCurrent      : PointPtr  := Points ;	-- The Point that is currently used for drawing a line.
      Ymin, Ymax    : Integer ;		        -- Max and Min values of y, used to determine maximal heigth of the polygone
	  Xmin,Xmax		: Integer ;
	  I             : Integer   := 0 ;		-- Integer used to track which line a point is on
      Final_Y       : Integer   := 0 ;		-- Variable showng on what line the last Side begins
	  TSides		: array (0..image.height) of SidePtr ;	-- The list of all sides in the polygone
      TSidesActive  : SidePtr   := null ;   -- Pointer towards the "active sides" of the polygone

      color         : Pixel     := pixelValue ;	-- Color of the polygone
	  pPtr			: PixelPtr ;			-- Pointer to the current pixel to paint
	  cour			: SidePtr ;				-- Pointer to the current side treated

	  XClipMin, XClipMax, YClipMin, YClipMax		: integer;

   begin
      -- Calculate the highest and lowest values of y.
      Ymax_Min(Points, Ymin, Ymax);
	  Xmax_Min(Points, Xmin, Xmax);
      -- Insert all sides in TSides, the chain TSides(n) is sorted after x
         while PCurrent.next /= null loop
               -- Insert the side in TSides and draw the lines of the polygone.
	           -- Sides are inserted in their proper place so that the chain is always sorted
               Insert_Side(Pcurrent, Pcurrent.Next, Tsides(Min(Pcurrent.y, Pcurrent.next.y)));
               PCurrent := PCurrent.next;
         end loop ;

         -- Calculate where the last side begins
         Final_Y := Min(PCurrent.Y, Point1.Y);
         -- Insert the last side and complete the polygone
         Insert_Side(PCurrent, Point1, Tsides(Final_Y));

		 XClipMin := ClipRect.all.topLeft.X ;
		 XClipMax := ClipRect.all.bottomRight.X ;
		 YClipMin := ClipRect.all.topLeft.Y ;
		 YClipMax := ClipRect.all.bottomRight.Y ;

         --Fill the polygone!
         for y in Ymin ..Ymax loop
			 -- Insert sides into TSidesActive, update the sides in TSidesActive, sort them and remove if necessary
             Insert_Side(Tsides(y), TSidesActive);
			 Update_Sides(TSidesActive, y);
             cour := TSidesActive;
			 -- Fill in all intervals
             while cour /= null and then cour.next /= null loop
				 -- Fill in the current interval
				 for x in cour.X_Ymin .. Cour.next.X_Ymin loop
					 pPtr:= Image.basePixel + ptrdiff_t (Image.width * y + x);
					 if (ClipRect /= null) and then Check(x,y,ClipRect.TopLeft.X,ClipRect.TopLeft.Y,ClipRect.BottomRight.X,ClipRect.BottomRight.Y) then
	   					 PPtr.all:= Color ;
	  				 end if ;
				 end loop;
				 -- Move on to the next interval
                 cour := cour.next.next;
             end loop;
         end loop;
   end Polygone;

end Gr_Shapes;

