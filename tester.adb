with Aux, Ada.Integer_Text_Io, Ada.Text_Io;
use Aux, Ada.Integer_Text_Io, Ada.Text_Io;

procedure Tester is
	list			: SidePtr;
	p1, p2, p3, p4	: PointPtr;
	pCurr			: PointPtr;
	sCurr			: SidePtr;
	i				: Natural	:= 0;
begin
	-- declaration of variables
	p4 := new point'(90, 90, null);
	p3 := new point'(30, 90, p4);
	p2 := new point'(90, 30, p3);
	p1 := new point'(30, 30, p2);

	put_line("4 punkter ger 4 sidor");

	-- Create the table of sides
	pCurr := p1; 
	while pCurr.next /= null loop
		insert_side(pCurr, pCurr.next, list);
		pCurr := pCurr.next;
	end loop;
	insert_side(p4, p1, list);

	sCurr := list;
	while sCurr /= null loop
		i := i+1;
		sCurr := sCurr.next;
	end loop;
	put(i); put_line(" sidor i listan");

	sCurr := list;
	i := 1;
	while sCurr /= null loop
		put("Sida"); put(i); put("s X(Ymin) värde är :"); Put(Scurr.X_Ymin); put(" och Ymax är"); Put(Scurr.Ymax); put(" dX är:"); put(Scurr.dx); New_Line;
		sCurr := sCurr.next;
		i := i+1;
	end loop;

	New_line;

	for j in 30..34 loop
		put_line("Sortera listan");
		Update_Sides(list, j);
		
		sCurr := list;
		i := 0;
		while sCurr /= null loop
			i := i+1;
			sCurr := sCurr.next;
		end loop;
		put(i); put_line(" sidor i listan");
		
		sCurr := list;
		i := 1;
		while sCurr /= null loop
			put("Sida"); put(i); put(" X(Ymin) :"); Put(Scurr.X_Ymin); put(" Ymax :"); Put(Scurr.Ymax); put(" dX :"); put(Scurr.dx); New_Line;
			sCurr := sCurr.next;
			i := i+1;
		end loop;
	end loop;
end	Tester;

