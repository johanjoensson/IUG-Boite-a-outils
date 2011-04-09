with Ada_SDL_Video, Ada.Unchecked_Deallocation, Gr_Shapes ;
use Ada_SDL_Video, Ada_SDL_Video.PixelPtrPkg, Gr_Shapes ;

package body Aux_Fct is
	 procedure Liberer is new Ada.Unchecked_Deallocation (Cote,CotePtr);
   procedure Liberer is new Ada.Unchecked_Deallocation (Point,PointPtr);


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
		if color(iA) /= 0 and then color(iA) /= 255 then
	 		pPixel(iR) := (color(iA))*pPixel(iR) + (255 - color(iA)+1)* color(iR);
	 		pPixel(iG) := (color(iA))*pPixel(iG) + (255 - color(iA)+1)* color(iG);
			pPixel(iB) := (color(iA))*pPixel(iB) + (255 - color(iA)+1)* color(iB); 
		elsif color(iA) = 255 then
			pPixel.all:=color;
		end if;
   end;
 
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

end Aux_Fct;
