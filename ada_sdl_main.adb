-- ada_sdl_main.adb --
--
--  Example of a main program using the Ada_SDL library.
--  This should be replaced by your program.


with
  Ada.Text_IO, Interfaces.C,
  Ada_SDL_Init, Ada_SDL_Video, Ada_SDL_Event, Ada_SDL_Mouse, Ada_SDL_Keyboard,
  Ada_ManyMouse,
  Gr_Shapes, Aux_Fct, Example_Package, Event_Handling, Drawline_Pkg, Circle_Pkg, Ada.Numerics.Elementary_Functions ;
use
  Ada.Text_IO, Interfaces.C,
  Ada_SDL_Init, Ada_SDL_Video, Ada_SDL_Event, Ada_SDL_Mouse, Ada_SDL_Keyboard,
  Ada_ManyMouse,
  Gr_Shapes, Aux_Fct, Example_Package, Event_Handling, Drawline_Pkg, Circle_Pkg, Ada.Numerics.Elementary_Functions ;

use
  Ada_SDL_Video.PixelPtrPkg;

package body Ada_SDL_Main is

  function Ada_SDL_Main_Function return Integer is
    surface         : SDL_SurfacePtr;                         -- The main window
    event           : SDL_EventPtr;                           -- Where to store details of the received event
    res             : Integer             := 0;               -- Error code returned by some functions (0 = no error)
    width           : Integer             := 800;             -- Width of the main window
    height          : Integer             := 480;             -- Height of the main window
    iR, iG, iB, iA  : Integer;                                -- Channel indices: where is "red", "green", ... in the pixel ?

    offset          : constant            := 20;              -- Width of the black border when drawing the red rectangle
    red             : Pixel               := (0, 0, 0, 0);    -- We will construct a red pixel in this (including opaque alpha)
    blue            : Pixel               := (0, 0, 0, 0);    -- We will construct a blue pixel in this (including opaque alpha)
    black           : Pixel               := (0, 0, 0, 0);    -- We will construct a black pixel in this (including opaque alpha)
	green			: Pixel				  := (0, 0, 0, 0);	  -- We will construct a green pixel in this (including opaque alpha)
	white			: Pixel				  := (0, 0, 0, 0);	  -- We xill construct a xhite pixel in this (including opaque alpha) 
	nullPixel		: Pixel				  := (0, 0, 0, 0);
    pixels, lines   : PixelPtr;                               -- Pointers to pixels, used in scanline algorithms

    key             : SDL_Key;                                -- The number of the keyboard key that was pressed
    modKey          : SDL_ModKey;                             -- The number of the keyboard mod key (alt, shift, ...) that was pressed

    eventType       : Uint8;                                  -- The code representing the event type (keyboard press, mouse motion, ...)
    buttonNb        : Uint8;                                  -- The number of the mouse button that was depressed or released
    buttonStates    : Uint8;                                  -- A bitmap of the mouse button state when a mouse motion event is received
    x, y            : Uint16;                                 -- Used in loops, and to retrieve mouse motion even parameters
    xrel, yrel      : Sint16;                                 -- Used to retrieve mouse motion even parameters

    doManyMouse     : Boolean             := false;           -- True if trying to implement multiple mice
    nbMice          : Integer;                                -- Number of mice connected to the computer
    mouseRec        : MousePtr;                               -- Retrieves mouse information when using multiple mice

    myImage         : Image;                                  -- An image structure used to call the Ex_DrawLine primitive

    myImagePtr      : ImagePtr;
    P1,P2,P3,P4  : PointPtr ;
	m1,m2,m3,m4,m5,m6,m7	: PointPtr ;
	mouseColor		: Pixel;
	mx, my, mxrel, myrel	: Integer ;
    Cour          : PointPtr ;
    ClipRect, oldClipRect   : RectanglePtr ;
	Greentran		: Pixel					:= (0,0,0,0);

	Zen				: Nirvana;
	offScreen		: SDL_SurfacePtr;
	offscreenImage	: Image;
	offScreenImagePtr	: ImagePtr;
	offPixels		: PixelPtr;
	mousePoint		: point;
	moveShape		: Boolean	:= False;
	ShapeMoved		: ShapePtr;
	ShapeType		: OBJECT;
	PCurr			: PointPtr;
	oldXmin, oldXmax, oldYmin, oldYmax	: Integer;
	Xmin, Xmax, Ymin, Ymax	: Integer;
	maxPrio			: Pixel					:= (0, 0, 0, 0);

	toolglassactive: Boolean := False;	
	ToolglassOffscreen	: SDL_SurfacePtr;
	ToolglassoffscreenImage	: Image;
	ToolglassoffScreenImagePtr	: ImagePtr;
	ToolglassoffPixels, ToolglassOffLines		: PixelPtr;
 	ToolglassActivated	: Boolean	:= False;
	ToolglassPos	: PointPtr	:= new point;
	ActiveFunction	: Boolean	:= false;

	fPoint,nPoint, tmpPoint	: PointPtr	;
	CurrColor				: Pixel ;
	DrawlineActive			: Boolean	:= False;
	PolylineActive			: Boolean	:= False;
	PolygonActive			: Boolean	:= False;
	CircleActive			: Boolean	:= False;
	FilledCircleActive		: Boolean	:= False;
	Radius					: Integer	;

	

  begin

    -- Initialize the ManyMouse package if required.

	  oldClipRect := new rectangle;
	  TmpPoint := new Point;
    if doManyMouse then
      Ada_MM_InitMice;
      nbMice        := Integer (Ada_MM_AvailableMice);
      Put_Line ("Number of mice: " & Integer'Image (nbMice));
    end if;

    -- Create the window on which everything is drawn, and receiving mouse and keyboard events.

    surface         := Ada_SDL_CreateWindow (width, height);
	offScreen		:= Ada_SDL_CreateOffscreen (surface,width, height);
	toolglassOffscreen	:= Ada_SDL_CreateOffscreen (surface,width, height);

    if surface = null then
      return -1;
    end if;

    -- Get the indices of the red, green, blue and alpha channel in pixels of this window

    Ada_SDL_GetSurfaceChannelIdx (surface, iR, iG, iB, iA);
	iA := 6 - (iR + iG + iB);

    -- Create the color values (red, blue, black). Set alpha to 255 (opaque) if transparency is
    --  handled on this window.

    red(iR)         := 255;
    blue(iB)        := 255;
	green(iG)		:= 255;
	white(iR)		:= 255;
	white(iG)		:= 255;
	white(iB)		:= 255;
	Greentran(iG)	:= 255;
    if (iA /= -1) then
      red(iA)       := 255;
      blue(iA)      := 255;
	  green(iA)		:= 255;
      black(iA)     := 255;
	  white(iA)		:= 255;
	  Greentran(iA)	:= 128;
	  maxPrio(iA)	:= 255;
    end if;
	currColor := Blue;

    -- Prepare to draw in the window: get exclusive access to its memory,
    --  get a pointer to the first pixel.

    res             := SDL_LockSurface (surface);
    pixels          := Ada_SDL_GetPixelPtr (surface);
	offPixels		:= Ada_SDL_GetPixelPtr (offScreen);
	ToolglassOffPixels	:= Ada_SDL_GetPixelPtr (ToolglassOffScreen);



    -- Erase the window: set all its pixels to black.

    for y in 1 .. height loop
      for x in 1 .. width loop
        pixels.all := black;
		offPixels.all := black;
		toolGlassOffPixels.all	:= nullPixel;
        Increment (pixels);
        Increment (offPixels);
		increment (toolglassOffPixels);
      end loop;
    end loop;

	p4  :=  new point'(1, height, null);
	p3	:=  new point'(width,height,p4);
	p2	:=  new	point'(width,1,p3);
	p1	:=  new point'(1,1,p2);
	cour := p1;
	insert_Shape(Zen(Canvas), new shape'(p1, Black, maxPrio, null));
	-- Increase the priority for the next Canvas object
	--increasePrio(maxPrio, iR, iG, iB, iA);

    -- Draw a big red rectangle in the window, leaving only a border of <margin> black pixels
    --  on every sides.

    lines           := Ada_SDL_GetPixelPtr (surface);
    lines           := lines + ptrdiff_t (offset * width + offset);

    for y in reverse 0 .. height - 2 * offset - 1 loop
      pixels        := lines;
      for x in reverse 0 .. width - 2 * offset - 1 loop
        pixels.all  := white;
        Increment (pixels);
      end loop;
      lines         := lines + ptrdiff_t (width);
    end loop;

	p4  := new point'(offset, height - offset, null);
	p3	:= new point'(width - offset -1, height - offset,p4);
	p2	:= new point'(width - offset -1,offset,p3);
	p1	:= new point'(offset ,offset,p2);
	insert_shape(Zen(Canvas), new shape'(p1, white, maxPrio, null));
	-- Reset the priority, objects will not be added to the canvas
	maxPrio(iR) := 1;
	
   	-- Fill-in an Image record in order to all the "Ex_DrawLine" drawing primitive,
    --  then draw a line.

    myImage.basePixel := Ada_SDL_GetPixelPtr (surface);
    myImage.iR        := iR;
    myImage.iG        := iG;
    myImage.iB        := iB;
    myImage.iA        := iA;
    myImage.width     := width;
    myImage.height    := height;

	offScreenImage.basePixel := Ada_SDL_GetPixelPtr (offScreen);
	offScreenImage.iR		:= iR;
	offScreenImage.iG		:= iG;
	offScreenImage.iB		:= iB;
	offScreenImage.iA		:= iA;
	offScreenImage.width	:= width;
	offScreenImage.height	:= height;

	ToolglassOffscreenImage.basePixel	:= Ada_SDL_GetPixelPtr (toolGlassoffscreen);
	ToolglassoffScreenImage.iR		:= iR;
	ToolGlassoffScreenImage.iG		:= iG;
	ToolGlassoffScreenImage.iB		:= iB;
	ToolGlassoffScreenImage.iA		:= iA;
	ToolglassoffScreenImage.width	:= width;
	ToolglassoffScreenImage.height	:= height;


	offScreenImagePtr	:= new image'(offScreenImage);
    myImagePtr        := new Image'(myImage) ;
	ToolglassOffscreenImagePtr	:= new image'(ToolglassOffscreenImage);
    ClipRect          := new Rectangle'((110,110,null),(120,120,null)) ;

-- 	p4  := new point'(90,90, null);
-- 	p3	:= new point'(50,90,p4);
--  	p2	:= new point'(90,90,null);
-- 	p1	:= new point'(50,50,p2);
-- 	DrawLine(MyImagePtr, p1, Blue);
-- -- 	
-- 	Polygone(myImagePtr,p1,Blue) ;
-- 	polygone(offScreenImagePtr, p1, maxPrio);
-- 
-- 	insert_shape(Zen(Polygone), new Shape'(p1,Blue, maxPrio, null));
-- 	increasePrio(maxPrio, iR, iG, iB, iA);
-- 	
-- 	p3	:=  new point'(80,90,null);
-- 	p2	:=  new point'(120,50,p3);
-- 	p1	:=  new point'(80,50,p2);
-- 	Polygone(myImagePtr,p1,Red) ;
-- 	Polygone(offscreenImagePtr,p1,maxPrio) ;
-- 	insert_shape(Zen(Polygone),  new Shape'(p1,Red, maxPrio, null));
-- 	increasePrio(maxPrio, iR, iG, iB, iA);
-- 
-- 	p2	:=  new point'(120,150,null);
-- 	p1	:=  new point'(120,120,p2);
-- 	CercleRempli(MyImagePtr, p1, p2, Blue);
-- 	CercleRempli(offscreenImagePtr, p1, p2, maxPrio);
-- 	insert_shape(Zen(FilledCircle), new shape'(p1, Blue, maxPrio, null));
-- 	increasePrio(maxPrio, iR, iG, iB, iA);

    -- Release exclusive access to the window's pixel memory, tell the system to
    --  update the entire window on the screen.

     SDL_UnlockSurface (surface);
     SDL_UpdateRect (surface);
     SDL_UnlockSurface (offScreen);
     SDL_UpdateRect (offScreen);
	 SDL_UnlockSurface (ToolglassoffScreen);
     SDL_UpdateRect (ToolglassoffScreen);

 
    --
    -- Now for events and handle them.
    --

    -- Create a recard to store events,
    --  loop infinitely by waiting for a new event, and handling it.

    event := Ada_SDL_AllocateEvent;

	m7	:=	new point;
	m6	:=	new point;
	m5	:=	new point;
	m4  :=  new point;
	m3	:=  new point;
	m2	:=  new	point;
	m1	:=  new point;
	Cliprect := new Rectangle;
	
	mouseColor := Black;

    loop
      res := SDL_WaitEvent (event);
      exit when res /= 1;
      exit when Ada_SDL_EventType (event) = SDL_QUIT;

      if Ada_SDL_EventType (event) = SDL_KEYDOWN then

        -- A keyboard key was depressed.

        Ada_SDL_GetKeyboardEventParams(event, key, modKey);
        if key = SDLK_ESCAPE then
          -- Exit the program when pressing the "escape" key
          exit;
        end if;
        if key = SDLK_m then
          -- Move the system mouse to the center of window when pressing the "m" key
          SDL_WarpMouse (Uint16 (width / 2),  Uint16 (height / 2));
        end if;

		if key = SDLK_p then
			p3 := new point'(90, 90, null);
			p2 := new point'(120, 90, p3);
			p1 := new point'(120, 120, p2);
			res := SDL_LockSurface (surface);
			Polygone(myImagePtr,p1,Blue) ;
			Polygone(offscreenImagePtr,p1,maxPrio) ;
			insert_shape(Zen(Polygone),  new Shape'(p1,Blue, maxPrio, null));
			increasePrio(maxPrio, iR, iG, iB, iA);
			SDL_UnlockSurface (surface);
			SDL_UpdateRect (surface);

		end if;
      end if;

      if Ada_SDL_EventType (event) = SDL_MOUSEMOTION then

		  --res := SDL_LockSurface (surface);

        -- The mouse moved

        Ada_SDL_GetMouseMotionEventParams (event, buttonStates, x, y, xrel, yrel);
		mx := integer(x);
		my := integer(y);
		mxrel := integer(xrel);
		myrel := integer(yrel);
		mousePoint := (mx-mxrel, my-myrel, null);-- Ancien position de souris


-- 		if not moveShape then
				
		-- Draw the mouse in it's new position
		if not Toolglassactive then
			-- Erase the old image of the mouse
			 
			ClipRect.topLeft := mousePoint; 		
			ClipRect.bottomRight := (mousePoint.x +15, mousePoint.y+15, null);
			RedrawWindow(myImagePtr, Zen, ClipRect);
	
			-- If necessary repair the Toolglass
			if (mx >= ToolglassPos.x - 15 and mx <= ToolglassPos.x + 95) and then (my >= Toolglasspos.y - 15 and my <= Toolglasspos.y + 175) then
				DrawtoolGlass(MyImagePtr, ToolglassPos.x, ToolglassPos.y, ir, iG, iB, iA, ClipRect);
			end if;
			
			SDL_UnlockSurface (surface);
			SDL_UpdateRect (surface, Sint32(ClipRect.topLeft.X), Sint32 (ClipRect.topLeft.Y), Uint32(15), Uint32(15));



			-- Determine all points for the pointer

            if my+14 >= Height then
               M7.all:= (mx,Height,null) ;
            else
               M7.all:= (mx, my+14,null);
            end if ;
            if my+10 >= Height then
               M6.all:= (mx+4,Height,M7) ;
            else
               M6.all:= (mx+4,my+10,M7);
            end if ;
            if my+15 >= Height then
               M5.all:= (mx+6,Height,M6) ;
            else
               M5.all:= (mx+6,my+15,M6);
            end if ;
            if my+13 >= Height then
               M4.all:= (mx+7,Height,M5) ;
            else
               M4.all:= (mx+7,my+12,M5);
            end if ;
            if my+10 >= Height then
               M3.all:= (mx+5,Height,M4);
               M2.all:= (mx+10,Height,M3) ;
            else
               M3.all:= (mx+6,my+10,M4);
               M2.all:= (mx+10,my+10,M3);
            end if ;
            M1.all := (mx,my,M2);

			-- Draw and show the pointer
            Polygone(myImagePtr,M1,mouseColor) ;
			SDL_UnlockSurface (surface);
			SDL_UpdateRect (surface,Sint32(mx), Sint32 (my), Uint32(15), Uint32(15)) ;
			-- mouse drawn, phew...

		else
			-- Delete the old picture of the toolglass
 			ClipRect.topLeft := mousepoint;
 			ClipRect.bottomRight := (mousepoint.x + 80, mousepoint.y + 161, null);
 			RedrawWindow(MyImagePtr, Zen, ClipRect);
 			SDL_UnlockSurface (surface);
  			SDL_UpdateRect (surface, Sint32(ClipRect.TopLeft.x), Sint32(ClipRect.topLeft.y), Uint32(81), Uint32(161));
 

			-- Draw the Toolglass
			DrawToolGlass(MyImagePtr, mx, my, iR, iG, iB, iA); 
			SDL_UnlockSurface (surface);
			SDL_UpdateRect (surface, Sint32(mx), Sint32(my), Uint32(81), Uint32(161));
		-- 			SDL_UnlockSurface (surface);
-- 			SDL_UpdateRect (surface, Sint32(ClipRect.topLeft.x), Sint32(ClipRect.topLeft.y), Uint32(90), Uint32(170));
         end if ;
		 -- Mouse of toolglass Drawn
		 
-- 		 if DrawlineActive then
-- 			 -- Draw a line from the old point (nPoint) to the current mouse position
-- 			 put_line("Drawing a line");
-- 			 TmpPoint. all := (mx,my, null);
-- 			 nPoint.next := tmpPoint;
-- 			 ClipRect.topLeft	:= (min(mx, nPoint.x), min(my, nPoint.y), null);
-- 			 ClipRect.bottomRight	:= (max(mx, nPoint.x), max(my, nPoint.y), null);
--  			 RedrawWindow(MyImagePtr, Zen, ClipRect);
-- 			 Drawline(MyImagePtr, nPoint, CurrColor);
-- 			 SDL_UnlockSurface (surface);
--  			 SDL_UpdateRect (surface, Sint32(ClipRect.topLeft.x), Sint32(ClipRect.topleft.y), Uint32(ClipRect.bottomRight.x - ClipRect.topLeft.x), Uint32(ClipRect.bottomRight.y - ClipRect.topLeft.y));
-- 		 end if;


-- 		  else
-- 		  -- Move a polygone!
-- 		  --
-- 		  PCurr := ShapeMoved.PStart;
-- 		  -- Erase old picture
-- 		  Initscanline(PCurr, Ymin, Ymax);
-- 		  X_MinMax(PCurr, Xmin, XMax);
-- 		  ClipRect.topLeft := (Xmin, Ymin, null);
-- 		  ClipRect.bottomRight := (Xmax, Ymax, null);
--   
-- 		  -- Update the points in the moved shape
-- 		  while PCurr /= null loop
-- 			 PCurr.X := PCurr.X + mxrel;
-- 			 PCurr.Y := PCurr.Y + myrel;
-- 			 PCurr := PCurr.next;
-- 		  end loop;
-- 
-- 		  
--   		  RedrawWindow(myImagePtr,Zen, ClipRect);
-- 		  --RedrawOffscreen(OffscreenImagePtr, Zen, ClipRect);
--   
-- 		  SDL_UnlockSurface (surface);
--   		  SDL_UpdateRect (surface, Sint32(ClipRect.topLeft.X), Sint32 (ClipRect.topLeft.Y), Uint32(ClipRect.bottomRight.X - ClipRect.topLeft.X +1), Uint32(ClipRect.bottomRight.Y - ClipRect.topLeft.Y +1));
--  
-- 		  
-- 		  Initscanline(ShapeMoved.Pstart, Ymin, Ymax);
-- 		  X_MinMax(ShapeMoved.Pstart, Xmin, XMax);
--   		  ClipRect.topLeft := (Xmin, Ymin, null);
-- 		  ClipRect.bottomRight := (Xmax, Ymax, null);
-- 		  --Polygone(myImagePtr, ShapeMoved.Pstart, ShapeMoved.Color, ClipRect);
-- 		  RedrawWindow(myImagePtr,Zen, ClipRect);
-- 		  --RedrawOffscreen(OffscreenImagePtr, Zen, ClipRect);
-- 
-- 		SDL_UnlockSurface (surface);
-- 		SDL_UpdateRect (surface, Sint32(Xmin), Sint32 (Ymin), Uint32(Xmax - Xmin), Uint32(Ymax - Ymin));
-- 
-- 
-- 
-- 
-- 		end if;




        if not doManyMouse then

          -- We are only handling one mouse.

--          Put_Line ("Motion, x = " & Integer'Image (Integer (x)) & ", y = " & Integer'Image (Integer (y))                     & ", xrel = " & Integer'Image (Integer (xrel)) & ", yrel = " & Integer'Image (Integer (yrel)));
			mx:=mx;
        else

          -- We are using multiple mice, loop for all mice, reading and displaying their state for each.

          Ada_MM_UpdateMice;
          for m in 0 .. nbMice - 1 loop
            mouseRec    := Ada_MM_MouseRecord (int (m));
            Put ("Mouse " & Integer'Image (m) & ": ");
            Put_Line  ("x = " & Integer'Image (Integer (mouseRec.x)) &
                      " y = " & Integer'Image (Integer (mouseRec.y)));
          end loop;
        end if;

      end if;

      if Ada_SDL_EventType (event) = SDL_MOUSEBUTTONDOWN or
         Ada_SDL_EventType (event) = SDL_MOUSEBUTTONUP then

        -- A mouse button was depressed.

        Ada_SDL_GetMouseButtonEventParams (event, eventType, buttonNb, x, y);
		mx := integer(x);
		my := integer(y);

        if not doManyMouse then
--          Put_Line ("MouseButton, type = " & Integer'Image (Integer (eventType)) & ", buttonNb = " & Integer'Image (Integer (buttonNb)) & ", x = " & Integer'Image (Integer (x)) & ", y = " & Integer'Image (Integer (y)));

			-- Start moving the ToolGlass!
			if not ActiveFunction and then integer(buttonnb) = 3 and then Ada_SDL_EventType (event) = SDL_MOUSEBUTTONDOWN and then not ToolglassActive then
               Toolglassactive:= True ;
			   ClipRect.topLeft := (ToolGlassPos.x, ToolGlassPos.y, null);
			   ClipRect.bottomRight := (ToolglassPos.x + 81, ToolglassPos.y + 161, null);
			   RedrawWindow(MyImagePtr, Zen, ClipRect);
			   
			   DrawToolGlass(MyImagePtr, mx, my, iR, iG, iB, iA); 
			   
			   SDL_UnlockSurface (surface);
			   SDL_UpdateRect (surface, Sint32(ToolglassPos.x), Sint32(ToolglassPos.y), 81, 161);

			   SDL_UnlockSurface (surface);
			   SDL_UpdateRect (surface, Sint32(mx), Sint32(my), 81, 161);
			   ToolglassActivated := True;

			   
  				--CheckShape(offScreenImagePtr, integer(x), integer(y), Zen, ShapeMoved);
-- 				if shapeMoved /= null then
-- 					ShapeMoved.color := Black;
-- 					-- Redraw the polygon
-- 					Initscanline(ShapeMoved.Pstart, Ymin, Ymax);
-- 					X_MinMax(ShapeMoved.Pstart, Xmin, XMax);
-- 					ClipRect.topLeft := (Xmin, Ymin, null);
-- 					ClipRect.bottomRight := (Xmax, Ymax, null);
-- 					RedrawWindow(myImagePtr,Zen, ClipRect);
-- 					SDL_UnlockSurface (surface);
-- 					SDL_UpdateRect (surface, Sint32(Xmin), Sint32 (Ymin), Uint32(Xmax - Xmin), Uint32(Ymax - Ymin));
-- 				end if;

			   -- Stop moving the Toolglass!
			elsif integer(buttonnb) = 3 and then Ada_SDL_EventType (event) = SDL_MOUSEBUTTONDOWN and then ToolglassActive then
				DrawToolglass(MyImagePtr, integer(x), integer(y), iR, iG, iB, iA);
				ToolglassPos.all := (mx, my, null);
				--DrawToolglass(ToolGlassOffScreenImagePtr, integer(x), integer(y), iR, iG, iB, iA);
				ToolglassActive := False;
			end if;

			if integer(buttonnb) = 1 and then Ada_SDL_EventType (event) = SDL_MOUSEBUTTONDOWN and then (mx >= ToolglassPos.x and mx <= ToolglassPos.x + 80) and then (my >= ToolglassPos.y and my <= ToolglassPos.y + 160) and then not ToolglassActive and then not ActiveFunction then
				put_line("Inuti Toolglass!");
				if mx < ToolglassPos.x + 40 and then my < ToolglassPos.y + 40 then
					ActiveFunction := True;
					DrawlineActive := True;
					mouseColor := Blue;
					nPoint := new point'(mx, my, null);
					put_line("Drawline");
				elsif mx < ToolglassPos.x + 80 and then my < ToolglassPos.y + 40 then
					ActiveFunction := True;
					PolylineActive := True;
					mouseColor := Blue;
					fPoint := new point'(mx, my, null);
					nPoint := fPoint;
					put_line("Polyline");
				elsif mx < ToolglassPos.x + 40 and then my < ToolGlassPos.y + 80 then
					ActiveFunction := True;
					CircleActive := True;
					nPoint := new point'(mx, my, null);

					put_line("Cercle");
				elsif mx < ToolglassPos.x + 80 and then my < ToolGlassPos.y + 80 then
					ActiveFunction := True;
					PolygonActive := True;
					mouseColor := Blue;
					fPoint := new point'(mx, my, null);
					nPoint := fPoint;

					put_line("Polygone");
				elsif mx < ToolglassPos.x + 40 and then my < ToolGlassPos.y + 120 then
					put_line("CercleRempli");
				elsif mx < ToolglassPos.x + 80 and then my < ToolGlassPos.y + 120 then
					put_line("Choose Color");
				elsif mx < ToolglassPos.x + 40 and then my < ToolGlassPos.y + 160 then
					put_line("Remove");
				elsif mx < ToolglassPos.x + 80 and then my < ToolGlassPos.y + 160 then
					put_line("Increase Priority");
				end if;

			elsif integer(buttonnb) = 1 and then Ada_SDL_EventType (event) = SDL_MOUSEBUTTONDOWN and then DrawlineActive then
				ActiveFunction:= False;
				mouseColor := Black;
				nPoint.next := new point'(mx, my, null);
				ClipRect.topLeft := (min(nPoint.x, nPoint.next.x), min(nPoint.y, nPoint.next.y), null);
				ClipRect.bottomRight := (max(nPoint.x, nPoint.next.x), max(nPoint.y, nPoint.next.y), null);
				RedrawWindow(MyImagePtr, Zen, ClipRect);
				DrawlineActive := false;
				Drawline(MyImagePtr, nPoint, CurrColor);
				Drawline(OffscreenImagePtr, nPoint, maxPrio);
				insert_shape(zen(Line), new shape'(nPoint, CurrColor, maxPrio, null));
 				increasePrio(maxPrio, iR, iG, iB, iA);	
				DrawToolglass(MyImagePtr, ToolglassPos.x, ToolGlassPos.y, iR, iG, iB, iA);
				Put_line("Line Drawn");
				if nPoint = null then
					put_line("Ajaj");
				elsif nPoint.next = null then
					put_line("Vafan!");
				else
					put_line("God's in his heaven all's well with the earth");
				end if;
				SDL_UnlockSurface (surface);
				SDL_UpdateRect (surface, Sint32(ClipRect.topLeft.x), Sint32 (ClipRect.topLeft.y), Uint32(ClipRect.bottomRight.x - ClipRect.topLeft.x), Uint32(ClipRect.bottomRight.y - ClipRect.topLeft.y));
		
		
			elsif integer(buttonnb) = 1 and then Ada_SDL_EventType (event) = SDL_MOUSEBUTTONDOWN and then PolylineActive then
				nPoint.next := new point'(mx, my, null);
				nPoint := nPoint.next;
				
				Initscanline(fPoint, oldYmin, oldYmax);
  				X_MinMax(fPoint, oldXmin, oldXMax);
  				ClipRect.topLeft := (oldXmin, oldYmin, null);
  				ClipRect.bottomRight := (oldXmax, oldYmax, null);
  				RedrawWindow(MyImagePtr, Zen, ClipRect);

				polyline(MyImagePtr, fPoint, CurrColor);
				DrawToolglass(MyImagePtr, ToolglassPos.x, ToolglassPos.y, iR, iG, iB, iA);
				SDL_UnlockSurface (surface);
				SDL_UpdateRect (surface, Sint32(ClipRect.topLeft.x), Sint32 (ClipRect.topLeft.y), Uint32(ClipRect.bottomRight.x - ClipRect.topLeft.x), Uint32(ClipRect.bottomRight.y - ClipRect.topLeft.y));
			
			elsif integer(buttonnb) = 1 and then Ada_SDL_EventType (event) = SDL_MOUSEBUTTONDOWN and then PolygonActive then
				nPoint.next := new point'(mx, my, null);
				nPoint := nPoint.next;
			
			elsif integer(buttonnb) = 1 and then Ada_SDL_EventType (event) = SDL_MOUSEBUTTONDOWN and then CircleActive then
				ActiveFunction := False;
				CircleActive := False;
				nPoint.next := new point'(mx, my, null);
				Radius := max(abs (nPoint.X - nPoint.next.x), abs(nPoint.y - nPoint.next.y));
				ClipRect.topLeft := (nPoint.x - Radius, nPoint.y - Radius, null);
				ClipRect.bottomRight := (nPoint.x + Radius, nPoint.y + Radius, null);
  				RedrawWindow(MyImagePtr, Zen, ClipRect);

				Cercle(MyImagePtr, nPoint, nPoint.next, CurrColor);
				Cercle(OffscreenImagePtr, nPoint, nPoint.next, maxPrio);
				insert_Shape(zen(Circle), new shape'(nPoint, CurrColor, maxPrio, null));
				increasePrio(maxPrio, iR, iG, iB, iA);
				DrawToolglass(MyImagePtr, ToolglassPos.x, ToolglassPos.y, iR, iG, iB, iA);
				
				SDL_UnlockSurface (surface);
				SDL_UpdateRect (surface, Sint32(ClipRect.topLeft.x), Sint32 (ClipRect.topLeft.y), Uint32(ClipRect.bottomRight.x - ClipRect.topLeft.x), Uint32(ClipRect.bottomRight.y - ClipRect.topLeft.y));



-- 				ShapeType := whatObject(offScreenImagePtr, integer(x), integer(y),Zen);
-- 				removeShape(offScreenImagePtr, integer(x), integer(y), Zen, ShapeMoved);
-- 			  if ShapeMoved = null then
-- 				  moveShape := false;
-- 				  put_line("Ooops!");
-- 				  put_line(integer'image(integer(maxPrio(iR))));
-- 			  else
-- 				  Initscanline(ShapeMoved.Pstart, oldYmin, oldYmax);
-- 				  X_MinMax(ShapeMoved.Pstart, oldXmin, oldXMax);
-- 				  put_line("Xmin, Ymin =" & integer'image(oldXmin) & integer'image(oldYmin));
-- 				  put_line("Xmax, Ymax =" & integer'image(oldXmax) & integer'image(oldYmax));
-- 				  put_line(integer'image(integer(ShapeMoved.Identifier(iR))));
--  				  ShapeMoved.Identifier := maxPrio;
-- 				  increasePrio(MaxPrio, iR, iG, iB, iA);
-- 				  insert_Shape(Zen(ShapeType), ShapeMoved);
-- 				  resortPrio(Zen, iR, iG, iB, iA, maxPrio);
-- 				  redrawOffscreen(OffscreenImagePtr, zen, null);
-- -- 			  end if;

		  else
			  -- Stop Moving Polygones!
--			  put_line("moveShape = False");

			  -- Remove old figure from the offscreen
-- 			  oldClipRect.topLeft := (oldXmin, oldYmin, null);
-- 			  oldClipRect.bottomRight := (oldXmax, oldYmax, null);
-- 			  RedrawOffScreen(OffscreenImagePtr, zen, oldClipRect);
-- 			  ShapeMoved := null;
--  
-- 			  -- Draw the new position in the offscreen
-- 			  RedrawOffScreen(OffscreenImagePtr, zen, ClipRect);
			  moveShape := False;
		  end if;

		  -- Right click is stop for the functions that use more than 2 points
		  if integer(buttonnb) = 3 and then Ada_SDL_EventType (event) = SDL_MOUSEBUTTONDOWN and then PolylineActive then
			  PolylineActive := False;
			  ActiveFunction := False;
-- 			  nPoint.next := new point'(mx, my, null);
-- 			  nPoint := nPoint.next;

			  Initscanline(fPoint, oldYmin, oldYmax);
			  X_MinMax(fPoint, oldXmin, oldXMax);
			  ClipRect.topLeft := (oldXmin, oldYmin, null);
			  ClipRect.bottomRight := (oldXmax, oldYmax, null);
			  RedrawWindow(MyImagePtr, Zen, ClipRect);

			  polyline(MyImagePtr, fPoint, CurrColor);
			  polyline(OffscreenImagePtr, fPoint, maxPrio);
			  insert_Shape(Zen(Polyline), new Shape'(fPoint, CurrColor, maxPrio, null));
			  increasePrio(maxPrio, iR, iG, iB, iA);
			  DrawToolglass(MyImagePtr, ToolglassPos.x, ToolglassPos.y, iR, iG, iB, iA);
			  SDL_UnlockSurface (surface);
			  SDL_UpdateRect (surface);--, Sint32(ClipRect.topLeft.x), Sint32 (ClipRect.topLeft.y), Uint32(ClipRect.bottomRight.x - ClipRect.topLeft.x), Uint32(ClipRect.bottomRight.y - ClipRect.topLeft.y));

		  elsif integer(buttonnb) = 3 and then Ada_SDL_EventType (event) = SDL_MOUSEBUTTONDOWN and then PolygonActive then
			  PolygonActive := False;
			  ActiveFunction := False;
			  
			  Initscanline(fPoint, oldYmin, oldYmax);
			  X_MinMax(fPoint, oldXmin, oldXMax);
			  ClipRect.topLeft := (oldXmin, oldYmin, null);
			  ClipRect.bottomRight := (oldXmax, oldYmax, null);
			  RedrawWindow(MyImagePtr, Zen, ClipRect);
			  
			  polygone(MyImagePtr, fPoint, CurrColor);
			  polygone(OffscreenImagePtr, fPoint, maxPrio);
			  insert_Shape(Zen(Polygone), new Shape'(fPoint, CurrColor, maxPrio, null));
			  increasePrio(maxPrio, iR, iG, iB, iA);
			  DrawToolglass(MyImagePtr, ToolglassPos.x, ToolglassPos.y, iR, iG, iB, iA);
			  SDL_UnlockSurface (surface);
			  SDL_UpdateRect (surface);



		  end if;







        else

          Ada_MM_UpdateMice;
          for m in 0 .. nbMice - 1 loop
            mouseRec    := Ada_MM_MouseRecord (int (m));
            Put ("Mouse " & Integer'Image (m) & ": ");
            Put_Line (" buttons = " & Integer'Image (Integer (mouseRec.buttons)));
          end loop;
        end if;

      end if;
    end loop;

    -- Preparing to end the program: release all memory allocated for this program.

    Ada_SDL_ReleaseEvent (event);

    SDL_FreeSurface (surface);

    return 0;

  end Ada_SDL_Main_Function;

end Ada_SDL_Main;
