with  Ada_SDL_Video, Interfaces.C, Gr_Shapes, Aux_Fct, Drawline_Pkg ;
use   Ada_SDL_Video, Interfaces.C, Ada_SDL_Video.PixelPtrPkg, Gr_Shapes, Aux_Fct, Drawline_Pkg ;
package body Circle_Pkg is

 procedure Cercle(animage: ImagePtr; M, D: PointPtr; Color: Pixel) is
	 -- Draw an empty circle
	  X : Integer := M.X;
	  Y : Integer := M.Y;
	  Rayon : Integer := max(abs(D.X - M.X), abs((D.Y - M.Y)));
      Di,Xx,Yy,X0,X1,X2,X3,X4,X5,X6,X7,Y0,Y1,Y2,Y3,Y4,Y5,Y6,Y7: Integer ;
      PPtr: PixelPtr ;
   begin
      X0:= X ;
      Y0:= Y + Rayon ;
      X1:= X0 ;
      Y1:= Y0 ;
      pPtr:= anImage.basePixel + ptrdiff_t (anImage.width * Y0 + X0);
      PaintPixel(anImage,PPtr,Color) ;
      X2:= X ;
      Y2:= Y - Rayon ;
      X3:= X2 ;
      Y3:= Y2 ;
      pPtr:= anImage.basePixel + ptrdiff_t (anImage.width * Y2 + X2);
      PaintPixel(anImage,PPtr,Color) ;
      X4:= X + Rayon;
      Y4:= Y ;
      X6:= X4 ;
      Y6:= Y4 ;
      pPtr:= anImage.basePixel + ptrdiff_t (anImage.width * Y4 + X4);
      PaintPixel(anImage,PPtr,Color) ;
      X5:= X - Rayon;
      Y5:= Y ;
      X7:= X5 ;
      Y7:= Y5 ;
      pPtr:= anImage.basePixel + ptrdiff_t (anImage.width * Y5 + X5);
      PaintPixel(anImage,PPtr,Color) ;

      Di:= 3 - 2*Rayon ;
      Xx:= 0 ;
      Yy:= Rayon ;

      while Xx < Yy loop
         if Di < 0 then
            Di:= Di + 4*Xx + 6 ;
         else
            Di:= Di + 4*(Xx-Yy) + 10 ;
            Yy:= Yy - 1 ;
            Y0:= Y0 - 1 ;
            Y1:= Y1 - 1 ;
            Y2:= Y2 + 1 ;
            Y3:= Y3 + 1 ;
            X4:= X4 - 1 ;
            X5:= X5 + 1 ;
            X6:= X6 - 1 ;
            X7:= X7 + 1 ;
         end if ;
         Xx:= Xx + 1 ;
         X0:= X0 + 1 ;
         X1:= X1 - 1 ;
         X2:= X2 + 1 ;
         X3:= X3 - 1 ;
         Y4:= Y4 + 1 ;
         Y5:= Y5 + 1 ;
         Y6:= Y6 - 1 ;
         Y7:= Y7 - 1 ;
         pPtr:= anImage.basePixel + ptrdiff_t (anImage.width * Y0 + X0);
      PaintPixel(anImage,PPtr,Color) ;
         pPtr:= anImage.basePixel + ptrdiff_t (anImage.width * Y1 + X1);
      PaintPixel(anImage,PPtr,Color) ;
         pPtr:= anImage.basePixel + ptrdiff_t (anImage.width * Y2 + X2);
      PaintPixel(anImage,PPtr,Color) ;
         pPtr:= anImage.basePixel + ptrdiff_t (anImage.width * Y3 + X3);
      PaintPixel(anImage,PPtr,Color) ;
         pPtr:= anImage.basePixel + ptrdiff_t (anImage.width * Y4 + X4);
      PaintPixel(anImage,PPtr,Color) ;
         pPtr:= anImage.basePixel + ptrdiff_t (anImage.width * Y5 + X5);
      PaintPixel(anImage,PPtr,Color) ;
         pPtr:= anImage.basePixel + ptrdiff_t (anImage.width * Y6 + X6);
      PaintPixel(anImage,PPtr,Color) ;
         pPtr:= anImage.basePixel + ptrdiff_t (anImage.width * Y7 + X7);
      PaintPixel(anImage,PPtr,Color) ;
      end loop ;
   end ;


   procedure CercleRempli(animage: ImagePtr; M, D: PointPtr; Color: Pixel; ClipRect : RectanglePtr := null) is
	   -- Draw a filled circle
      X : Integer := M.X;
	  Y : Integer := M.Y;
	  Rayon : Integer := max(abs(M.x - D.x), abs(M.y - D.y));
	  Xc: Integer:= 0 ;
      Yc: Integer ;
      P: Integer ;
   begin
	   Yc := Rayon;
      P:= 3 - 2*Rayon ;
      while Xc <= Yc loop
         DrawLine(animage, new point'(X+Yc,Y+Xc,new point'(X-Yc,Y+Xc, null)),Color, ClipRect) ;
         DrawLine(animage,new point'(X+Yc,Y-Xc, new point'(X-Yc,Y-Xc, null)),Color, ClipRect) ;
         DrawLine(animage,new point'(X+Xc,Y+Yc, new point'(X+Xc,Y-Yc, null)),Color, ClipRect) ;
         DrawLine(animage,new point'(X-Xc,Y+Yc, new point'(X-Xc,Y-Yc, null)),Color, ClipRect) ;
         if P < 0 then
            P:= P + Xc*4 + 6 ;
            Xc:= Xc + 1 ;
         else
            P:= P + (Xc - Yc)*4 + 10 ;
            Xc:= Xc + 1 ;
            Yc:= Yc - 1 ;
         end if ;
      end loop ;
   end ;
end Circle_Pkg;

