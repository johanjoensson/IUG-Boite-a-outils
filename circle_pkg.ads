with
  Ada_SDL_Video, Gr_Shapes;
use
  Ada_SDL_Video, Gr_Shapes;

package Circle_Pkg is

   procedure Cercle(animage: ImagePtr; M, D: PointPtr; Color: Pixel) ;

   procedure CercleRempli(animage: ImagePtr; M, D: PointPtr; Color: Pixel; ClipRect: RectanglePtr := null) ;

end Circle_Pkg;
