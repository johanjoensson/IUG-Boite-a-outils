with Ada.Unchecked_Deallocation, Ada.Text_Io;
use Ada.Text_Io;

package body Aux is

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
         if Min(P1.X, P2.X) < Cour.X_Ymin then
            --the side is to be inserted in the middle or the beginning of the list
            Tmp := new Side;
	    -- Calculate the value of Ymax
            Tmp.Ymax := Max(P1.Y, P2.Y);
	    -- Determine the value of X(Ymin)
            if Tmp.Ymax = P1.Y then
               Tmp.X_Ymin := P1.X;
            else
               Tmp.X_Ymin := P2.X;
            end if;
	    -- Insert Tmp correctly
            Tmp.Next := Cour;
            if Prec /= null then
	    -- Tmp will be inserted in the middle of an existing list
               Prec.next := Tmp;
            else
	    -- Tmp will be inserted in the beginning of a list
               Sides := Tmp;
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
            Tmp.X_Ymin := P1.X;
         else
            Tmp.X_Ymin := P2.X;
         end if;
         if Sides = null then
         --Side is to be inserted first in the list
         --because there are no sides currently in the list
            Sides := Tmp;
            Tmp.Next := Null;
         else
            --the side is to be inserted in the end of the list
            Tmp.Next := Null;
            Prec.next := Tmp;
         end if;
      end if;
	  Tmp.Dy := P2.Y - P1.Y;
	  Tmp.Dx := P2.X - P1.X;
   end Insert_Side;


	   -- Insert sides into a table of sides
   procedure Insert_Side(Sides  : in SidePtr; Table : in out SidePtr) is
    current_side,next_side              : SidePtr   := Sides;
    current_table, former_table         : SidePtr;  
    inserted                            : Boolean   := False;
   begin
    while current_side /= null loop
		former_table := null;
		current_table := Table;
        next_side := current_side.next;    
        if Table /= null then
            -- Insert side in the middle or at the end of the table
            inserted := false;
            while current_table /= null and not inserted loop
                if current_side.X_Ymin < current_table.X_Ymin then
                    -- Insert side in the middle or the beginning of the table
					if former_table = null then
						-- insert side in the beginning of the table
						current_side.next := current_table;
						current_table := current_side;
--						put_Line("Inserted first in the chain");
					else
						-- insert side in the middle of the table
						former_table.next := current_side;
						current_side.next := current_table;
						current_table := current_side;
						inserted := true;
					end if;
                end if;
                former_table := current_table;
                current_table := current_table.next;
            end loop;
            if not inserted then
                -- Insert side at the end of the table
--                Put_line("Chain ended");
                former_table.next := current_side;
                current_side.next := null;
            end if;
        else
            -- The table is empty, insert side as the first side in the table
--            Put_Line("Chaine started");
            Table := current_side;
            current_side.next := null;
            former_table := Table;
        end if;
        current_side := next_side;
    end loop;
   end Insert_Side;

   -- Remove unnecessary sides, recalculate the x values and sort the list according to the new x values
   procedure Update_Sides(Sides : in out SidePtr; line : in Natural) is
    curr		: SidePtr	:= Sides;
	prec		: SidePtr	:= null;
	next		: SidePtr;
	tmpSides	: SidePtr;	
   begin
	   -- if sides is empty then do nothing
	   if Sides /= null then
		  while curr /= null loop
			  next := curr.next;
			  -- update the values in the list
			  if curr.dy /= 0 then
				  curr.X_Ymin := curr.X_Ymin - curr.dx/curr.dy;
			  end if;

			  -- remove sides from list
   			  if line = curr.Ymax then
				  curr.next := null;
				  tmpSides := curr;
				  if prec /= null then
					  prec.next := next;
					  curr := prec;
				  else
					  -- Error in here!
					  Sides := next;
					  -- curr := null;
					  -- end of error area, I hope
 				  end if;
				  put_line("side removed");
			  end if;
			  free(tmpSides);
			  prec := curr;
			  curr := next;
		  end loop;

		  -- Sort the list
		  curr := Sides;
		  --next := curr.next;
		  prec := null;
		  while curr /=null loop
			  next := curr.next;
			  if next /= null and then curr.X_Ymin > next.X_Ymin then
				  put_line("move one side");
				  if prec /= null then
					  -- Item in the middle out of place
					  put_line("borde hända");
					  prec.next := next;
				  else
					  -- First item out of place
					  put_line("borde inte hända");
					  sides := next;
				  end if;
				  -- Reinsert the side in the list
				  curr.next := null;
				  insert_side(curr, Sides);
				  -- next := Sides;
			  end if;
			  prec := curr;
			  curr := next;
		  end loop;
	   end if;
   end Update_Sides;



end Aux;

