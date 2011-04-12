with
   Ada_SDL_Video,Gr_Shapes;
use
   Ada_SDL_Video,Gr_Shapes;

package Drawline_Pkg is
	
	-- Implementation of Bressenham's algorithm for drawing straight lines
   	procedure DrawLine (anImage                 : ImagePtr;
                       points				   : PointPtr;
                       color                   : Pixel;
                       clipRect   : RectanglePtr :=null) ;
end Drawline_Pkg;

