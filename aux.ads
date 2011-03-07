Package Aux is

	--Point data type
   type Point;
   type PointPtr is access all Point;

   type Point is record
      x, y          : Integer;
      next          : PointPtr;
   end record;

   -- Rectangle data type
   type Rectangle is record
      topLeft, bottomRight : Point;
   end record;

   type RectanglePtr is access all Rectangle;  

   type Side;
   type SidePtr is access all Side;

   type Side is record
      Ymax, X_Ymin    : Integer;
      Dx, Dy          : Integer;
      Next            : SidePtr;
   end record;

   function Min(A,B : Integer) return Integer;

   function Max(A,B : Integer) return Integer;

   procedure Ymax_min (P: in PointPtr; Min, Max : out Integer);
   
   function XYMin(point1, point2: PointPtr) return integer;
   
   procedure Insert_Side(P1, P2: PointPtr; Sides: in out SidePtr);

   procedure Insert_Side(Sides  : in SidePtr; Table : in out SidePtr);

   procedure Update_Sides(Sides : in out SidePtr; line : in Natural);

end Aux;

