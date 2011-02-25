with  Ada_SDL_Video, Interfaces.C, Ada.Text_IO, Ada.Integer_Text_IO;
use   Ada_SDL_Video, Interfaces.C, Ada_SDL_Video.PixelPtrPkg, Ada.Text_IO,Ada.Integer_Text_IO;

package body Gr_Shapes is

   function Min(A,B : Integer) return Integer is
   begin
      if A <= B then
         return A ;
      else
         return B ;
      end if ;
   end ;


   function Max(A,B : Integer) return Integer is
   begin
      if A <= B then
         return B ;
      else
         return A ;
      end if ;
   end ;

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

   procedure Ymax_min (P: in PointPtr; Min, Max : out Integer) is
      --Return the maximal and minimal value of Y found amongst the points
      Tmp : PointPtr := P.next ;
   begin
      Min := P.Y ;
      Max := P.Y ;
      while Tmp /= null loop
         if Tmp.Y < Min then
            Min := Tmp.Y ;
         elsif P.Y > Max then
            Max := Tmp.Y ;
         end if ;
         Tmp := Tmp.Next ;
      end loop ;
   end;



   procedure Insert_Side(P1, P2: PointPtr; Sides: in out SidePtr) is
      --Insert the sides of the polygone in the list of sides
      --P1 and P2 are the endpoints of the side to be inserted
      Cour:Sideptr := Sides;	    -- Pointer to a side currently in the list
      Prec: SidePtr;		    -- Pointer to the side before Cour
      Tmp: SidePtr;		    -- Temporary pointer to the side that is to be inserted in te list

      Inserted: Boolean := False;   -- Boolean to check whether the side has been inserted or not

   begin
      while Cour /= null and then not inserted loop
         --Sides are inserted in order of increasing x values
         Put_Line("A tour of the loop");
         if Min(P1.X, P2.X) < Cour.X_Ymin then
            --the side is to be inserted in the middle or the beginning of the list
            Tmp := new Side;
	    -- Calculate the value of Ymax
            Tmp.Ymax := Max(P1.Y, P2.Y);
	    -- Determine the value of X(Ymin)
            if Tmp.Ymax = P1.Y then
               Tmp.X_Ymin := P1.Y;
            else
               Tmp.X_Ymin := P2.Y;
            end if;
	    -- Insert Tmp correctly
            Tmp.Next := Cour;
            if Prec /= null then
	    -- Tmp will be inserted in the middle of an existing list
               Prec.next := Tmp;
               Put_Line("Side inserted in the middle of the list") ;
            else
	    -- Tmp will be inserted in the beginning of a list
               Sides := Tmp;
               Put_Line("Side inserted first in the list") ;
            end if;
	    -- We have inserted a side!
            Inserted := True;
         end if;
	 -- Continue on inside the loop
         Prec := Cour;
         Cour := Cour.next;
      end loop;

      --if cour is Null then inserted = false
      if not Inserted then
      -- no side has been inserted
      -- the side will be inserted at the end of the list or as the first element of the list      
         Tmp := new Side;
	 -- Calculate all values to be inserted
         Tmp.Ymax := Max(P1.Y, P2.Y);
         if Tmp.Ymax = P1.Y then
            Tmp.X_Ymin := P1.Y;
         else
            Tmp.X_Ymin := P2.Y;
         end if;
         if Sides = null then
            --Side is to be inserted first in the list
	    --because there are no sides currently in the list
            Sides := Tmp;
	    Tmp.Next := Null;
            Put_Line("Side inserted as the first side in the list");
         else
            --the side is to be inserted in the end of the list
            Tmp.Next := Null;
            Prec.next := Tmp;
            Put_Line("Side inserted last in list");
         end if;
      end if;

   end Insert_Side;



   
   procedure Polygone (image      : ImagePtr;
                       points     : PointPtr;
                       pixelValue : Pixel;
                       clipRect   : RectanglePtr      := NULL) is
      Point1: PointPtr := Points ;	-- The first point, the starting point of the polygone
      PCurrent: PointPtr := Points ;	-- The Point that is currently used for drawing a line.
      Ymin, Ymax : Integer ;		-- Max and Min values of y, used to determine maximal heigth of the polygone
      I : Integer := 0;			-- Integer used to track which line a point is on
      Final_Y : Integer := 0;		-- Variable showng on what line the last Side begins

   begin

   -- Calculate the highest and lowest values of y.
      Ymax_Min(Points, Ymin, Ymax);
      -- Begin drawing on the first line
      I := Ymin;
      put(Ymax); New_line;
      -- Declaration of an array containing pointers to all the sides in the polygon
      declare
      -- TSides contains all sides of the polygon,  indexes show on what line the side begins.
         TSides : array (Ymin..Ymax + 1) of SidePtr ;
      begin
      -- Insert all sides in TSides, the chain TSides(n) is sorted after x
         while PCurrent.next /= null loop
	 -- If I is not on the line where the side begins, increase I until it is.
	 -- If I should pass below the polygone then restart from Ymin.
            while Min(Pcurrent.y, Pcurrent.Next.Y) /=I loop
               I := I +1 ;
               if I > Ymax then
                  I:=Ymin;
               end if;

            end loop;
	    -- Insert the side in TSides and draw the lines of the polygone.
	    -- Sides are inserted in their proper place so that the chain is always sorted
               Put_Line("Insert side");
               Put("Insert on line "); Put(I); New_Line ;
               Insert_Side(Pcurrent, Pcurrent.Next, Tsides(I));
               DrawLine(Image, PCurrent.X, PCurrent.Y, PCurrent.Next.X, PCurrent.Next.Y, PixelValue);
               PCurrent := PCurrent.next;
         end loop ;
	 -- Calculate where the last side begins
         Final_Y := Min(PCurrent.Y, Point1.Y);
         Put_Line("Insert side");
         Put("Insert on line "); Put(Final_Y); New_Line ;
	 -- Insert the last side and complete the polygone
         Insert_Side(PCurrent, Point1, Tsides(Final_Y));
         DrawLine(Image, PCurrent.X, PCurrent.Y, Point1.X, Point1.Y, PixelValue) ;
      end;

      --Fill the polygone!

   end Polygone;

end Gr_Shapes;

