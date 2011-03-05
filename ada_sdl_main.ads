-- ada_sdl_main.ada --
--
--  Declaration of the "Ada_SDL_Main" function.

package Ada_SDL_Main is

  --
  -- Called by <Ada_SDL_RunApplication> (see "ada_dsl_init.ads").
  --
  function Ada_SDL_Main_Function return Integer;
  pragma Export (C, Ada_SDL_Main_Function, "Ada_SDL_Main_Function");

end Ada_SDL_Main;

