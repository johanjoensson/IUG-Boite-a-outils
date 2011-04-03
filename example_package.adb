-- example_package.adb --

with  Ada_SDL_Video, Interfaces.C, Gr_Shapes, Ada.Unchecked_Deallocation,Ada.Text_Io;
use   Ada_SDL_Video, Interfaces.C, Ada_SDL_Video.PixelPtrPkg,Gr_Shapes,Ada.Text_Io;

package body Example_Package is
   procedure Liberer is new Ada.Unchecked_Deallocation (Point,PointPtr);

  -- Ex_DrawLine

  procedure Ex_DrawLine  (anImage                 : Image;
                          xMin, yMin, xMax, yMax  : Integer;
                          color                   : Pixel) is
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
		  Dy, Dx : integer;
          M:float;

       begin
          if Point1.X/=Point2.X then
--             M:=(Float(Point2.Y-Point1.Y))/Float((Point2.X-Point1.X));
			 Dx := point2.X - Point1.X;
			 Dy := point2.Y - Point1.y;
          end if;

          if WBoundary=Upper or WBoundary=Lower  then
                if  WBoundary= Upper then
                   YI:=ClipRect.topLeft.Y;

                elsif  WBoundary=Lower then
                   YI:=ClipRect.bottomRight.Y;
                end if;
                if Point1.X/=Point2.X then
--                    XI:=Integer(Float((YI-Point2.Y))/M+Float(Point2.X));
                   XI:=(YI-Point2.Y)/(Dy/Dx)+Point2.X;
                else
                   XI:=Point1.X;
                end if;

          else
             if WBoundary=Left then
                XI:=ClipRect.topLeft.X;
             else
                XI:=ClipRect.bottomRight.X;
             end if;
--              YI:=Integer(M*Float((XI-Point2.X))+Float(Point2.Y));
             YI:=(Dy/Dx)*(XI-Point2.X)+Point2.Y;
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
--              Put_Line("S Est null");
			  return;
           end if;

          while S.next/=null loop
             S:=S.Next;
          end loop;    --S is set to the last point of the polygon, P to the first
          Senti:=new Point;
          Tail:=Senti;
          while P/=null loop
--             Put_Line("P.X= " & Integer'Image(P.X) & "P.Y=" & Integer'Image(P.Y));
--             Put_Line("S.X= " & Integer'Image(S.X) & "S.Y=" & Integer'Image(S.Y));
             if Inside(P,ClipRect,TheBoundary) then
                if Inside(S,ClipRect,TheBoundary) then
                   Tail.Next:=new Point'(P.X,P.Y,null);
                   Tail:=Tail.Next;
--                   Put_Line(Integer'Image(Tail.Y));
                else
                   Intersect(ClipRect,S,P,TheBoundary,I);
                   Tail.Next:=I; --insert intersection if s outside and P inside
                   Tail:=Tail.Next;
                   Tail.Next:=new Point'(P.X,P.Y,null); --insert P
                   Tail:=Tail.Next;
--                   Put_Line(Integer'Image(Tail.Y));
                end if;

             elsif Inside(S,ClipRect,TheBoundary) then
                Intersect(ClipRect,S,P,TheBoundary,I);
                Tail.Next:=I;
                Tail:=Tail.Next;  --P is outside so we insert only the intersection with the Boundary
--                Put_Line(Integer'Image(Tail.Y));
             --nothing to do if both S and P are outside
             end if;
             S:=P;
             P:=P.Next;
          end loop;
--          if Senti.Next=null then
--              Put_Line("pb");
--           end if;
-- 
          PolygonClip:=Senti.Next;
--          Put_Line("SuthH fini, PolygonClip.Y=" & Integer'Image(PolygonClip.Y));
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





end Example_Package;

