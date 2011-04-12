-- ada_sdl_main.adb --
--
--  Example of a main program using the Ada_SDL library.
--  This should be replaced by your program.


with
  Ada.Text_IO, Interfaces.C,
  Ada_SDL_Init, Ada_SDL_Video, Ada_SDL_Event, Ada_SDL_Mouse, Ada_SDL_Keyboard,
  Ada_ManyMouse,
  Gr_Shapes, Aux_Fct, Event_Handling, Drawline_Pkg, Circle_Pkg;
use
  Ada.Text_IO, Interfaces.C,
  Ada_SDL_Init, Ada_SDL_Video, Ada_SDL_Event, Ada_SDL_Mouse, Ada_SDL_Keyboard,
  Ada_ManyMouse,
  Gr_Shapes, Aux_Fct, Event_Handling, Drawline_Pkg, Circle_Pkg;

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
	Yellow			: Pixel				  := (0, 0, 0, 0);	  -- We will construct a yellow pixel in this (including opaque alpha)
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

    myImagePtr      : ImagePtr;								  -- Pointer to our image structure, used for most drawing procedures
	p1, p2, p3, p4	: PointPtr	;							  -- Points used for creating the canvas
	m1,m2,m3,m4,m5,m6,m7	: PointPtr ;					  -- The points of our pointer (mouse)	
	mouseColor		: Pixel;								  -- The color of our mouse
	mx, my, mxrel, myrel	: Integer ;						  -- Integer values of the mouse's position and it's movement
    ClipRect, oldClipRect   : RectanglePtr ;				  -- Rectangles used for clipping, containing current and old position of an object respectively
	Greentran		: Pixel					:= (0,0,0,0);	  -- We will create a transparent green color in this variable

	Zen				: Nirvana;				-- A table of lists containing all the object we have created
	offScreen		: SDL_SurfacePtr;		-- An offscreen used for picking
	offscreenImage	: Image;				-- Image Structure off the offscreen
	offScreenImagePtr	: ImagePtr;			-- Pointer to the Image of the offscreen
	offPixels		: PixelPtr;				-- Pointer to Pixels in the offscreen
	mousePoint		: point;				-- The old location of the mouse
	moveShape		: Boolean	:= False;	-- Boolean indicating wheter or not we are moving an object
	ShapeMoved		: ShapePtr;				-- The object we are moving, null if we are not moving any object
	ShapeType		: OBJECT;				-- The kind of object we are moving
	PCurr			: PointPtr;				-- Pointer to a point
	oldXmin, oldXmax, oldYmin, oldYmax	: Integer;	-- The coordinates of a rectangle containing the old position of an object
	Xmin, Xmax, Ymin, Ymax	: Integer;		-- The coordinates of a rectangle containing the current position of an object
	maxPrio			: Pixel					:= (0, 0, 0, 0); -- Indicator of priority, one higher than the highest priority of the objects

	toolglassactive: Boolean := False;		-- True if we are moving the toolglass
 	ToolglassActivated	: Boolean	:= False;	-- True if we have designed the toolglass at least once
	ToolglassPos	: PointPtr	:= new point;	-- The position of the upper left corner of the toolglass
	ActiveFunction	: Boolean	:= false;		-- True if we are currently performing some sort of action (drawing an object f.i.)

	ColorTableActive	: Boolean	:= False;	-- True if the color table is displayed
	ColortablePos		: PointPtr	:= new point;	-- The position of the upper left corner of the color table

	fPoint,nPoint, tmpPoint	: PointPtr	;		-- Pointers to points we use to create and draw objects
	CurrColor				: Pixel ;			-- The current color we are using
	DrawlineActive			: Boolean	:= False;	-- True if we are drawing a line
	PolylineActive			: Boolean	:= False;	-- True if we are drawing a polyline
	PolygonActive			: Boolean	:= False;	-- True if we are drawing a polygon
	CircleActive			: Boolean	:= False;	-- True if we are drawing an (empty) circle
	FilledCircleActive		: Boolean	:= False;	-- True if we are drawing a (filled) circle
	Radius					: Integer	;			-- Not really the radius of a circle, but much easier and cheaper to calculate

	

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

	-- Create the offscreen
	offScreen		:= Ada_SDL_CreateOffscreen (surface,width, height);

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
	Yellow(iR)		:= 255;
	Yellow(iG)		:= 255;
	white(iR)		:= 255;
	white(iG)		:= 255;
	white(iB)		:= 255;
	Greentran(iG)	:= 255;
    if (iA /= -1) then
      red(iA)       := 255;
      blue(iA)      := 255;
	  green(iA)		:= 255;
	  Yellow(iA)	:= 255;
      black(iA)     := 255;
	  white(iA)		:= 255;
	  Greentran(iA)	:= 128;
	  maxPrio(iA)	:= 255;
    end if;
	-- Default color fo drawing is blue
	currColor := Blue;

    -- Prepare to draw in the window: get exclusive access to its memory,
    --  get a pointer to the first pixels.

    res             := SDL_LockSurface (surface);
    pixels          := Ada_SDL_GetPixelPtr (surface);
	offPixels		:= Ada_SDL_GetPixelPtr (offScreen);



    -- Erase the window: set all its pixels to black.
	-- Set all the offscreen's pixels to Black (so that we know the default value of the Canvas

    for y in 1 .. height loop
      for x in 1 .. width loop
        pixels.all := black;
		offPixels.all := black;
        Increment (pixels);
        Increment (offPixels);
      end loop;
    end loop;

	p4  :=  new point'(1, height, null);
	p3	:=  new point'(width,height,p4);
	p2	:=  new	point'(width,1,p3);
	p1	:=  new point'(1,1,p2);
	insert_Shape(Zen(Canvas), new shape'(p1, Black, maxPrio, null));
	
    -- Draw a big red rectangle in the window, leaving only a border of <margin> black pixels
    --  on every sides.
	--  Add this rectangle to the canvas and draw it in the offscreen

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

	-- Initialise the offscreen, not really useful but it can't hurt

	offScreenImage.basePixel := Ada_SDL_GetPixelPtr (offScreen);
	offScreenImage.iR		:= iR;
	offScreenImage.iG		:= iG;
	offScreenImage.iB		:= iB;
	offScreenImage.iA		:= iA;
	offScreenImage.width	:= width;
	offScreenImage.height	:= height;

	

	offScreenImagePtr	:= new image'(offScreenImage);
    myImagePtr        := new Image'(myImage) ;
    ClipRect          := new Rectangle'((110,110,null),(120,120,null)) ;

    -- Release exclusive access to the window's pixel memory, tell the system to
    --  update the entire window on the screen.

     SDL_UnlockSurface (surface);
     SDL_UpdateRect (surface);
     SDL_UnlockSurface (offScreen);
     SDL_UpdateRect (offScreen);

 
    --
    -- Now for events and handle them.
    --

    -- Create a recard to store events,
    --  loop infinitely by waiting for a new event, and handling it.

    event := Ada_SDL_AllocateEvent;

	-- Preparing the mouse, we wont draw anything yet though
	m7	:=	new point;
	m6	:=	new point;
	m5	:=	new point;
	m4  :=  new point;
	m3	:=  new point;
	m2	:=  new	point;
	m1	:=  new point;
	Cliprect := new Rectangle;
	
	-- Default color of the mouse is black
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

      end if;

      if Ada_SDL_EventType (event) = SDL_MOUSEMOTION then


        -- The mouse moved

        Ada_SDL_GetMouseMotionEventParams (event, buttonStates, x, y, xrel, yrel);
		-- Get the current position of the mouse
		mx := integer(x);
		my := integer(y);
		mxrel := integer(xrel);
		myrel := integer(yrel);
		mousePoint := (mx-mxrel, my-myrel, null);-- Ancien position de souris


				
	        if not doManyMouse then

          -- We are only handling one mouse.

				-- Draw the mouse in it's new position
		if not Toolglassactive and then not moveShape then
			-- Erase the old image of the mouse
			 
			ClipRect.topLeft := mousePoint; 		
			ClipRect.bottomRight := (mousePoint.x +15, mousePoint.y+15, null);
			RedrawWindow(myImagePtr, Zen, ClipRect);
	
			-- If necessary repair the Toolglass
			if not colortableActive and then (mx >= ToolglassPos.x - 15 and mx <= ToolglassPos.x + 95) and then (my >= Toolglasspos.y - 15 and my <= Toolglasspos.y + 175) then
				DrawtoolGlass(MyImagePtr, ToolglassPos.x, ToolglassPos.y, ir, iG, iB, iA, ClipRect);
			end if;
			
		
			-- if necessary repair the table of colors
			if ColortableActive and then (mx >= ColorTablePos.x - 15 and mx <= ColortablePos.x + 105) and then (my >= ColortablePos.y - 15 and my <= ColorTablePos.y + 135) then
				DrawColortable(MyImagePtr, ColortablePos.x, ColortablePos.y, ir, iG, iB, iA, ClipRect);
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

		elsif not moveShape then
			-- Draw the Toolglass in it's new position
			
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
	
		elsif moveShape then
			
			PCurr := ShapeMoved.PStart;
		   	-- Erase old picture
  			Initscanline(PCurr, Ymin, Ymax);
  			X_MinMax(PCurr, Xmin, XMax);
  			if ShapeType = Circle or else ShapeType = FilledCircle then
				Radius := max(abs (ShapeMoved.Pstart.X - ShapeMoved.Pstart.next.x), abs(ShapeMoved.Pstart.y - ShapeMoved.Pstart.next.y));
				ClipRect.topLeft := (ShapeMoved.Pstart.X - Radius - 1, ShapeMoved.Pstart.y - Radius - 1, null);
				ClipRect.bottomRight := (ShapeMoved.Pstart.x + Radius + 1, ShapeMoved.Pstart.y + Radius +1, null);
			else
				ClipRect.topLeft := (Xmin, Ymin, null);
				ClipRect.bottomRight := (Xmax + 1, Ymax + 2, null);
			end if;
 
				
  			-- Update the points in the moved shape 		  
			while PCurr /= null loop
			   	PCurr.X := PCurr.X + mxrel;
   				PCurr.Y := PCurr.Y + myrel;
   				PCurr := PCurr.next;
			end loop;
			-- Draw the new picture
  			RedrawWindow(myImagePtr,Zen, ClipRect);


		
		   	SDL_UnlockSurface (surface);
  			SDL_UpdateRect (surface, Sint32(ClipRect.topLeft.X), Sint32 (ClipRect.topLeft.Y), Uint32(ClipRect.bottomRight.X - ClipRect.topLeft.X +1), Uint32(ClipRect.bottomRight.Y - ClipRect.topLeft.Y +1));



         end if ;
		 -- Mouse, toolglass or Object (if moving an object) Drawn

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

			-- Start moving the ToolGlass!
			if not ActiveFunction and then not moveShape and then integer(buttonnb) = 3 and then Ada_SDL_EventType (event) = SDL_MOUSEBUTTONDOWN and then not ToolglassActive then
               Toolglassactive:= True ;
			   ColorTableActive := False;
			   ClipRect.topLeft := (ToolGlassPos.x, ToolGlassPos.y, null);
			   ClipRect.bottomRight := (ToolglassPos.x + 81, ToolglassPos.y + 161, null);
			   RedrawWindow(MyImagePtr, Zen, ClipRect);
			  
			   ClipRect.topLeft := (ColorTablePos.x, ColorTablePos.y, null);
			   ClipRect.bottomRight := (ColorTablePos.x + 95, ColorTablePos.y + 121, null);
			   RedrawWindow(MyImagePtr, Zen, ClipRect);

			   
			   DrawToolGlass(MyImagePtr, mx, my, iR, iG, iB, iA); 
			   
 			   SDL_UnlockSurface (surface);
 			   SDL_UpdateRect (surface, Sint32(ToolglassPos.x), Sint32(ToolglassPos.y), 81, 161);
			   
			   SDL_UnlockSurface (surface);
 			   SDL_UpdateRect (surface, Sint32(ColorTablePos.x), Sint32(ColorTablePos.y), 95, 121);


			   SDL_UnlockSurface (surface);
			   SDL_UpdateRect (surface, Sint32(mx), Sint32(my), 81, 161);
			   ToolglassActivated := True;

			   
  				
			   -- Stop moving the Toolglass!
			elsif integer(buttonnb) = 3 and then Ada_SDL_EventType (event) = SDL_MOUSEBUTTONDOWN and then ToolglassActive then
				DrawToolglass(MyImagePtr, integer(x), integer(y), iR, iG, iB, iA);
				ToolglassPos.all := (mx, my, null);
				ToolglassActive := False;
			end if;

			-- The toolglass is not moving and we clicked somewhere in the window
			if integer(buttonnb) = 1 and then Ada_SDL_EventType (event) = SDL_MOUSEBUTTONDOWN and then (mx >= ToolglassPos.x and mx <= ToolglassPos.x + 80) and then (my >= ToolglassPos.y and my <= ToolglassPos.y + 160) and then not ToolglassActive and then not ActiveFunction and then not ColorTableActive then
			
				------------------------------------------
				-- We Clicked inside the Toolglass, YAY!--
				if mx < ToolglassPos.x + 40 and then my < ToolglassPos.y + 40 then
					-- Activate Drawline
					ActiveFunction := True;
					DrawlineActive := True;
					mouseColor := Blue;
					nPoint := new point'(mx, my, null);
				elsif mx < ToolglassPos.x + 80 and then my < ToolglassPos.y + 40 then
					-- Activate Polyline
					ActiveFunction := True;
					PolylineActive := True;
					mouseColor := Blue;
					fPoint := new point'(mx, my, null);
					nPoint := fPoint;
				elsif mx < ToolglassPos.x + 40 and then my < ToolGlassPos.y + 80 then
					-- Activate Circle
					ActiveFunction := True;
					CircleActive := True;

					nPoint := new point'(mx, my, null);

				elsif mx < ToolglassPos.x + 80 and then my < ToolGlassPos.y + 80 then
					-- Activate polygon
					ActiveFunction := True;
					PolygonActive := True;
					mouseColor := Blue;
					fPoint := new point'(mx, my, null);
					nPoint := fPoint;

				elsif mx < ToolglassPos.x + 40 and then my < ToolGlassPos.y + 120 then
					-- Activate filled Circle
					ActiveFunction := True;
					FilledCircleActive := True;
					mouseColor := Blue;
					nPoint := new point'(mx, my, null);

				elsif mx < ToolglassPos.x + 80 and then my < ToolGlassPos.y + 120 then
					-- Activate the table of colors
					ToolGlassActive := False;
					checkShape(OffscreenImagePtr, mx, my, Zen, ShapeMoved);
					ShapeType := whatObject(OffscreenImagePtr, ShapeMoved.Pstart.x, ShapeMoved.Pstart.y, Zen);
					ClipRect.topLeft := (ToolglassPos.x, ToolGlassPos.Y, null);
					ClipRect.bottomRight := (ToolglassPos.x + 80, ToolglassPos.Y + 160, null);
					RedrawWindow(MyImagePtr, Zen, ClipRect);
				
					SDL_UnlockSurface (surface);
					SDL_UpdateRect (surface, Sint32(ClipRect.topLeft.x), Sint32 (ClipRect.topLeft.y), Uint32(81), Uint32(161));

					ColorTableActive := True;
					ColorTablePos.all	:= (mx, my, null);

				   	DrawColorTable(MyImagePtr, mx, my, iR, iG, iB, iA);
					
					SDL_UnlockSurface (surface);
					SDL_UpdateRect (surface, Sint32(mx), Sint32 (my), Uint32(90), Uint32(121));


				elsif mx < ToolglassPos.x + 40 and then my < ToolGlassPos.y + 160 then
					-- Erase the object!

					checkShape(OffscreenImagePtr, mx, my, Zen, ShapeMoved);
					if ShapeMoved /= null then
						ShapeType := whatObject(OffscreenImagePtr, mx, my, Zen);
						initscanline(ShapeMoved.Pstart, Ymin, Ymax);
						X_MinMax(ShapeMoved.Pstart, Xmin, XMax);
						-- Create a rectangle that contains the object
						if ShapeType = Circle or else ShapeType = FilledCircle then
							Radius := max(abs (ShapeMoved.Pstart.X - ShapeMoved.Pstart.next.x), abs(ShapeMoved.Pstart.y - ShapeMoved.Pstart.next.y));
							ClipRect.topLeft := (ShapeMoved.Pstart.X - Radius - 1, ShapeMoved.Pstart.y - Radius - 1, null);
							ClipRect.bottomRight := (ShapeMoved.Pstart.x + Radius + 1, ShapeMoved.Pstart.y + Radius +1, null);
						else
							ClipRect.topLeft := (Xmin, Ymin, null);
							ClipRect.bottomRight := (Xmax + 1, Ymax + 1, null);
						end if;
						
						-- The Boolean is to make sure that we erase the object
						removeShape(OffscreenImagePtr, mx, my, Zen, ShapeMoved, True);
						ShapeMoved := null;
						resortPrio(Zen, iR, iG, iB, iA, MaxPrio);
						RedrawWindow(MyImagePtr, Zen, ClipRect);
						RedrawOffScreen(OffscreenImagePtr, Zen);
						DrawToolglass(MyImagePtr, ToolglassPos.x, ToolGlassPos.y, iR, iG, iB, iA);
						SDL_UnlockSurface (surface);
						SDL_UpdateRect (surface, Sint32(ClipRect.topLeft.x), Sint32 (ClipRect.topLeft.y), Uint32(ClipRect.bottomRight.x - ClipRect.topLeft.x), Uint32(ClipRect.bottomRight.y - ClipRect.topLeft.y));
					end if;

				elsif mx < ToolglassPos.x + 80 and then my < ToolGlassPos.y + 160 then
					-- Change the object Priority (to the highest value so far)
				
					-- Find out what kind of shape we're dealing with
					ShapeType := whatObject(offScreenImagePtr, integer(x), integer(y),Zen);
					-- The Boolean is necessary to make sure that we do NOT erase the object
					-- we only want to remove it from the list, so that we can insert it later
					removeShape(offScreenImagePtr, integer(x), integer(y), Zen, ShapeMoved, false);
					if ShapeMoved /= null then					
						Initscanline(ShapeMoved.Pstart, Ymin, Ymax);
						X_MinMax(ShapeMoved.Pstart, Xmin, XMax);

						-- Calculate an appropriate clipping rectangle
						if ShapeType = Circle or else ShapeType = FilledCircle then
							Radius := max(abs (ShapeMoved.Pstart.X - ShapeMoved.Pstart.next.x), abs(ShapeMoved.Pstart.y - ShapeMoved.Pstart.next.y));
							ClipRect.topLeft := (ShapeMoved.Pstart.X - Radius - 1, ShapeMoved.Pstart.y - Radius - 1, null);
							ClipRect.bottomRight := (ShapeMoved.Pstart.x + Radius + 1, ShapeMoved.Pstart.y + Radius +1, null);
						else
							ClipRect.topLeft := (Xmin, Ymin, null);
							ClipRect.bottomRight := (Xmax + 1, Ymax + 1, null);
						end if;

						-- Increase the priority of the object
						ShapeMoved.Identifier := maxPrio;
						increasePrio(MaxPrio, iR, iG, iB, iA);
						insert_Shape(Zen(ShapeType), ShapeMoved);
						resortPrio(Zen, iR, iG, iB, iA, maxPrio);
						
						-- Redraw the object according to it's new priority
						redrawWindow(MyImagePtr, Zen, ClipRect);
						redrawOffscreen(OffscreenImagePtr, zen);
						DrawToolglass(MyImagePtr, ToolglassPos.x, ToolGlassPos.y, iR, iG, iB, iA);
						
						SDL_UnlockSurface (surface);
						SDL_UpdateRect (surface, Sint32(ClipRect.topLeft.x), Sint32 (ClipRect.topLeft.y), Uint32(ClipRect.bottomRight.x - ClipRect.topLeft.x), Uint32(ClipRect.bottomRight.y - ClipRect.topLeft.y));
					end if;

				end if;


				------------------------------------------------------------------------------------
				-- We didn't Click inside the toolglass, or the toolglass is currently not active --

			elsif integer(buttonnb) = 1 and then Ada_SDL_EventType (event) = SDL_MOUSEBUTTONDOWN and then DrawlineActive then
				-- We are drawing a line between two points, cool!
				ActiveFunction:= False;
				DrawlineActive := false;
				mouseColor := Black;
				nPoint.next := new point'(mx, my, null);

				-- Redraw the window
 				ClipRect.topLeft := (min(nPoint.x, nPoint.next.x), min(nPoint.y, nPoint.next.y), null);
 				ClipRect.bottomRight := (max(nPoint.x, nPoint.next.x), max(nPoint.y, nPoint.next.y), null);
				
				
				Drawline(MyImagePtr, nPoint, CurrColor);
				Drawline(OffscreenImagePtr, nPoint, maxPrio);
				insert_shape(zen(Line), new shape'(nPoint, CurrColor, maxPrio, null));
 				increasePrio(maxPrio, iR, iG, iB, iA);	
				DrawToolglass(MyImagePtr, ToolglassPos.x, ToolGlassPos.y, iR, iG, iB, iA, ClipRect);

				SDL_UnlockSurface (surface);
				SDL_UpdateRect (surface, Sint32(ClipRect.topLeft.x), Sint32 (ClipRect.topLeft.y), Uint32(ClipRect.bottomRight.x - ClipRect.topLeft.x), Uint32(ClipRect.bottomRight.y - ClipRect.topLeft.y));
		
		
				-- We are drawing a polyline, ooh that seems fun!
			elsif integer(buttonnb) = 1 and then Ada_SDL_EventType (event) = SDL_MOUSEBUTTONDOWN and then PolylineActive then
				-- Draw part of the polyline
				nPoint.next := new point'(mx, my, null);
				nPoint := nPoint.next;
				
				Initscanline(fPoint, Ymin, Ymax);
  				X_MinMax(fPoint, Xmin, XMax);
  				ClipRect.topLeft := (Xmin, Ymin, null);
  				ClipRect.bottomRight := (Xmax, Ymax, null);
  				RedrawWindow(MyImagePtr, Zen, ClipRect);

				polyline(MyImagePtr, fPoint, CurrColor);
				DrawToolglass(MyImagePtr, ToolglassPos.x, ToolglassPos.y, iR, iG, iB, iA);
				SDL_UnlockSurface (surface);
				SDL_UpdateRect (surface, Sint32(ClipRect.topLeft.x), Sint32 (ClipRect.topLeft.y), Uint32(ClipRect.bottomRight.x - ClipRect.topLeft.x), Uint32(ClipRect.bottomRight.y - ClipRect.topLeft.y));
			
				-- We are drawing a polygon, I like it!
			elsif integer(buttonnb) = 1 and then Ada_SDL_EventType (event) = SDL_MOUSEBUTTONDOWN and then PolygonActive then
				nPoint.next := new point'(mx, my, null);
				nPoint := nPoint.next;
			
				-- We are drawing a circle, this seems hard!
			elsif integer(buttonnb) = 1 and then Ada_SDL_EventType (event) = SDL_MOUSEBUTTONDOWN and then CircleActive then
				-- Draw the circle
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
		
				-- we are drawing a filled circle, that's nice!
			elsif integer(buttonnb) = 1 and then Ada_SDL_EventType (event) = SDL_MOUSEBUTTONDOWN and then FilledCircleActive then
				-- Calculate the ClipRect and redraw the window
				ActiveFunction := False;
				FilledCircleActive := False;
				nPoint.next := new point'(mx, my, null);
				Radius := max(abs (nPoint.X - nPoint.next.x), abs(nPoint.y - nPoint.next.y));
				ClipRect.topLeft := (nPoint.x -Radius, nPoint.y - Radius, null);
				ClipRect.bottomRight := (nPoint.x + Radius, nPoint.y + Radius, null);
  				RedrawWindow(MyImagePtr, Zen, ClipRect);

				-- Draw the filled circle
				CercleRempli(MyImagePtr, nPoint, nPoint.next, CurrColor);
				CercleRempli(OffscreenImagePtr, nPoint, nPoint.next, maxPrio);
				insert_Shape(zen(FilledCircle), new shape'(nPoint, CurrColor, maxPrio, null));
				increasePrio(maxPrio, iR, iG, iB, iA);
				DrawToolglass(MyImagePtr, ToolglassPos.x, ToolglassPos.y, iR, iG, iB, iA);
				
				SDL_UnlockSurface (surface);
				SDL_UpdateRect (surface, Sint32(ClipRect.topLeft.x), Sint32 (ClipRect.topLeft.y), Uint32(ClipRect.bottomRight.x - ClipRect.topLeft.x + 1), Uint32(ClipRect.bottomRight.y - ClipRect.topLeft.y + 1));
			
			
				-- We want to change color, Shiny!
			elsif integer(buttonnb) = 1 and then Ada_SDL_EventType (event) = SDL_MOUSEBUTTONDOWN and then ColorTableActive then
				-- erase the table of colors (we don't need it anymore)
					ColorTableActive := false;
					ClipRect.topLeft := (ColortablePos.all);
					ClipRect.bottomRight := (ColortablePos.x + 90, ColorTablePos.y + 121, null);
					RedrawWindow(MyImagePtr, Zen, ClipRect);	
					
					SDL_UnlockSurface (surface);
					SDL_UpdateRect (surface, Sint32(ClipRect.topLeft.x), Sint32(ClipRect.topLeft.y), Uint32(ClipRect.bottomRight.x - ClipRect.topLeft.x), Uint32(ClipRect.bottomRight.Y - ClipRect.topLeft.y));
				

					-- We clicked inside the Table of colors
				if (mx >= ColorTablePos.x and mx <= ColortablePos.x + 90) and then (my >= ColortablePos.y and my <= ColorTablePos.y + 120) then

					-- Select color!
					if mx < ColorTablePos.x + 45 and then my < ColorTablePos.y + 45 then
						CurrColor := Red;
					elsif mx < ColorTablePos.x + 90 and then my < ColorTablePos.y + 45 then
						CurrColor := Green;
					elsif mx < ColorTablePos.x + 45 and then my < ColorTablePos.y + 90 then
						CurrColor := Blue;
					elsif mx < ColorTablePos.x + 90 and then my < ColorTablePos.y + 90 then
						CurrColor := Black;
					elsif mx < ColorTablePos.x + 45 and then my < ColorTablePos.y + 135 then
						CurrColor := Yellow;
					elsif mx < ColorTablePos.x + 90 and then my < ColorTablePos.y + 180 then
						CurrColor := White;
					end if;

					-- Let's change the color of the object as well, if we selected an object
					if ShapeMoved /= null then
						ShapeMoved.color := CurrColor;
						initscanline(ShapeMoved.Pstart, Ymin, Ymax);
						X_MinMax(ShapeMoved.Pstart, Xmin, XMax);
						if ShapeType = Circle or else ShapeType = FilledCircle then
							Radius := max(abs (ShapeMoved.Pstart.X - ShapeMoved.Pstart.next.x), abs(ShapeMoved.Pstart.y - ShapeMoved.Pstart.next.y));
							ClipRect.topLeft := (ShapeMoved.Pstart.X - Radius - 1, ShapeMoved.Pstart.y - Radius - 1, null);
							ClipRect.bottomRight := (ShapeMoved.Pstart.x + Radius + 1, ShapeMoved.Pstart.y + Radius +1, null);
						else
							ClipRect.topLeft := (Xmin, Ymin, null);
							ClipRect.bottomRight := (Xmax + 1, Ymax + 2, null);
						end if;

						RedrawWindow(MyImagePtr, Zen, ClipRect);
						SDL_UnlockSurface (surface);
						SDL_UpdateRect (surface, Sint32(ClipRect.topLeft.x), Sint32(ClipRect.topLeft.y), Uint32(ClipRect.bottomRight.x - ClipRect.topLeft.x), Uint32(ClipRect.bottomRight.Y - ClipRect.topLeft.y));

					end if;
				end if;
					
				DrawToolglass(MyImagePtr, ToolglassPos.x, ToolGlassPos.y, iR, iG, iB, iA);
				SDL_UnlockSurface (surface);
				SDL_UpdateRect (surface, Sint32(ToolglassPos.x), Sint32(ToolglassPos.y), 81, 161);
	
				-------------------------------------------------------------------------------------------
				-- We didn't click in the toolglass, maybe we want to move an object, that'd be so cool! --
			elsif integer(buttonnb) = 1 and then Ada_SDL_EventType (event) = SDL_MOUSEBUTTONDOWN and then not MoveShape then

				-- We wanto to move an object

							
 				ShapeType := whatObject(offScreenImagePtr, integer(x), integer(y),Zen);
 				CheckShape(offScreenImagePtr, integer(x), integer(y), Zen, ShapeMoved);
 			  if ShapeMoved = null then
				  -- no object was selected
				  moveShape := false;
 			  else
				  -- an object was selected
				  moveShape := True;

				  -- Remove the pointer and the toolglass
				  ClipRect.topLeft := (mx, my, null);
				  ClipRect.bottomRight := (mx + 15, my + 15, null);
  				  RedrawWindow(MyImagePtr, Zen, ClipRect);

			  	  ClipRect.topLeft := (ToolGlassPos.x, ToolGlassPos.y, null);
			  	  ClipRect.bottomRight := (ToolglassPos.x + 81, ToolglassPos.y + 161, null);
  				  RedrawWindow(MyImagePtr, Zen, ClipRect);

				  -- Determine the original position of the object
				  if Shapetype = Circle or else ShapeType = FilledCircle then
					  oldXmin := ShapeMoved.Pstart.x;
					  oldYmin := ShapeMoved.Pstart.y;
				  else
					  Initscanline(ShapeMoved.Pstart, oldYmin, oldYmax);
					  X_MinMax(ShapeMoved.Pstart, oldXmin, oldXMax);
				  end if;
			  end if;
			  
			  SDL_UnlockSurface (surface);
  			  SDL_UpdateRect (surface, Sint32(mx), Sint32(my), Uint32(15), Uint32(15));

		  	  SDL_UnlockSurface (surface);
  			  SDL_UpdateRect (surface, Sint32(ClipRect.TopLeft.x), Sint32(ClipRect.topLeft.y), Uint32(81), Uint32(161));

			
			elsif integer(buttonnb) = 1 and then Ada_SDL_EventType (event) = SDL_MOUSEBUTTONDOWN and then MoveShape then

			  -- Stop Moving Objects!

			  -- Remove old figure from the offscreen
 			 if ShapeType = Circle or else ShapeType = FilledCircle then
				 Radius := max(abs (ShapeMoved.Pstart.X - ShapeMoved.Pstart.next.x), abs(ShapeMoved.Pstart.y - ShapeMoved.Pstart.next.y));
				 oldClipRect.topLeft := (oldXmin - Radius - 2, oldYmin - Radius - 2, null);
				 oldClipRect.bottomRight := (oldXmin + Radius + 2, oldYmin + Radius +2, null);
			 else
				 oldClipRect.topLeft := (oldXmin, oldYmin, null);
				 oldClipRect.bottomRight := (oldXmax + 1, oldYmax + 2, null);
			 end if;
 			  RedrawOffScreen(OffscreenImagePtr, zen, oldClipRect);
 			  ShapeMoved := null;
  
 			  -- Draw the new position in the offscreen
 			  RedrawOffScreen(OffscreenImagePtr, zen, ClipRect);
			  moveShape := False;


				DrawToolglass(MyImagePtr, ToolglassPos.x, ToolGlassPos.y, iR, iG, iB, iA);

				SDL_UnlockSurface (surface);
  				SDL_UpdateRect (surface, Sint32(ToolglassPos.x), Sint32(ToolglassPos.y), Uint32(81), Uint32(161));

		  end if;
  
		  -- Right click is stop for the functions that use more than 2 points
		  if integer(buttonnb) = 3 and then Ada_SDL_EventType (event) = SDL_MOUSEBUTTONDOWN and then PolylineActive then
			  -- Stop Polyline
			  PolylineActive := False;
			  ActiveFunction := False;
			  mouseColor := Black;

			  -- Redraw the window and calculate the clipRect
			  Initscanline(fPoint, Ymin, Ymax);
			  X_MinMax(fPoint, Xmin, XMax);
			  ClipRect.topLeft := (Xmin, Ymin, null);
			  ClipRect.bottomRight := (Xmax, Ymax, null);
			  RedrawWindow(MyImagePtr, Zen, ClipRect);

			  -- Draw the Polyline
			  polyline(MyImagePtr, fPoint, CurrColor);
			  polyline(OffscreenImagePtr, fPoint, maxPrio);
			  insert_Shape(Zen(Polyline), new Shape'(fPoint, CurrColor, maxPrio, null));
			  increasePrio(maxPrio, iR, iG, iB, iA);
			  DrawToolglass(MyImagePtr, ToolglassPos.x, ToolglassPos.y, iR, iG, iB, iA, ClipRect);
			  
			  SDL_UnlockSurface (surface);
			  SDL_UpdateRect (surface, Sint32(ClipRect.topLeft.x), Sint32 (ClipRect.topLeft.y), Uint32(ClipRect.bottomRight.x - ClipRect.topLeft.x), Uint32(ClipRect.bottomRight.y - ClipRect.topLeft.y));

		  elsif integer(buttonnb) = 3 and then Ada_SDL_EventType (event) = SDL_MOUSEBUTTONDOWN and then PolygonActive then
			  -- Stop Polygone
			  PolygonActive := False;
			  ActiveFunction := False;
			  mouseColor := Black;
			  
			  -- Redraw the window
			  Initscanline(fPoint, Ymin, Ymax);
			  X_MinMax(fPoint, Xmin, XMax);
			  ClipRect.topLeft := (Xmin, Ymin, null);
			  ClipRect.bottomRight := (Xmax, Ymax, null);
			  RedrawWindow(MyImagePtr, Zen, ClipRect);
			  
			  -- Draw the polygon
			  polygone(MyImagePtr, fPoint, CurrColor);
			  polygone(OffscreenImagePtr, fPoint, maxPrio);
			  insert_Shape(Zen(Polygone), new Shape'(fPoint, CurrColor, maxPrio, null));
			  increasePrio(maxPrio, iR, iG, iB, iA);
			  DrawToolglass(MyImagePtr, ToolglassPos.x, ToolglassPos.y, iR, iG, iB, iA);


			  SDL_UnlockSurface (surface);
			  SDL_UpdateRect (surface, Sint32(ClipRect.topLeft.x), Sint32 (ClipRect.topLeft.y), Uint32(ClipRect.bottomRight.x - ClipRect.topLeft.x), Uint32(ClipRect.bottomRight.y - ClipRect.topLeft.y));



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
