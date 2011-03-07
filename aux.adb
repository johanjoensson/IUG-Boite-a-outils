with Ada.Unchecked_Deallocation;

package body Aux is

	-- Procedure used to manage memory consumption
	procedure free is new Ada.Unchecked_Deallocation (Side,SidePtr);

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


   procedure Ymax_min (P: in PointPtr; Min, Max : out Integer) is
      --Return the maximal and minimal value of Y found amongst the points
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

   function XYMin(point1, point2: PointPtr) return integer is
	   -- Return X(Ymin), if Ymin=Ymax return Xmin
	   res : integer;
   begin
	   if point1.Y < point2.Y then
		   res := point1.X;
	   elsif point2.Y < point1.Y then
		   res := point2.X;
	   else
		   res := min(point1.X, point2.X);
	   end if;
	   return res;
   end XYmin;

   procedure Insert_Side(P1, P2: PointPtr; Sides: in out SidePtr) is
 	   -- Insert the sides of the polygone in the list of sides
	   -- P1 and P2 are the endpoints of the side to be inserted
	   -- Sort according to X_Ymin
      Cour	: Sideptr	:= Sides;	    -- Pointer to a side currently in the list
      Prec	: SidePtr	;			    -- Pointer to the side before Cour
      Tmp	: SidePtr	;			    -- Temporary pointer to the side that is to be inserted in te list

      Inserted	: Boolean	:= False;   -- Boolean to check whether the side has been inserted or not

   begin
	   tmp := new Side'(max(p1.Y,p2.Y),XYmin(p1,p2), (p2.X - p1.X), (p2.Y - p1.Y), null);
	   if Sides /= null then
		   -- Side will be inserted into an existing table
		   while cour /= null and not inserted loop
			   if cour.X_Ymin > Tmp.X_Ymin then
				   if prec = null then
					   -- Insert side as first element in chain
					   Tmp.next := Sides;
					   Sides := Tmp;
				   else
					   -- insert side in the chain
					   prec.next := Tmp;
					   Tmp.next := cour;
					   cour := Tmp;
				   end if;
				   inserted := true;
			   end if;
			   prec := cour;
			   cour := cour.next;
		   end loop;

		   if not inserted then
			   -- Insert side as the last edge of a chain
			   prec.next := Tmp;
		   end if;
	   else
		   -- Create a new table and insert the edge
		   Sides := Tmp;
	   end if;
   end Insert_Side;


	   -- Insert sides into a table of sides, sort according to X_Ymin
   procedure Insert_Side(Sides  : in SidePtr; Table : in out SidePtr) is
    current_side,next_side              : SidePtr   := Sides;		-- Pointers to the sides to be inserted
    current_table, former_table         : SidePtr;					-- Pointers to the sides already in the table
    inserted                            : Boolean   := False;		-- Boolean to see whether or not we've inserted a value already
   begin
	   -- Loop through and insert all the sides to be inserted
	   while current_side /= null loop
		   -- Initialize variables for insertion
		   inserted := false;
		   next_side := current_side.next;
		   current_side.next := null;
		   former_table := null;
		   current_table := table;
		   -- Loop through the table of sides already inserted and insert the current side
		   while current_table /= null and not inserted loop
			   if current_side.X_Ymin < current_table.X_Ymin then
				   if former_table = null then
					   -- Insert edge as first element in chain
					   current_side.next := Table;
					   Table := current_side;
				   else
					   -- Insert side in the middle of the chain
					   former_table.next := current_side;
					   current_side.next := current_table;
					   current_table := current_side;
				   end if;
				   inserted := true;
			   end if;
			   former_table := current_table;
			   current_table := current_table.next;
		   end loop;
		   if not inserted and then former_table = null then
			   -- Insert edge as first edge in a new list
			   table := current_side;
			   inserted := true;
		   elsif not inserted then
			   -- insert at the end of chain
			   former_table.next := current_side;
			   current_side.next := null;
			   inserted := true;
		   end if;
		   current_side := next_side;
	   end loop;
   end Insert_Side;

   -- Remove unnecessary sides, recalculate the x values and sort the list according to the new x values
   procedure Update_Sides(Sides : in out SidePtr; line : in Natural) is
    curr, Sent	: SidePtr	:= Sides;
	prec		: SidePtr	:= null;
	next		: SidePtr;
	tmpSides	: SidePtr;	

   begin
	   while curr /= null loop
		   next := curr.next;

		   -- Update the values
		   if curr.Dy /= 0 then
			   curr.X_Ymin := curr.X_Ymin + curr.Dx/curr.Dy;
		   end if;
		   
		 
		   -- Remove sides
		   if curr.Ymax = line then
			   tmpSides := curr;
			   if prec = null then
				   curr := null;
				   Sent := next;
			   else
				   prec.next := next;
				   curr := prec;
			   end if;
			   free(tmpSides);
		   end if;
		   prec := curr;
		   curr := next;
	   end loop;
	   Sides := Sent;

	   tmpSides := null;

	   -- Sort the chain
	   insert_side(Sides, tmpSides);
	   sides := tmpSides;
   end Update_Sides;



end Aux;

