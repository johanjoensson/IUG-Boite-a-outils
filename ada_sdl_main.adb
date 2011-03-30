-- ada_sdl_main.adb --
--
--  Example of a main program using the Ada_SDL library.
--  This should be replaced by your program.


with
  Ada.Text_IO, Interfaces.C,
  Ada_SDL_Init, Ada_SDL_Video, Ada_SDL_Event, Ada_SDL_Mouse, Ada_SDL_Keyboard,
  Ada_ManyMouse,
  Gr_Shapes, Example_Package;
use
  Ada.Text_IO, Interfaces.C,
  Ada_SDL_Init, Ada_SDL_Video, Ada_SDL_Event, Ada_SDL_Mouse, Ada_SDL_Keyboard,
  Ada_ManyMouse,
  Gr_Shapes, Example_Package;

use
  Ada_SDL_Video.PixelPtrPkg;

package body Ada_SDL_Main is

  function Ada_SDL_Main_Function return Integer is
    surface         : SDL_SurfacePtr;                         -- The main window
    event           : SDL_EventPtr;                           -- Where to store details of the received event
    res             : Integer             := 0;               -- Error code returned by some functions (0 = no error)
    width           : Integer             := 640;             -- Width of the main window
    height          : Integer             := 480;             -- Height of the main window
    iR, iG, iB, iA  : Integer;                                -- Channel indices: where is "red", "green", ... in the pixel ?

    offset          : constant            := 20;              -- Width of the black border when drawing the red rectangle
    red             : Pixel               := (0, 0, 0, 0);    -- We will construct a red pixel in this (including opaque alpha)
    blue            : Pixel               := (0, 0, 0, 0);    -- We will construct a blue pixel in this (including opaque alpha)
    black           : Pixel               := (0, 0, 0, 0);    -- We will construct a black pixel in this (including opaque alpha)
	green			: Pixel				  := (0, 0, 0, 0);	  -- We will construct a green pixel in this (including opaque alpha)
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
    P1,P2,P3,P4,P5,P6  : PointPtr ;
	m1,m2,m3,m4,m5,m6,m7	: PointPtr ;
	mx, my, mxrel, myrel	: Integer ;
    Cour, suiv, Tmp          : PointPtr ;
    Diff            : Integer ;
    ClipRect        : RectanglePtr ;
	Greentran		: Pixel					:= (0,0,0,0);

	Zen				: Nirvana;
	offScreen		: SDL_SurfacePtr;
	offscreenImage	: Image;
	offScreenImagePtr	: ImagePtr;
	offPixels		: PixelPtr;
	mousePoint		: point;

  begin

    -- Initialize the ManyMouse package if required.

    if doManyMouse then
      Ada_MM_InitMice;
      nbMice        := Integer (Ada_MM_AvailableMice);
      Put_Line ("Number of mice: " & Integer'Image (nbMice));
    end if;

    -- Create the window on which everything is drawn, and receiving mouse and keyboard events.

    surface         := Ada_SDL_CreateWindow (width, height);
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
	Greentran(iG)	:= 255;
    if (iA /= -1) then
      red(iA)       := 255;
      blue(iA)      := 255;
	  green(iA)		:= 255;
      black(iA)     := 255;
	  Greentran(iA)	:= 125;
    end if;

    -- Prepare to draw in the window: get exclusive access to its memory,
    --  get a pointer to the first pixel.

    res             := SDL_LockSurface (surface);
    pixels          := Ada_SDL_GetPixelPtr (surface);
	offPixels		:= Ada_SDL_GetPixelPtr (offScreen);


    -- Erase the window: set all its pixels to black.

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
	cour := p1;
	insert_Shape(Zen(Canvas), new shape'(p1, Black, (0,0,0,0), null));

    -- Draw a big red rectangle in the window, leaving only a border of <margin> black pixels
    --  on every sides.

    lines           := Ada_SDL_GetPixelPtr (surface);
    lines           := lines + ptrdiff_t (offset * width + offset);

    for y in reverse 0 .. height - 2 * offset - 1 loop
      pixels        := lines;
      for x in reverse 0 .. width - 2 * offset - 1 loop
        pixels.all  := red;
        Increment (pixels);
      end loop;
      lines         := lines + ptrdiff_t (width);
    end loop;

	p4  := new point'(offset-1, height - offset, null);
	p3	:= new point'(width -1 - offset, height - offset,p4);
	p2	:= new point'(width -1 - offset,offset,p3);
	p1	:= new point'(offset-1 ,offset,p2);
	insert_shape(Zen(Canvas), new shape'(p1, red, (0,0,0,1), null));
	
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

	offScreenImagePtr	:= new image'(offScreenImage);
    myImagePtr        := new Image'(myImage) ;
    ClipRect          := new Rectangle'((110,110,null),(120,120,null)) ;

--	p5.all	:=	(120,170,null);
	p4  := new point'(90,90, null);
	p3	:= new point'(50,90,p4);
	p2	:= new point'(90,50,p3);
	p1	:= new point'(50,50,p2);
	
	Polygone(myImagePtr,p1,Greentran) ;
	polygone(offScreenImagePtr, p1, (1,1,1,255));

	insert_shape(Zen(Polygone), new Shape'(p1,Greentran, (0, 0, 0, 1), null));
	
	p3	:=  new point'(80,90,null);
	p2	:=  new point'(120,50,p3);
	p1	:=  new point'(80,50,p2);
	Polygone(myImagePtr,p1,Greentran) ;
	insert_shape(Zen(Polygone),  new Shape'(p1,Greentran, (0,0,0,2), null));

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

	m7	:=	new point;
	m6	:=	new point;
	m5	:=	new point;
	m4  :=  new point;
	m3	:=  new point;
	m2	:=  new	point;
	m1	:=  new point;
	Cliprect := new Rectangle;

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
			res := SDL_LockSurface (surface);
			Polygone(myImagePtr,p1,Blue) ;
--			ClipRect := new Rectangle'((90, 90, null), (150, 150, null));
--			RedrawWindow(myImagePtr,Zen, Black, ClipRect);
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


		ClipRect.topLeft := mousePoint; 		
		CLipRect.bottomRight := (mousePoint.x +12, mousePoint.y+13, null);
	
		RedrawWindow(myImagePtr,Zen, Black,ClipRect);

		SDL_UnlockSurface (surface);
		SDL_UpdateRect (surface, Sint32(ClipRect.topLeft.X), Sint32 (ClipRect.topLeft.Y), Uint32(12), Uint32(13));

		m7.all	:=	(mx, my +12, null);
		m6.all	:=	(mx +2, my +9, m7);
		m5.all	:=	(mx+4, my +11,m6);
		m4.all  :=  (mx+6,my+10,m5);
		m3.all	:=  (mx+4,my+8,m4);
		m2.all	:=  (mx+6,my+6,m3);
		m1.all	:=  (mx,my,m2);

-- 		clipRect.topLeft := (1,1, null);
-- 		ClipRect.bottomRight :=(width, height, null);

		Polygone(myImagePtr,m1,Blue) ;
	   
		SDL_UnlockSurface (surface);
		SDL_UpdateRect (surface,Sint32(mx), Sint32 (my), Uint32(12), Uint32(13)) ;




        if not doManyMouse then

          -- We are only handling one mouse.

          Put_Line ("Motion, x = " & Integer'Image (Integer (x)) & ", y = " & Integer'Image (Integer (y))
                     & ", xrel = " & Integer'Image (Integer (xrel)) & ", yrel = " & Integer'Image (Integer (yrel)));
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

        if not doManyMouse then
          Put_Line ("MouseButton, type = " & Integer'Image (Integer (eventType)) & ", buttonNb = " & Integer'Image (Integer (buttonNb))
                       & ", x = " & Integer'Image (Integer (x)) & ", y = " & Integer'Image (Integer (y)));
		  CheckShape(offScreenImagePtr, integer(x), integer(y));
		  
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
