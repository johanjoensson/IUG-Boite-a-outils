with Ada_SDL_Video, Interfaces.C, Ada.Unchecked_Deallocation, Gr_Shapes ;
use Ada_SDL_Video,  Interfaces.C,Ada_SDL_Video.PixelPtrPkg, Gr_Shapes ;

package body Aux_Fct is
	 procedure Liberer is new Ada.Unchecked_Deallocation (Cote,CotePtr);
   procedure free is new Ada.Unchecked_Deallocation (Point,PointPtr);


  procedure PaintPixel(currentImage	:in		ImagePtr;
						pPixel			:in out	PixelPtr;
						color			:in		Pixel) is
						-- "Paint" the pixel

		-- Set the indexes for all the channels
	   iR	: Integer := currentImage.iR;
	   iG	: Integer := currentImage.iG;
	   iB	: Integer := currentImage.iB;
	   iA	: Integer := currentImage.iA;
   begin
	   -- update all the values, one channel at a time
				pPixel(iR) := 255*(255 - color(iA))*pPixel(iR) + (255*color(iA)*color(iR));
				pPixel(iG) := 255*(255 - color(iA))*pPixel(iG) + (255*color(iA)*color(iG));
				pPixel(iB) := 255*(255 - color(iA))*pPixel(iB) + (255*color(iA)*color(iB));
   end;
 
	  function Min(A,B : Integer) return Integer is
		  -- Return the min of A and B
   begin
      if A <= B then
         return A ;
      else
         return B ;
      end if ;
   end ;

   function Max(A,B : Integer) return Integer is
	   -- return the max of A and B
   begin
      if A <= B then
         return B ;
      else
         return A ;
      end if ;
   end ;


   function Check (X,Y,XLMin,YLMin,XLMax,YLMax: Integer) return Boolean is
	   -- Return true if (x,y) inside te rectangle determined by (XLMin, YLMin),(XLMax, YLMax)
   begin
      if X >= XLMin and X <= XLMax and Y >= YLMin and Y <= YLMax then
         return True ;
      else
         return False ;
      end if ;
   end Check ;

   procedure X_MinMax (P: in PointPtr; min, max : out integer) is
	   Tmp : PointPtr := P.next;
   begin
 	   Min := P.X ;
 	   Max := P.X ;
 	   while Tmp /= null loop
  		   if Tmp.X < Min then
   			   Min := Tmp.X ;
  		   elsif Tmp.X > Max then
   			   Max := Tmp.X ;
  		   end if ;
  		   Tmp := Tmp.Next ;
 	   end loop ;
   end X_MinMax;
   
   procedure erasePoints(Points : pointPtr) is
	   -- Liberate memory allocated by points
	pCurr, pNext, Tmp : PointPtr;
   begin
	pCurr := Points;
	while pCurr /= null loop
		pNext := pCurr.next;
		Tmp := pCurr;
		free(Tmp);
		pCurr := pNext;
	end loop;
   end erasePoints;

  

  ----------------------------------------------------------------------------------------------------------------------
  -- Procedures pour Polygone ------------------------------------------------------------------------------------------
  ---------------------------------------------------------------------------------------------------------------------- 
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
	   -- Determine Ymin and return the corresponding X
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
	   -- Update the sides used in the polygon algorithm
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

   -- procedure to free the memory occupied by points
   procedure Liberer is new Ada.Unchecked_Deallocation (Point,PointPtr);

  -- Ex_DrawLine

  procedure Ex_DrawLine  (anImage                 : Image;
                          xMin, yMin, xMax, yMax  : Integer;
                          color                   : Pixel) is
						  -- Example of drawline, not used at all
    e           : Integer;
    x_i, y_i    : Integer;
    dx, dy      : Integer;
    pPtr        : PixelPtr;

  begin

    dx          := xMax - xMin;
    dy          := yMax - yMin;
    e           := 0;
    x_i         := xMin;
    y_i         := yMin;

    pPtr        := anImage.basePixel + ptrdiff_t (anImage.width * yMin + xMin);

    while x_i <= xMax loop
      pPtr.all  := color;

      x_i       := x_i + 1;
      Increment (pPtr);

      e         := e + dy;
      if 2*e > dx then
        y_i     := y_i + 1;
        pPtr    := pPtr + ptrdiff_t (anImage.width);

        e       := e - dx;
      end if;

    end loop;

  end;





  function Inside(Point:PointPtr;ClipRect:RectanglePtr;WBoundary:Boundary) return Boolean is
	  -- Returns true if the point is inside one of the rectangle's sides (side determined by boundary)
  begin


     if WBoundary=Left and then Point.X >= ClipRect.TopLeft.X then
           return True;

     elsif WBoundary = Right and then Point.X<=ClipRect.bottomRight.X then
        return True;
     elsif WBoundary=Upper and then Point.Y>=ClipRect.topLeft.Y then
        return True;
     elsif WBoundary=Lower and then Point.Y<=ClipRect.bottomRight.Y then
        return True;
     else
        return False;
     end if;

