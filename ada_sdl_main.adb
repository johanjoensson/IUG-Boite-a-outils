-- ada_sdl_main.adb --
--
--  Example of a main program using the Ada_SDL library.
--  This should be replaced by your program.


with
  Ada.Text_IO, Interfaces.C,
  Ada_SDL_Init, Ada_SDL_Video, Ada_SDL_Event, Ada_SDL_Mouse, Ada_SDL_Keyboard,
  Ada_ManyMouse,
  Gr_Shapes, Example_Package,
  Aux;

use
  Ada.Text_IO, Interfaces.C,
  Ada_SDL_Init, Ada_SDL_Video, Ada_SDL_Event, Ada_SDL_Mouse, Ada_SDL_Keyboard,
  Ada_ManyMouse,
  Gr_Shapes, Example_Package,
  Aux;

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

    myImage         : Image;	-- An image structure used to call the Ex_DrawLine primitive

    myImagePtr	    : ImagePtr;

	myClipRect		: RectanglePtr;

	topLeftClip, bottomRightClip		: Point;
	

    p1, p2, p3, p4, p5, p6, p7, p8, p9, p10  : PointPtr;


  begin

    -- Initialize the ManyMouse package if required.

    if doManyMouse then
      Ada_MM_InitMice;
      nbMice        := Integer (Ada_MM_AvailableMice);
      Put_Line ("Number of mice: " & Integer'Image (nbMice));
    end if;
  
    -- Create the window on which everything is drawn, and receiving mouse and keyboard events.

    surface         := Ada_SDL_CreateWindow (width, height);
    if surface = null then
      return -1;
    end if;
    
    -- Get the indices of the red, green, blue and alpha channel in pixels of this window

    Ada_SDL_GetSurfaceChannelIdx (surface, iR, iG, iB, iA);
    
    -- Create the color values (red, blue, black). Set alpha to 255 (opaque) if transparency is
    --  handled on this window.

    red(iR)         := 255;
    blue(iB)        := 255;
    if (iA /= -1) then
      red(iA)       := 255;
      blue(iA)      := 255;
      black(iA)     := 255;
    end if;
    
    -- Prepare to draw in the window: get exclusive access to its memory,
    --  get a pointer to the first pixel.

    res             := SDL_LockSurface (surface);
    pixels          := Ada_SDL_GetPixelPtr (surface);

    -- Erase the window: set all its pixels to black.

    for y in 1 .. height loop
      for x in 1 .. width loop
        pixels.all := black;
        Increment (pixels);
      end loop;
    end loop;

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

    -- Fill-in an Image record in order to all the "Ex_DrawLine" drawing primitive,
    --  then draw a line.

    myImage.basePixel := Ada_SDL_GetPixelPtr (surface);
    myImage.iR        := iR;
    myImage.iG        := iG;
    myImage.iB        := iB;
    myImage.iA        := iA;
    myImage.width     := width;
    myImage.height    := height;

    myImagePtr  	:=  new Image'(myImage);

	topLeftClip		:=	(45,60,null);
	bottomRightClip	:=	(150,150,null);

	myClipRect		:=	new Rectangle'(topLeftClip, bottomRightClip);

    --DrawLine (myImagePtr, 30, 30, 30, 90, blue);
	p10	:=	new point'(240,120,null);
	p9	:=	new point'(240,60,p10);
	p8	:=	new point'(210,30,p9);
	p7	:=	new point'(180,60,p8);
	p6	:=	new point'(180,90,null);
	p5	:=	new point'(180,120,p6);
	p4  :=  new point'(120,120,p5);
    p3	:=  new point'(120,30,p4);
    p2	:=  new	point'(90,30,p3);
    p1	:=  new point'(90,90,p2);
    polygone(myImagePtr, p1, blue, myClipRect);
	--polygone(myImagePtr, p5, blue);

    --p1.next := p2;
    --p2.next := p4;
    --p4.next := p3;
    --p3.next := null;
    --polygone(myImagePtr, p1, blue);




    -- Release exclusive access to the window's pixel memory, tell the system to
    --  update the entire window on the screen.

    SDL_UnlockSurface (surface);
    SDL_UpdateRect (surface);
    
    --
    -- Now for events and handle them.
    --
    
    -- Create a recard to store events,
    --  loop infinitely by waiting for a new event, and handling it.

    event := Ada_SDL_AllocateEvent;
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
