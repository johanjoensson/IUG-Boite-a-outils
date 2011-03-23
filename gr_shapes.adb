with  Ada_SDL_Video, Interfaces.C, Ada.Text_IO, Ada.Integer_Text_IO, Ada.Unchecked_Deallocation ;
use   Ada_SDL_Video, Interfaces.C, Ada_SDL_Video.PixelPtrPkg, Ada.Text_IO, Ada.Integer_Text_IO;

package body Gr_Shapes is
   procedure Liberer is new Ada.Unchecked_Deallocation (Cote,CotePtr);

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

   function Check (X,Y,XLMin,YLMin,XLMax,YLMax: Integer) return Boolean is
   begin
      if X >= XLMin and X <= XLMax and Y >= YLMin and Y <= YLMax then
         return True ;
      else
         return False ;
      end if ;
   end Check ;


   procedure DrawLine (anImage                 : ImagePtr;
                       points				   : PointPtr;
                       color                   : Pixel ;
                       clipRect                : RectanglePtr:=null ) is
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



   procedure InitScanline (P: in PointPtr; Min, Max : out Integer) is
      --Initialiser la Scanline pour trouver le Ymin et Ymax
      Tmp : PointPtr := P.next ;
   begin
      Min := P.Y ;
      Max := P.Y ;
      while Tmp /= null loop
         if Tmp.Y < Min then
            Min := Tmp.Y ;
         elsif Tmp.Y > Max then
            Max := Tmp.Y ;
         end if ;
         Tmp := Tmp.Next ;
      end loop ;
   end;

   function X_YMin(Point1,Point2: PointPtr) return integer is
      -- Return X_Ymin,si Ymin=Ymax return Xmin
      Aux : integer;
   begin
      if Point1.Y < Point2.Y then
         Aux:= Point1.X;
      elsif point2.Y < point1.Y then
         Aux:= Point2.X;
      else
         Aux:= Min(Point1.X,Point2.X);
      end if;
      return Aux;
   end X_Ymin;

   procedure Table_Des_Cotes (P1,P2: in PointPtr ; Cotes: in out CotePtr) is
      --Inserer la cote dans le table des cotes
      Tmp,Prec: CotePtr ;
      Cour: CotePtr:= Cotes ;
      DejaInsere: Boolean:= False ;
   begin
      Tmp:= new Cote'(Max(P1.Y,P2.Y),X_Ymin(P1,P2),(P2.X - P1.X),(P2.Y - P1.Y),0,null) ;
      if Cotes = null then
         Cotes:= Tmp ;
      else
         Prec:= null ;
         while Cour /= null and then not DejaInsere loop
            if Cour.X_Ymin > Tmp.X_Ymin then
               if Prec = null then
                  -- Inserer dans la premiere position
                  Tmp.Next:= Cotes ;
                  Cotes:= Tmp ;
               else
                  -- Inserer la cote
                  Prec.Next:= Tmp ;
                  Tmp.Next:= Cour ;
               end if;
               DejaInsere:= True ;
            elsif Cour.X_Ymin = Tmp.X_Ymin then
               if Cour.Dy = 0 then
                  if Prec = null then
                     -- Inserer dans la premiere position
                     Tmp.Next:= Cotes ;
                     Cotes:= Tmp ;
                  else
                     -- Inserer la cote
                     Prec.Next:= Tmp ;
                     Tmp.Next:= Cour ;
                  end if;
                  DejaInsere:= True ;
               else
                  if Tmp.Dy /= 0 then
                     if Min(Cour.Dx,Cour.Dy) >= 0 then
                        if Min(Tmp.Dx,Tmp.Dy) <= 0 and Max(Tmp.Dx,Tmp.Dy) >= 0 then
                           if Prec = null then
                              -- Inserer dans la premiere position
                        Tmp.Next:= Cotes ;
                        Cotes:= Tmp ;
                           else
                              -- Inserer la cote
                              Prec.Next:= Tmp ;
                              Tmp.Next:= Cour ;
                           end if;
                           DejaInsere:= True ;
                        elsif Min(Tmp.Dx,Tmp.Dy) >= 0 or Max(Tmp.Dx,Tmp.Dy) <= 0 then
                           if abs(Cour.Dx * Tmp.Dy) > abs(Tmp.Dx * Cour.Dy) then
                              if Prec = null then
                                 -- Inserer dans la premiere position
                                 Tmp.Next:= Cotes ;
                                 Cotes:= Tmp ;
                              else
                                 -- Inserer la cote
                                 Prec.Next:= Tmp ;
                                 Tmp.Next:= Cour ;
                              end if;
                              DejaInsere:= True ;
                           end if ;
                        end if ;
                     end if ;
                  end if ;
               end if ;
            end if;
            Prec:= Cour ;
            Cour:= Cour.Next ;
         end loop;
         if not DejaInsere then
            -- Inserer a la fin de la chaine
            Prec.Next:= Tmp ;
         end if;
      end if ;
   end Table_Des_Cotes ;

   procedure Table_Des_Cotes_Actifs(Cotes: in CotePtr; TCA: in out CotePtr) is
      --Construire le table des cotes actifs
      Cour,Suiv: CotePtr:= Cotes ;
      TCACour,TCAPrec: CotePtr ;
      DejaInsere: Boolean:= False ;
   begin
      while Cour /= null loop
         -- Initialisation des variables
         DejaInsere:= False ;
         Suiv:= Cour.Next ;
         Cour.Next:= null ;
         TCAPrec:= null ;
         TCACour:= TCA ;
         if TCA = null then
            TCA:= Cour ;
         else
            while TCACour /= null and not DejaInsere loop
               if Cour.X_Ymin < TCACour.X_Ymin then
                  if TCAPrec = null then
                     -- Inserer dans la premiere position
                     Cour.Next := TCA;
                     TCA:= Cour;
                  else
                     -- Inserer dans la chaine
                     TCAPrec.Next := Cour;
                     Cour.Next := TCACour;
                  end if;
                  DejaInsere := true;
               elsif Cour.X_Ymin = TCACour.X_Ymin then
                  if TCACour.Dy = 0 then
                     if TCAPrec = null then
                        -- Inserer dans la premiere position
                        Cour.Next:= TCA ;
                        TCA:= Cour ;
                     else
                        -- Inserer la cote
                        TCAPrec.Next:= Cour ;
                        Cour.Next:= TCACour ;
                     end if;
                     DejaInsere:= True ;
                  else
                     if Cour.Dy /= 0 then
                        if Min(TCACour.Dx,TCACour.Dy) >= 0 then
                           if Min(Cour.Dx,Cour.Dy) <= 0 and Max(Cour.Dx,Cour.Dy) >= 0 then
                              if TCAPrec = null then
                                 -- Inserer dans la premiere position
                                 Cour.Next:= TCA ;
                                 TCA:= Cour ;
                              else
                                 -- Inserer la cote
                                 TCAPrec.Next:= Cour ;
                                 Cour.Next:= TCACour ;
                              end if;
                              DejaInsere:= True ;
                           elsif Min(Cour.Dx,Cour.Dy) >= 0 or Max(Cour.Dx,Cour.Dy) <= 0 then
                              if abs(TCACour.Dx * Cour.Dy) > abs(Cour.Dx * TCACour.Dy) then
                                 if TCAPrec = null then
                                    -- Inserer dans la premiere position
                                    Cour.Next:= TCA ;
                                    TCA:= Cour ;
                                 else
                                    -- Inserer la cote
                                    TCAPrec.Next:= Cour ;
                                    Cour.Next:= TCACour ;
                                 end if;
                                 DejaInsere:= True ;
                              end if ;
                           end if ;
                        end if ;
                     end if ;
                  end if;
               end if;
               TCAPrec := TCACour;
               TCACour := TCACour.Next;
            end loop;
            if not DejaInsere then
               -- Inserer a la fin de la chaine
               TCAPrec.next := Cour;
               DejaInsere := true;
            end if;
         end if ;
         Cour := Suiv;
      end loop;
   end Table_Des_Cotes_Actifs ;

   procedure Update_Cotes(Cotes : in out CotePtr; Line : in Natural) is
      Cour, Sent        : CotePtr       := Cotes;
      Prec            : CotePtr       := null;
      Suiv            : CotePtr;
      TmpCotes        : CotePtr;
   begin
      while Cour /= null loop
         Suiv := Cour.next;
         -- Renouveler les valeurs de X_Ymin
         if Cour.Dy /= 0 then
            if Min(Cour.Dx,Cour.Dy) >= 0 or Max(Cour.Dx,Cour.Dy) <= 0 then
               Cour.X_Ymin:= Cour.X_Ymin + (abs(Cour.Dx) + Cour.E)/abs(Cour.Dy) ;
               Cour.E:= (abs(Cour.Dx) + Cour.E) mod abs(Cour.Dy) ;
            else
               Cour.X_Ymin:= Cour.X_Ymin - (abs(Cour.Dx) + Cour.E)/abs(Cour.Dy) ;
               Cour.E:= (abs(Cour.Dx) + Cour.E) mod abs(Cour.Dy) ;
            end if;
         end if ;
         -- Liberer les cotes inutiles
         if Cour.Ymax = line then
            TmpCotes := Cour;
            if Prec = null then
               Cour := null;
               Sent := Suiv;
            else
               Prec.next := Suiv;
               Cour := Prec;
            end if;
            Liberer(TmpCotes);
         end if;
         Prec := Cour;
         Cour := Suiv;
      end loop;
      Cotes := Sent;
      TmpCotes := null;
      Table_Des_Cotes_Actifs(Cotes, TmpCotes);
      Cotes := TmpCotes;
   end Update_Cotes;

   procedure Polygone (image      : ImagePtr;
                       points     : PointPtr;
                       pixelValue : Pixel;
                       clipRect   : RectanglePtr  :=    null) is
      Ymin,Ymax: Integer ;
      PDeb,PCour: PointPtr:= points ;
      TCA,Cour: CotePtr ;
      TC: array (0..Image.height) of CotePtr ;
      pPtr: PixelPtr ;
      Final_Y,X, line, XMAx: Integer ;
      Paire: Boolean ;
   begin
      InitScanline(Points, Ymin, Ymax);
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
	
	  --Clipping
	  line := Ymin;
	  if ClipRect /= null then
		  -- Trouve la premier scanline
		  while line < ClipRect.topLeft.y loop 
			  Table_Des_Cotes_Actifs(TC(line), TCA);
			  Update_Cotes(TCA, line+1);
			  line := line +1 ;
		  end loop;
		  Ymin := Max(Ymin, Cliprect.topLeft.Y);
		  Ymax := Min(Ymax, ClipRect.bottomRight.Y);
	  end if;

	  -- Remplissage de poygone
      for y in Ymin ..Ymax-1 loop
		  -- mets a jour le TCA
		  Table_Des_Cotes_Actifs(TC(y), TCA);
         Cour := TCA;
		 if ClipRect /= null then
			 X:= Max(Cour.X_Ymin, ClipRect.topLeft.X) +1 ;
		 else
			 X := Cour.X_Ymin;
		 end if;
         pPtr:= Image.basePixel + ptrdiff_t (Image.width * y + x);
         Paire:= False ;
         while Cour.Next /= null loop
			 if ClipRect /= null then
				 XMax := Min(cour.next.X_Ymin, ClipRect.bottomRight.X);
			 else
				 XMax := cour.next.X_Ymin;
			 end if;
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
   end Polygone ;

   -- Procedure for painting a pixel with regard to alpha values.
   procedure PaintPixel(currentImage	:in		ImagePtr;
						pPixel			:in out	PixelPtr;
						color			:in		Pixel) is

		-- Set the indexes for all the channels
	   iR	: Integer := currentImage.iR;
	   iG	: Integer := currentImage.iG;
	   iB	: Integer := currentImage.iB;
	   iA	: Integer := currentImage.iA;
   begin
	   -- update all the values, one channel at a time
		if color(iA) /= 0 then
	 		pPixel(iR) := (color(iA))*pPixel(iR) + (255 - color(iA)+1)* color(iR);
	 		pPixel(iG) := (color(iA))*pPixel(iG) + (255 - color(iA)+1)* color(iG);
			pPixel(iB) := (color(iA))*pPixel(iB) + (255 - color(iA)+1)* color(iB); 
		end if;
   end;

   procedure RedrawWindow(	Window		: ImagePtr;
							TabObj		: Nirvana;
							pixelValue	: Pixel;
							Clipper		: RectanglePtr) is

		pPixel	: PixelPtr	:= Window.basePixel;
		PCour	: PointPtr;
		SCour	: ShapePtr;
		nullPixel : Pixel := (0,0,0,0);
   begin

	   pPixel:= Window.basePixel + ptrdiff_t (Window.width * Clipper.topLeft.Y + Clipper.topLeft.X);

	   for y in Clipper.topLeft.Y..Clipper.bottomRight.Y loop
		   for x in Clipper.topLeft.X..Clipper.bottomRight.X loop
			   PaintPixel(Window,pPixel,pixelValue);
			   Increment(pPixel);
		   end loop;
 		   pPixel:= Window.basePixel + ptrdiff_t (Window.width * y + Clipper.topLeft.x);
	   end loop;

	   for i in OBJECT loop
		   PCour := null;
		   SCour := TabObj(i);
		   case i is
			   when Line =>
				   while SCour /= null loop
					   PCour := TabObj(i).PStart;
					   while PCour /= null loop
						   DrawLine(Window, PCour, TabObj(i).Color, Clipper);
						   PCour := PCour.next;
					   end loop;
					   SCour := SCour.next;
				   end loop;
			   when Polyline =>
				   while SCour /= null loop
					   PCour := TabObj(i).PStart;
					   while PCour /= null loop
						   Polyline(Window, PCour, TabObj(i).Color, Clipper);
						   PCour := PCour.next;
					   end loop;
					   SCour := SCour.next;
				   end loop;
			   when Canvas|Polygone|Toolglass =>
				   while SCour /= null loop
					   PCour := TabObj(i).PStart;
					   while PCour /= null loop
						   Polygone(Window, PCour, TabObj(i).Color, Clipper);
						   PCour := PCour.next;
					   end loop;
					   SCour := SCour.next;
				   end loop;
		   end case;
	   end loop;
   end RedrawWindow;

end Gr_Shapes;