end Inside;

       procedure Intersect(ClipRect: in RectanglePtr;Point1,Point2: in PointPtr;WBoundary:Boundary; Intersection: out PointPtr) is
          ---requires: Intersection of the half Plane determined by Boundary and of the segment defined by points 1 and 2 exists.          ---guarantees: Intersection points to the intersection point

          YI,XI:Integer;
          M:float;

       begin
          if Point1.X/=Point2.X then
             M:=(Float(Point2.Y-Point1.Y))/Float((Point2.X-Point1.X));
          end if;

          if WBoundary=Upper or WBoundary=Lower  then
                if  WBoundary= Upper then
                   YI:=ClipRect.topLeft.Y;

                elsif  WBoundary=Lower then
                   YI:=ClipRect.bottomRight.Y;
                end if;
                if Point1.X/=Point2.X then
                    XI:=Integer(Float((YI-Point2.Y))/M+Float(Point2.X));
                 else
                   XI:=Point1.X;
                end if;

          else
             if WBoundary=Left then
                XI:=ClipRect.topLeft.X;
             else
                XI:=ClipRect.bottomRight.X;
             end if;
              YI:=Integer(M*Float((XI-Point2.X))+Float(Point2.Y));
          end if;
          Intersection:=new Point'(XI,YI,null);
       end Intersect;

        procedure SutherlandHodgmanClip(Poly:in PointPtr;PolygonClip:out PointPtr; ClipRect:in RectanglePtr;TheBoundary:Boundary) is
          S,P:PointPtr:=Poly;
          Tail:PointPtr;
          I:PointPtr;
          Senti:PointPtr;
        begin
           if S=null then
			  return;
           end if;

          while S.next/=null loop
             S:=S.Next;
          end loop;    --S is set to the last point of the polygon, P to the first
          Senti:=new Point;
          Tail:=Senti;
          while P/=null loop
             if Inside(P,ClipRect,TheBoundary) then
                if Inside(S,ClipRect,TheBoundary) then
                   Tail.Next:=new Point'(P.X,P.Y,null);
                   Tail:=Tail.Next;
                else
                   Intersect(ClipRect,S,P,TheBoundary,I);
                   Tail.Next:=I; --insert intersection if s outside and P inside
                   Tail:=Tail.Next;
                   Tail.Next:=new Point'(P.X,P.Y,null); --insert P
                   Tail:=Tail.Next;
                end if;

             elsif Inside(S,ClipRect,TheBoundary) then
                Intersect(ClipRect,S,P,TheBoundary,I);
                Tail.Next:=I;
                Tail:=Tail.Next;  --P is outside so we insert only the intersection with the Boundary
             --nothing to do if both S and P are outside
             end if;
             S:=P;
             P:=P.Next;
          end loop;
          
		  PolygonClip:=Senti.Next;
		  Liberer(Senti);
       end SutherlandHodgmanClip;


       function PolygonClipping(Points:PointPtr;ClipRect:RectanglePtr) return PointPtr is
       Poly1,Poly2,Poly3,Poly4:PointPtr;
       Curr:PointPtr;
       begin

          SutherlandHodgmanClip(Points,Poly1,ClipRect,Left);
          SutherlandHodgmanClip(Poly1,Poly2,ClipRect,Upper);
          SutherlandHodgmanClip(Poly2,Poly3,ClipRect, Right);
          SutherlandHodgmanClip(Poly3,Poly4,ClipRect,Lower);

          while Poly1/=null loop
              Curr:=Poly1;
              Poly1:=Poly1.Next;
              Liberer(Curr);
           end loop;
 
           while Poly2/=null loop
              Curr:=Poly2;
              Poly2:=Poly2.Next;
              Liberer(Curr);
           end loop;
 
           while Poly3/=null loop
              Curr:=Poly3;
              Poly3:=Poly3.Next;
              Liberer(Curr);
           end loop;

          return Poly4;

       end PolygonClipping;



end Aux_Fct;
